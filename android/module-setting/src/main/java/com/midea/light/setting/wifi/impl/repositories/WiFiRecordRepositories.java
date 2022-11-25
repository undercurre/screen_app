package com.midea.light.setting.wifi.impl.repositories;

import androidx.annotation.NonNull;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.setting.wifi.impl.entity.WiFiAccountPasswordBean;
import com.midea.light.utils.GsonUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * @ClassName WiFiRecordRepositories
 * @Description 用于保存wifi密码等信息
 * @Author weinp1
 * @Date 2021/8/31 18:00
 * @Version 1.0
 */
public class WiFiRecordRepositories extends AbstractMMKVSetting {

    private static final String FILE_NAME = "wifi_record";
    private final static String SETTING_WIFI_CACHE_LIST = "setting_wifi_cache_list";
    /**
     * 本实例
     */
    private static WiFiRecordRepositories instance;

    /**
     * 私有的构造方法
     */
    private WiFiRecordRepositories() {
    }

    /**
     * 单例的实例
     *
     * @return this
     */
    public static WiFiRecordRepositories getInstance() {
        if (instance == null) {
            synchronized (WiFiRecordRepositories.class) {
                if (instance == null) {
                    instance = new WiFiRecordRepositories();
                }
            }
        }
        return instance;
    }


    public void saveWiFi(WiFiAccountPasswordBean bean) {
        List<String> list = getAlreadyLoginWiFis();
        if (list == null) {
            list = new ArrayList<>();
        }

        for (int i = 0; i < list.size(); i++) {
            String accountAndPassword = list.get(i);
            WiFiAccountPasswordBean cacheBean = GsonUtils.tryParse(WiFiAccountPasswordBean.class, accountAndPassword);
            if (cacheBean != null) {
                if (cacheBean.getSsid().equals(bean.getSsid())) {
                    list.set(i, GsonUtils.stringify(bean));
                    save(SETTING_WIFI_CACHE_LIST, list);
                    return;
                }
            }
        }

        list.add(GsonUtils.stringify(bean));
        save(SETTING_WIFI_CACHE_LIST, list);
    }
    public void saveWiFi(@NonNull List<String> data) {
        save(SETTING_WIFI_CACHE_LIST, data);
    }

    public void remove(WiFiAccountPasswordBean bean) {
        List<String> list = getAlreadyLoginWiFis();
        if (list == null) {
            return;
        }

        list  = list.stream().filter(s -> {
            WiFiAccountPasswordBean cacheBean = GsonUtils.tryParse(WiFiAccountPasswordBean.class, s);
            return cacheBean != null && bean.getSsid().equals(cacheBean.getSsid());
        }).collect(Collectors.toList());

        save(SETTING_WIFI_CACHE_LIST, list);
    }

    public List<String> getAlreadyLoginWiFis() {
        return get(SETTING_WIFI_CACHE_LIST, List.class);
    }

    public void clearAllWiFi() {
        clear(SETTING_WIFI_CACHE_LIST);
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