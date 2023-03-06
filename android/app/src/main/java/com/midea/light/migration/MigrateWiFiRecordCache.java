package com.midea.light.migration;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;

import java.util.List;

/**
 * @ClassName WiFiRecordRepositories
 * @Description 用于保存wifi密码等信息
 * @Author weinp1
 * @Date 2021/8/31 18:00
 * @Version 1.0
 */
public class MigrateWiFiRecordCache extends AbstractMMKVSetting {

    private static final String FILE_NAME = "wifi_record";
    private final static String SETTING_WIFI_CACHE_LIST = "setting_wifi_cache_list";
    /**
     * 本实例
     */
    private static MigrateWiFiRecordCache instance;

    /**
     * 私有的构造方法
     */
    private MigrateWiFiRecordCache() {
    }

    /**
     * 单例的实例
     *
     * @return this
     */
    public static MigrateWiFiRecordCache getInstance() {
        if (instance == null) {
            synchronized (MigrateWiFiRecordCache.class) {
                if (instance == null) {
                    instance = new MigrateWiFiRecordCache();
                }
            }
        }
        return instance;
    }

    public List<String> getAlreadyLoginWiFis() {
        return get(SETTING_WIFI_CACHE_LIST, List.class);
    }


    @Override
    protected String getFileName() {
        return FILE_NAME;
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.WIFI_RECORD;
    }

}