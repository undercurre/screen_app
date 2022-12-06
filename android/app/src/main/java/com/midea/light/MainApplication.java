package com.midea.light;


import android.content.Context;

import com.midea.light.basic.BuildConfig;
import com.midea.light.log.config.LogConfiguration;
import com.midea.light.log.config.MSmartLogger;
import com.midea.light.repositories.config.KVRepositoryConfig;
import com.midea.light.repositories.config.MSmartKVRepository;

import androidx.multidex.MultiDex;

public class MainApplication extends BaseApplication {
    public static final Boolean DEBUG = BuildConfig.DEBUG;
    public static final String MMKV_CRYPT_KEY = "16a62e2997ae0dda";

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
                .withMMKVCryptKey(MMKV_CRYPT_KEY)
                .build());
    }


}