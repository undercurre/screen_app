package com.midea.light.migration;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.utils.GsonUtils;

/**
 * Token迁移
 */
public class MigrateTokenCache extends AbstractMMKVSetting {

    private static MigrateTokenCache INSTANT = new MigrateTokenCache();

    public static MigrateTokenCache getInstance() {
        return INSTANT;
    }

    private final static String TOKEN = "token";
    private final static String USER_ID = "user_id";
    private final static String IOT_USER_ID = "iot_user_id";
    private final static String DATA_ENCODE_KEY = "data_encode_key";
    private final static String DATA_DECODE_KEY = "data_decode_key";
    private final static String DEVICE_ID = "uuid";

    public String getToken() {
        Object json =  get(TOKEN, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getUserID() {
        return get(USER_ID, String.class);
    }

    public String getIotUserId() {
        return get(IOT_USER_ID, String.class);
    }

    public String getDataEncodeKey() {
        return get(DATA_ENCODE_KEY, String.class);
    }

    public String getDataDecodeKey() {
        return get(DATA_DECODE_KEY, String.class);
    }

    public String getDevicesId() {
        String uuid = get(DEVICE_ID, String.class);
        return uuid != null ? uuid : "";
    }

    public void saveDevicesId(String uuid) {
        save(DEVICE_ID, uuid);
    }

    @Override
    protected String getFileName() {
        return "global_setting";
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.SYSTEM_SETTING_DIR;
    }
}

