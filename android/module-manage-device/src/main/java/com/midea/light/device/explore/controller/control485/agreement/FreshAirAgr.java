package com.midea.light.device.explore.controller.control485.agreement;

public enum FreshAirAgr {

    FRESH_AIR_QUERY_CODE("51") {
        @Override
        public String signal() {return "新风查询功能码";}
    },

    ALL_FRESH_AIR_QUERY_ONLINE_STATE_CODE("02") {
        @Override
        public String signal() {return "新风离在线查询码";}
    },

    ALL_FRESH_AIR_QUERY_PARELETE_CODE("FF") {
        @Override
        public String signal() {return "新风全状态查询码";}
    },

    COMMAND_FRESH_AIR_ON_OFF_CODE("71"){
        @Override
        public String signal() {return "控制开关功能码";}
    },

    COMMAND_FRESH_AIR_MODEL_CODE("73"){
        @Override
        public String signal() {return "控制模式功能码";}
    },

    COMMAND_FRESH_AIR_WIND_SPEED_CODE("74"){
        @Override
        public String signal() {return "控制风速功能码";}
    },

    FRESH_AIR_ON_LINE("01") {
        @Override
        public String signal() {
            return "新风在线";
        }
    },

    FRESH_AIR_OFF_LINE("00") {
        @Override
        public String signal() {
            return "新风离线";
        }
    },

    FRESH_AIR_OPEN("01") {
        @Override
       public String signal() {
            return "新风开机";
        }
    },

    FRESH_AIR_CLOSE("00") {
        @Override
        public String signal() {return "新风关机";}
    },


    FRESH_AIR_WIND_AUTO("00") {
        @Override
        public String signal() {return "自动风";}
    },

    FRESH_AIR_WIND_HIGHT("01") {
        @Override
        public String signal() {return "高速风";}
    },

    FRESH_AIR_WIND_MIDDLE("02") {
        @Override
        public String signal() {return "中速风";}
    },

    FRESH_AIR_WIND_MIDDLE_HIGHT("03") {
        @Override
        public String signal() {return "中高速风";}
    },

    FRESH_AIR_WIND_LOW("04") {
        @Override
        public String signal() {return "低速风";}
    },

    FRESH_AIR_WIND_MIDDLE_LOW("05") {
        @Override
        public String signal() {return "中低速风";}
    },

    FRESH_AIR_WIND_SMALL("06") {
        @Override
        public String signal() {return "微风";}
    },

    FRESH_AIR_ZI_DONG_MODEL("00") {
        @Override
        public String signal() {return "自动模式";}
    },

    FRESH_AIR_HUAN_QI_MODEL("01") {
        @Override
        public String signal() {return "换气模式";}
    },

    FRESH_AIR_PAI_FENG_MODEL("02") {
        @Override
        public String signal() {return "排风模式";}
    },

    FRESH_AIR_ZHI_NENG_MODEL("03") {
        @Override
        public String signal() {return "智能模式";}
    },

    FRESH_AIR_QIANG_JING_MODEL("04") {
        @Override
        public String signal() {return "强劲模式";}
    },

    FRESH_AIR_SHENG_DIAN_MODEL("05") {
        @Override
        public String signal() {return "省电模式";}
    },

    FRESH_AIR_SONG_FENG_MODEL("06") {
        @Override
        public String signal() {return "送风模式";}
    },

    FRESH_AIR_PANG_TONG_MODEL("07") {
        @Override
        public String signal() {return "旁通模式";}
    },

    FRESH_AIR_SU_JING_MODEL("08") {
        @Override
        public String signal() {return "速净模式";}
    },

    FRESH_AIR_SHU_SHI_MODEL("09") {
        @Override
        public String signal() {return "舒适模式";}
    },

    FRESH_AIR_LIANG_FENG_MODEL("0A") {
        @Override
        public String signal() {return "凉风模式";}
    },

