package com.midea.light;


import android.content.Context;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.midea.light.bean.GatewayPlatform;
import com.midea.light.channel.method.AliPushChannel;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.config.GatewayConfig;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.issued.IssuedManager;
import com.midea.light.issued.distribution.GateWayDistributionIssuedMatch;
import com.midea.light.issued.plc.PLCControlIssuedMatch;
import com.midea.light.issued.relay.RelayIssuedMatch;
import com.midea.light.log.config.LogConfiguration;
import com.midea.light.log.config.MSmartLogger;
import com.midea.light.repositories.config.KVRepositoryConfig;
import com.midea.light.repositories.config.MSmartKVRepository;
import com.midea.light.setting.relay.RelayControl;
import com.midea.light.setting.relay.RelayRepository;
import com.midea.light.setting.relay.VoiceIssuedMatch;
import com.midea.light.utils.AndroidManifestUtil;
import com.midea.light.utils.MacUtil;
import com.midea.light.utils.ProcessUtil;
import com.tencent.bugly.crashreport.CrashReport;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class MainApplication extends BaseApplication {
    public static final Boolean DEBUG = true;
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
        Thread thread =new Thread(){
            public  void  run(){
                try {
                    Thread.sleep(18000);
                    String re= executeCommand("sh /data/midea/bin/gwInit.sh");
                    Log.e("sky","网关启动:"+re);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
        };thread.start();

        // 初始化日志库
        if(!ProcessUtil.isInMainProcess(this)) {
            AliPushChannel.aliPushInit(this);
            return;
        }
        AliPushChannel.aliPushInit(this);

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

        GatewayConfig.relayControl.controlRelay1Open(RelayRepository.getInstance().getGP0State());
        GatewayConfig.relayControl.controlRelay2Open(RelayRepository.getInstance().getGP1State());

        // #上报继电器状态
        GatewayConfig.relayControl.reportRelayStateChange();
        // 初始化Bugly
        CrashReport.initCrashReport(this, AndroidManifestUtil.getMetaDataString(BaseApplication.getContext(), "BUGLY_ID"), DEBUG);
        //带上设备的mac地址
        CrashReport.putUserData(this, "mac_address",  MacUtil.macAddress("wlan0"));
        // 设置是否位开发设备
        CrashReport.setIsDevelopmentDevice(BaseApplication.getContext(), DEBUG);



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