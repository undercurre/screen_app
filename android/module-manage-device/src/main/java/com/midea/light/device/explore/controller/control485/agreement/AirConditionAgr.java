package com.midea.light.device.explore.controller.control485.agreement;

public enum AirConditionAgr {

    AIR_CONDITION_QUERY_CODE("50") {
        @Override
        public String signal() {return "空调功能码";}
    },

    ALL_AIR_CONDITION_QUERY_ONLINE_STATE_CODE("02") {
        @Override
        public String signal() {return "空调离在线查询码";}
    },

    ALL_AIR_CONDITION_QUERY_PARELETE_CODE("FF") {
        @Override
        public String signal() {return "空调全状态查询码";}
    },

    COMMAND_ON_OFF_CODE("31"){
        @Override
        public String signal() {return "控制开关功能码";}
    },

    COMMAND_TEMP_CODE("32"){
        @Override
        public String signal() {return "控制温度功能码";}
    },

    COMMAND_MODEL_CODE("33"){
        @Override
        public String signal() {return "控制模式功能码";}
    },

    COMMAND_WIND_SPEED_CODE("34"){
        @Override
        public String signal() {return "控制风速功能码";}
    },

    ON_LINE("01") {
        @Override
        public String signal() {
            return "在线";
        }
    },

    OFF_LINE("00") {
        @Override
        public String signal() {
            return "离线";
        }
    },

    OPEN("01") {
        @Override
       public String signal() {
            return "空调开机";
        }
    },

    CLOSE("00") {
        @Override
        public String signal() {return "空调关机";}
    },

    COLD_MODEL("01") {
        @Override
        public String signal() {return "制冷模式";}
    },

    WET_MODEL("02") {
        @Override
        public String signal() {return "除湿模式";}
    },

    REFRESHING_MODEL("03") {
        @Override
        public String signal() {return "清爽模式";}
    },

    WIND_MODEL("04") {
        @Override
        public String signal() {return "送风模式";}
    },

    AUTO_WET_MODEL("05") {
        @Override
        public String signal() {return "自动除湿模式";}
    },

    SLEEP_MODEL("06") {
        @Override
        public String signal() {return "睡眠模式";}
    },

    HOT_MODEL("08") {
        @Override
        public String signal() {return "制热模式";}
    },

    FLOOR_HOT_MODEL("09") {
        @Override
        public String signal() {return "地暖模式";}
    },

    STRONG_HOT_MODEL("0A") {
        @Override
        public String signal() {return "强热模式";}
    },

    WIND_AUTO("00") {
        @Override
        public String signal() {return "自动风";}
    },

    WIND_HIGHT("01") {
        @Override
        public String signal() {return "高速风";}
    },

    WIND_MIDDLE("02") {
        @Override
        public String signal() {return "中速风";}
    },

    WIND_MIDDLE_HIGHT("03") {
        @Override
        public String signal() {return "中高速风";}
    },

    WIND_LOW("04") {
        @Override
        public String signal() {return "低速风";}
    },

    WIND_MIDDLE_LOW("05") {
        @Override
        public String signal() {return "中低速风";}
    },

    WIND_SMALL("06") {
        @Override
        public String signal() {return "微风";}
    },

    RI_LI_TYPE("01"){
        @Override
        public String signal() {return "日立";}
    },

    DA_JIN_TYPE("02"){
        @Override
        public String signal() {return "大金";}
    },

    DONG_ZHI_TYPE("03"){
        @Override
        public String signal() {return "东芝";}
    },

    SAN_LING_ZHONG_GONG_TYPE("04"){
        @Override
        public String signal() {return "三菱重工";}
    },

    SAN_LING_DIAN_JI_TYPE("05"){
        @Override
        public String signal() {return "三菱电机";}
    },

    GE_LI_TYPE("06"){
        @Override
        public String signal() {return "格力";}
    },

    HAI_XIN_TYPE("07"){
        @Override
        public String signal() {return "海信";}
    },

    MEI_DI_TYPE("08"){
        @Override
        public String signal() {return "美的";}
    },

    HAI_ER_TYPE("09"){
        @Override
        public String signal() {return "海尔";}
    },

    LG_TYPE("0A"){
        @Override
        public String signal() {return "LG";}
    },

    SAN_XING_TYPE("0D"){
        @Override
        public String signal() {return "三星";}
    },

    AO_KE_SI_TYPE("0E"){
        @Override
        public String signal() {return "奥克斯";}
    },

    SONG_XIA_TYPE("0F"){
        @Override
        public String signal() {return "松下";}
    },

    YUE_KE_TYPE("10"){
        @Override
        public String signal() {return "约克";}
    },

    GE_LI_4_TYPE("13"){
        @Override
        public String signal() {return "格力四代";}
    },

    MAIKE_TYPE("15"){
        @Override
        public String signal() {return "麦克维尔";}
    },

    TCL_TYPE("18"){
        @Override
        public String signal() {return "TCL";}
    },

    ZHI_GAO_TYPE("19"){
        @Override
        public String signal() {return "志高";}
    },

    TIAN_JIA_TYPE("1A"){
        @Override
        public String signal() {return "天加";}
    },

    YUEKE_WATER_TYPE("23"){
        @Override
        public String signal() {return "约克水机";}
    },

    KU_FENG_TYPE("24"){
        @Override
        public String signal() {return "酷风";}
    },

