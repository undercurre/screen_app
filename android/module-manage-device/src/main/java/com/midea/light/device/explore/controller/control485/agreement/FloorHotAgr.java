package com.midea.light.device.explore.controller.control485.agreement;

public enum FloorHotAgr {

    FLOOR_HOT_QUERY_CODE("52") {
        @Override
        public String signal() {return "地暖功能码";}
    },

    ALL_FLOOR_HOT_QUERY_ONLINE_STATE_CODE("02") {
        @Override
        public String signal() {return "地暖离在线查询码";}
    },

    ALL_FLOOR_HOT_QUERY_PARELETE_CODE("FF") {
        @Override
        public String signal() {return "地暖全状态查询码";}
    },

    COMMAND_FLOOR_HOT_ON_OFF_CODE("81"){
        @Override
        public String signal() {return "控制开关功能码";}
    },

    COMMAND_FLOOR_HOT_TEMP_CODE("82"){
        @Override
        public String signal() {return "控制温度功能码";}
    },

    COMMAND_FLOOR_HOT_FANG_DONG_CODE("84"){
        @Override
        public String signal() {return "控制防冻保护功能码";}
    },

    FLOOR_HOT_ON_LINE("01") {
        @Override
        public String signal() {
            return "在线";
        }
    },

    FLOOR_HOT_OFF_LINE("00") {
        @Override
        public String signal() {
            return "离线";
        }
    },

    FLOOR_HOT_OPEN("01") {
        @Override
       public String signal() {
            return "地暖开机";
        }
    },

    FLOOR_HOT_CLOSE("00") {
        @Override
        public String signal() {return "地暖关机";}
    },

    FLOOR_HOT_FANG_DONG_CLOSE("00") {
        @Override
        public String signal() {return "防冻保护关闭";}
    },

    FLOOR_HOT_FANG_DONG_OPEN("01") {
        @Override
        public String signal() {return "防冻保护开启";}
    };

    public String data;

    FloorHotAgr(String v) {
        data=v;
    }

    public abstract String signal();




}