    FRESH_AIR_SHOU_DONG_MODEL("0B") {
        @Override
        public String signal() {return "手动模式";}
    },

    FRESH_AIR_JING_YIN_MODEL("0C") {
        @Override
        public String signal() {return "静音模式";}
    },

    FRESH_AIR_XIN_FENG_MODEL("0D") {
        @Override
        public String signal() {return "新风模式";}
    },

    FRESH_AIR_ZHI_LENG_MODEL("0E") {
        @Override
        public String signal() {return "制冷模式";}
    },

    FRESH_AIR_ZHI_RE_MODEL("0F") {
        @Override
        public String signal() {return "制热模式";}
    },

    FRESH_AIR_CHU_SHI_MODEL("10") {
        @Override
        public String signal() {return "除湿模式";}
    },

    FRESH_AIR_RE_JIAO_HUAN_MODEL("11") {
        @Override
        public String signal() {return "热交换模式";}
    },

    FRESH_AIR_NEI_XUN_HUAN_MODEL("12") {
        @Override
        public String signal() {return "内循环模式";}
    },

    FRESH_AIR_WAI_XUN_HUAN_MODEL("13") {
        @Override
        public String signal() {return "外循环模式";}
    },

    FRESH_AIR_HUN_FENG_MODEL("14") {
        @Override
        public String signal() {return "混风模式";}
    },

    FRESH_AIR_GUAN_BI_MODEL("15") {
        @Override
        public String signal() {return "关闭模式";}
    },

    FRESH_AIR_XIN_FENG_CHU_SHI_MODEL("16") {
        @Override
        public String signal() {return "新风除湿模式";}
    },

    FRESH_AIR_DING_SHI_MODEL("17") {
        @Override
        public String signal() {return "定时模式";}
    },

    FRESH_AIR_STRONG_HOT_MODEL("18") {
        @Override
        public String signal() {return "除霾模式";}
    },

    FRESH_AIR_CHU_SHUANG_MODEL("19") {
        @Override
        public String signal() {return "除霜模式";}
    },

    FRESH_AIR_NEI_CHU_SHI_MODEL("1A") {
        @Override
        public String signal() {return "内除湿模式";}
    };


    public String data;

    FreshAirAgr(String v) {
        data=v;
    }

    public abstract String signal();

    public static FreshAirAgr parseWindSpeed(String data){
        if(FRESH_AIR_WIND_AUTO.data.equals(data)){
            return FRESH_AIR_WIND_AUTO;
        }else if(FRESH_AIR_WIND_HIGHT.data.equals(data)){
            return FRESH_AIR_WIND_HIGHT;
        }else if(FRESH_AIR_WIND_MIDDLE.data.equals(data)){
            return FRESH_AIR_WIND_MIDDLE;
        }else if(FRESH_AIR_WIND_MIDDLE_HIGHT.data.equals(data)){
            return FRESH_AIR_WIND_MIDDLE_HIGHT;
        }else if(FRESH_AIR_WIND_LOW.data.equals(data)){
            return FRESH_AIR_WIND_LOW;
        }else if(FRESH_AIR_WIND_MIDDLE_LOW.data.equals(data)){
            return FRESH_AIR_WIND_MIDDLE_LOW;
        }else if(FRESH_AIR_WIND_SMALL.data.equals(data)){
            return FRESH_AIR_WIND_SMALL;
        }else{
            return FRESH_AIR_WIND_AUTO;
        }
    }