    QINGDAO_YUE_KE_TYPE("25"){
        @Override
        public String signal() {return "青岛约克";}
    },

    FU_SHI_TONG_TYPE("26"){
        @Override
        public String signal() {return "富士通";}
    },

    AIMOSHENG_WATER_TYPE("65"){
        @Override
        public String signal() {return "艾默生水机";}
    },

    MAIKE_WATER_TYPE("66"){
        @Override
        public String signal() {return "麦克维尔水机";}
    };


    public String data;

    AirConditionAgr(String v) {
        data=v;
    }

    public abstract String signal();

    public static AirConditionAgr parseWindSpeed(String data){
        if(WIND_AUTO.data.equals(data)){
            return WIND_AUTO;
        }else if(WIND_HIGHT.data.equals(data)){
            return WIND_HIGHT;
        }else if(WIND_MIDDLE.data.equals(data)){
            return WIND_MIDDLE;
        }else if(WIND_MIDDLE_HIGHT.data.equals(data)){
            return WIND_MIDDLE_HIGHT;
        }else if(WIND_LOW.data.equals(data)){
            return WIND_LOW;
        }else if(WIND_MIDDLE_LOW.data.equals(data)){
            return WIND_MIDDLE_LOW;
        }else if(WIND_SMALL.data.equals(data)){
            return WIND_SMALL;
        }else{
            return WIND_AUTO;
        }
    }

    public static AirConditionAgr parseWorkModel(String data){
        if(COLD_MODEL.data.equals(data)){
            return COLD_MODEL;
        }else if(WET_MODEL.data.equals(data)){
            return WET_MODEL;
        }else if(REFRESHING_MODEL.data.equals(data)){
            return REFRESHING_MODEL;
        }else if(WIND_MODEL.data.equals(data)){
            return WIND_MODEL;
        }else if(AUTO_WET_MODEL.data.equals(data)){
            return AUTO_WET_MODEL;
        }else if(SLEEP_MODEL.data.equals(data)){
            return SLEEP_MODEL;
        }else if(HOT_MODEL.data.equals(data)){
            return HOT_MODEL;
        }else if(FLOOR_HOT_MODEL.data.equals(data)){
            return FLOOR_HOT_MODEL;
        }else if(STRONG_HOT_MODEL.data.equals(data)){
            return STRONG_HOT_MODEL;
        }else{
            return COLD_MODEL;
        }
    }

    public static AirConditionAgr parseAirConditionType(String data){
        if(RI_LI_TYPE.data.equals(data)){
            return RI_LI_TYPE;
        }else if(DA_JIN_TYPE.data.equals(data)){
            return DA_JIN_TYPE;
        }else if(DONG_ZHI_TYPE.data.equals(data)){
            return DONG_ZHI_TYPE;
        }else if(SAN_LING_ZHONG_GONG_TYPE.data.equals(data)){
            return SAN_LING_ZHONG_GONG_TYPE;
        }else if(SAN_LING_DIAN_JI_TYPE.data.equals(data)){
            return SAN_LING_DIAN_JI_TYPE;
        }else if(GE_LI_TYPE.data.equals(data)){
            return GE_LI_TYPE;
        }else if(HAI_XIN_TYPE.data.equals(data)){
            return HAI_XIN_TYPE;
        }else if(MEI_DI_TYPE.data.equals(data)){
            return MEI_DI_TYPE;
        }else if(HAI_ER_TYPE.data.equals(data)){
            return HAI_ER_TYPE;
        }else if(LG_TYPE.data.equals(data)){
            return LG_TYPE;
        }else if(SAN_XING_TYPE.data.equals(data)){
            return SAN_XING_TYPE;
        }else if(AO_KE_SI_TYPE.data.equals(data)){
            return AO_KE_SI_TYPE;
        }else if(SONG_XIA_TYPE.data.equals(data)){
            return SONG_XIA_TYPE;
        }else if(YUE_KE_TYPE.data.equals(data)){
            return YUE_KE_TYPE;
        }else if(GE_LI_4_TYPE.data.equals(data)){
            return GE_LI_4_TYPE;
        }else if(MAIKE_TYPE.data.equals(data)){
            return MAIKE_TYPE;
        }else if(TCL_TYPE.data.equals(data)){
            return TCL_TYPE;
        }else if(ZHI_GAO_TYPE.data.equals(data)){
            return ZHI_GAO_TYPE;
        }else if(TIAN_JIA_TYPE.data.equals(data)){
            return TIAN_JIA_TYPE;
        }else if(YUEKE_WATER_TYPE.data.equals(data)){
            return YUEKE_WATER_TYPE;
        }else if(KU_FENG_TYPE.data.equals(data)){
            return KU_FENG_TYPE;
        }else if(QINGDAO_YUE_KE_TYPE.data.equals(data)){
            return QINGDAO_YUE_KE_TYPE;
        }else if(FU_SHI_TONG_TYPE.data.equals(data)){
            return FU_SHI_TONG_TYPE;
        }else if(AIMOSHENG_WATER_TYPE.data.equals(data)){
            return AIMOSHENG_WATER_TYPE;
        }else if(MAIKE_WATER_TYPE.data.equals(data)){
            return MAIKE_WATER_TYPE;
        }else{
            return MEI_DI_TYPE;
        }
    }



}
