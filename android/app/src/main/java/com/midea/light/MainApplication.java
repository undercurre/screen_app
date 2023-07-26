package com.midea.light;


import android.content.Context;

import com.aispeech.dca.DcaConfig;
import com.aispeech.dca.DcaSdk;
import com.midea.light.basic.BuildConfig;
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
import com.midea.light.utils.ProcessUtil;
import com.tencent.bugly.crashreport.CrashReport;

import androidx.multidex.MultiDex;

public class MainApplication extends BaseApplication {
    public static final Boolean DEBUG = BuildConfig.DEBUG;
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
        // 设置是否位开发设备
        CrashReport.setIsDevelopmentDevice(BaseApplication.getContext(), DEBUG);

        //思必驰语音sdk初始化
        DcaConfig dcaConfig = new DcaConfig.Builder()
                .apiKey(AppCommonConfig.DCA_API_KEY)
                .apiSecret(AppCommonConfig.DCA_API_SECRET)
                .openDebugLog(true)
                .publicKey(AppCommonConfig.DCA_PUB_KEY)
                .build();
        DcaSdk.initialize(MainApplication.this, dcaConfig);  //初始化dca sdk

        //wifi 10秒刷新一次
//        CommandExecution.execCommand("wpa_cli bss_expire_age 10", true);
        //wifi 缓冲为1
//        CommandExecution.execCommand("wpa_cli bss_expire_count 1", true);
        //bss flush
//        CommandExecution.execCommand("wpa_cli bss_flush", true);

    }

}