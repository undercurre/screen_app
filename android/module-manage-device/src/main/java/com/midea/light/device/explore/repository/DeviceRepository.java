package com.midea.light.device.explore.repository;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;

/**
 * @ClassName DeviceRepositry
 * @Description
 * @Author weinp1
 * @Date 2021/7/17 15:22
 * @Version 1.0
 */
public class DeviceRepository extends AbstractMMKVSetting {
    private static final String FILE_NAME = "devices_repository";
    private static final String GATEWAY_BIND_DETAIL = "gateway_bind_detail";
    private final static String GATEWAY_BIND_USER = "gateway_bind_user_home";
    private final static String GATEWAY_BIND_AUTHORIZE_USER_HOME = "gateway_bind_authorize_user_home";
    private final static String GATEWAY_SN = "gateway_sn";


    /**
     * 本实例
     */
    private static DeviceRepository instance;

    /**
     * 私有的构造方法
     */
    private DeviceRepository() {
    }

    /**
     * 单例的实例
     *
     * @return this
     */
    public static DeviceRepository getInstance() {
        if (instance == null) {
            synchronized (DeviceRepository.class) {
                if (instance == null) {
                    instance = new DeviceRepository();
                }
            }
        }
        return instance;
    }

    @Override
    protected String getFileName() {
        return FILE_NAME;
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.DEVICE_SETTING_DIR;
    }

}
