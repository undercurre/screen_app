package com.midea.light;


import android.app.ActivityManager;
import android.content.Context;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.midea.light.bean.GatewayPlatform;
import com.midea.light.channel.method.AliPushChannel;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.common.record.MideaBuriedPoint;
import com.midea.light.config.GatewayConfig;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.issued.IssuedManager;
import com.midea.light.issued.distribution.GateWayDistributionIssuedMatch;
import com.midea.light.issued.plc.PLCControlIssuedMatch;
import com.midea.light.issued.relay.RelayIssuedMatch;
import com.midea.light.issued.switchModel.SwitchModelIssuedMatch;
import com.midea.light.log.config.LogConfiguration;
import com.midea.light.log.config.MSmartLogger;
import com.midea.light.repositories.config.KVRepositoryConfig;
import com.midea.light.repositories.config.MSmartKVRepository;
import com.midea.light.setting.SystemUtil;
import com.midea.light.setting.relay.RelayControl;
import com.midea.light.setting.relay.RelayRepository;
import com.midea.light.setting.relay.VoiceIssuedMatch;
import com.midea.light.utils.ProcessUtil;
import com.midea.light.utils.RootCmd;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;
import java.util.function.Supplier;

import io.reactivex.rxjava3.schedulers.Schedulers;

public class MainApplication extends BaseApplication {
    public static final Boolean DEBUG = false;
    public static final String MMKV_CRYPT_KEY = "16a62e2997ae0dda";
    public static MainActivity mMainActivity;
    public static boolean standbyState=false;

    public static GatewayPlatform gatewayPlatform = GatewayPlatform.NONE;

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        application = this;
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // 初始化日志库
        MSmartLogger.init(LogConfiguration.LogConfigurationBuilder.create()
                .withEnable(DEBUG)
                .withStackFrom(0)
                .withStackTo(4)
                .withTag("M-Smart")
                .build());
        // 初始化本地存储仓库
        MSmartKVRepository.init(KVRepositoryConfig.KVRepositoryConfigBuilder.create(this)
                .withInitMMKVRepository(true)
                .withInitSharedPreferenceRepository(false)
                .withLogEnable(DEBUG)
                .withLogTag("MSmartKVRepository")
                .withMMKVCryptKey(AppCommonConfig.MMKV_CRYPT_KEY)
                .build());

        boolean isMainProcess = ProcessUtil.isInMainProcess(this);
        // #初始化Bugly
        BuglyManager.init(BuildConfig.DEBUG, (throwable, randomCode) -> false);

        if(!isMainProcess) {
            AliPushChannel.aliPushInit(this);
            return;
        } else {
            // 每次主进程重启，都将删除ai相关进程
            Schedulers.computation().scheduleDirect(() -> {
                try {
                    ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
                    List<ActivityManager.RunningAppProcessInfo> processes = activityManager.getRunningAppProcesses();
                    for (ActivityManager.RunningAppProcessInfo process : processes) {
                        if("com.midea.light:aiHomlux".equals(process.processName)) {
                            Log.i("sky", "即将删除进程com.midea.light:aiHomlux");
                            RootCmd.execRootCmdSilent("killall com.midea.light:aiHomlux");
                        }

                        if("com.midea.light:aiMeiJu".equals(process.processName)) {
                            Log.i("sky", "即将删除进程com.midea.light:aiMeiJu");
                            RootCmd.execRootCmdSilent("killall com.midea.light:aiMeiJu");
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }

        /// *************  注意注意 *******************
        /// 下面的初始化，只能在com.midea.light进程中初始化
        AliPushChannel.aliPushInit(this);

        // 初始化网关
        GateWayUtils.init();
        // #设置继电器控制器
        GatewayConfig.relayControl = new RelayControl();
        // #注册继电器捕抓器
        IssuedManager.getInstance().register(new RelayIssuedMatch());
        // #注册语音播报捕抓器
        IssuedManager.getInstance().register(new VoiceIssuedMatch());
        // #注册网关配网状态捕抓器
        IssuedManager.getInstance().register(new GateWayDistributionIssuedMatch());
        // #注册485设备控制下发捕抓器
        IssuedManager.getInstance().register(new PLCControlIssuedMatch());
        // #注册按键模式捕捉器
        IssuedManager.getInstance().register(new SwitchModelIssuedMatch());


        if(RelayRepository.getInstance().getGP0Model()!=0){
            SystemUtil.CommandGP(0, true);
            GatewayConfig.relayControl.controlRelay1Open(true);
        }else{
            GatewayConfig.relayControl.controlRelay1Open(RelayRepository.getInstance().getGP0State());
        }

        if(RelayRepository.getInstance().getGP1Model()!=0){
            SystemUtil.CommandGP(1, true);
            GatewayConfig.relayControl.controlRelay2Open(true);
        }else{
            GatewayConfig.relayControl.controlRelay2Open(RelayRepository.getInstance().getGP1State());
        }

        // #上报继电器状态
        GatewayConfig.relayControl.reportRelayStateChange();
        // #延迟初始化
        MideaBuriedPoint.init((Supplier<com.midea.light.common.record.BuriedPointService>) () -> new ByteDanceBuriedPointService());



        //wifi 10秒刷新一次
//        CommandExecution.execCommand("wpa_cli bss_expire_age 10", true);
        //wifi 缓冲为1
//        CommandExecution.execCommand("wpa_cli bss_expire_count 1", true);
        //bss flush
//        CommandExecution.execCommand("wpa_cli bss_flush", true);

    }

    private String executeCommand(String command) {
        Process process = null;
        try {
            process = Runtime.getRuntime().exec(command);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        InputStream inputStream = process.getInputStream();
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
        StringBuilder output = new StringBuilder();
        String line;
        while (true) {
            try {
                if (!((line = bufferedReader.readLine()) != null)) break;
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            output.append(line).append("\n");
        }
        return output.toString();
    }

}