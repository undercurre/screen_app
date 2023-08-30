package com.midea.light.migration;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.utils.GsonUtils;

/**
 * Homlux数据迁移
 */
public class MigrateHomluxCache extends AbstractMMKVSetting {

    private static MigrateHomluxCache INSTANT = new MigrateHomluxCache();

    public static MigrateHomluxCache getInstance() {
        return INSTANT;
    }

    private static final String KEY_TOKEN = "key_token";
    private static final String KEY_FAMILY = "key_family";
    private static final String KEY_ROOM = "key_room";
    private static final String KEY_USER = "key_user";
    private static final String KEY_BIND_GATEWAY_INFO = "key_bind_gateway_info";


    public String getToken() {
        Object json =  get(KEY_TOKEN, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getFamily() {
        Object json =  get(KEY_FAMILY, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getRoom() {
        Object json =  get(KEY_ROOM, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getUserData() {
        Object json =  get(KEY_USER, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getBindGatewayInfo() {
        Object json =  get(KEY_BIND_GATEWAY_INFO, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    @Override
    protected String getFileName() {
        return "user_global_setting";
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.HOMLUX_DIR;
    }
}