    public static FreshAirAgr parseWorkModel(String data){
        if(FRESH_AIR_ZI_DONG_MODEL.data.equals(data)){
            return FRESH_AIR_ZI_DONG_MODEL;
        }else if(FRESH_AIR_HUAN_QI_MODEL.data.equals(data)){
            return FRESH_AIR_HUAN_QI_MODEL;
        }else if(FRESH_AIR_PAI_FENG_MODEL.data.equals(data)){
            return FRESH_AIR_PAI_FENG_MODEL;
        }else if(FRESH_AIR_ZHI_NENG_MODEL.data.equals(data)){
            return FRESH_AIR_ZHI_NENG_MODEL;
        }else if(FRESH_AIR_QIANG_JING_MODEL.data.equals(data)){
            return FRESH_AIR_QIANG_JING_MODEL;
        }else if(FRESH_AIR_SHENG_DIAN_MODEL.data.equals(data)){
            return FRESH_AIR_SHENG_DIAN_MODEL;
        }else if(FRESH_AIR_SONG_FENG_MODEL.data.equals(data)){
            return FRESH_AIR_SONG_FENG_MODEL;
        }else if(FRESH_AIR_PANG_TONG_MODEL.data.equals(data)){
            return FRESH_AIR_PANG_TONG_MODEL;
        }else if(FRESH_AIR_SU_JING_MODEL.data.equals(data)){
            return FRESH_AIR_SU_JING_MODEL;
        }else if(FRESH_AIR_SHU_SHI_MODEL.data.equals(data)){
            return FRESH_AIR_SHU_SHI_MODEL;
        }else if(FRESH_AIR_LIANG_FENG_MODEL.data.equals(data)){
            return FRESH_AIR_LIANG_FENG_MODEL;
        }else if(FRESH_AIR_SHOU_DONG_MODEL.data.equals(data)){
            return FRESH_AIR_SHOU_DONG_MODEL;
        }else if(FRESH_AIR_JING_YIN_MODEL.data.equals(data)){
            return FRESH_AIR_JING_YIN_MODEL;
        }else if(FRESH_AIR_XIN_FENG_MODEL.data.equals(data)){
            return FRESH_AIR_XIN_FENG_MODEL;
        }else if(FRESH_AIR_ZHI_LENG_MODEL.data.equals(data)){
            return FRESH_AIR_ZHI_LENG_MODEL;
        }else if(FRESH_AIR_ZHI_RE_MODEL.data.equals(data)){
            return FRESH_AIR_ZHI_RE_MODEL;
        }else if(FRESH_AIR_CHU_SHI_MODEL.data.equals(data)){
            return FRESH_AIR_CHU_SHI_MODEL;
        }else if(FRESH_AIR_RE_JIAO_HUAN_MODEL.data.equals(data)){
            return FRESH_AIR_RE_JIAO_HUAN_MODEL;
        }else if(FRESH_AIR_NEI_XUN_HUAN_MODEL.data.equals(data)){
            return FRESH_AIR_NEI_XUN_HUAN_MODEL;
        }else if(FRESH_AIR_WAI_XUN_HUAN_MODEL.data.equals(data)){
            return FRESH_AIR_WAI_XUN_HUAN_MODEL;
        }else if(FRESH_AIR_HUN_FENG_MODEL.data.equals(data)){
            return FRESH_AIR_HUN_FENG_MODEL;
        }else if(FRESH_AIR_GUAN_BI_MODEL.data.equals(data)){
            return FRESH_AIR_GUAN_BI_MODEL;
        }else if(FRESH_AIR_XIN_FENG_CHU_SHI_MODEL.data.equals(data)){
            return FRESH_AIR_XIN_FENG_CHU_SHI_MODEL;
        }else if(FRESH_AIR_DING_SHI_MODEL.data.equals(data)){
            return FRESH_AIR_DING_SHI_MODEL;
        }else if(FRESH_AIR_STRONG_HOT_MODEL.data.equals(data)){
            return FRESH_AIR_STRONG_HOT_MODEL;
        }else if(FRESH_AIR_CHU_SHUANG_MODEL.data.equals(data)){
            return FRESH_AIR_CHU_SHUANG_MODEL;
        }else if(FRESH_AIR_NEI_CHU_SHI_MODEL.data.equals(data)){
            return FRESH_AIR_NEI_CHU_SHI_MODEL;
        }else{
            return FRESH_AIR_ZI_DONG_MODEL;
        }
    }

}
