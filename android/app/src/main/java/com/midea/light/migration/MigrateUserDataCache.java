package com.midea.light.migration;
import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.utils.GsonUtils;
import com.midea.smart.open.common.util.StringUtils;

public class MigrateUserDataCache extends AbstractMMKVSetting {

    private static final String FILE_NAME_FORMAT = "user_%s_setting";

    private String fileName;

    /**
     * @param uuid 当前用户的唯一标识
     */
    public MigrateUserDataCache(String uuid) {
        fileName = String.format(FILE_NAME_FORMAT, !StringUtils.isEmpty(uuid) ? uuid : "default").toLowerCase();
    }

    public static MigrateUserDataCache create() {
        return new MigrateUserDataCache(MigrateTokenCache.getInstance().getUserID());
    }

    /**
     * 业务逻辑 -- keys
     */
    private static final String USER_INFO = "user_info";
    private static final String MEI_JU_IS_MIGRATE = "meiju_is_migrate";

    private static final String USER_ROOM_ORDER = "user_room_%s_order";
    private static final String USER_SCENE_ORDER = "user_scene_order";

    private static final String USER_ROOM_SHORT_CUT = "user_room_%s_short_cut";
    private static final String USER_ROOM_GP_SHORT_CUT = "user_room_GP_%s_short_cut";

    private static final String USER_AI_AUTHORIZATION = "user_home_%s_ai_authorization";//记录语音是否授权

    private static final String GATEWAY_INFOR="GatewayInfor";//保存的网关信息


    public String getUserInfo() {
        Object json =  get(USER_INFO, Object.class);
        if(json == null) return "";
        return GsonUtils.stringify(json);
    }

    public String getMeiJuIsMigrate() {
        String json =  get(MEI_JU_IS_MIGRATE, String.class);
        if(json == null) return "0";
        return "1";
    }

    public void setMeiJuIsMigrate() {
        save(MEI_JU_IS_MIGRATE,"1");
    }

    @Override
    protected String getFileName() {
        return fileName;
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.USER_SETTING_DIR;
    }


}
