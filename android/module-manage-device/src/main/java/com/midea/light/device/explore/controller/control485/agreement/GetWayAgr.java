package com.midea.light.device.explore.controller.control485.agreement;

public enum GetWayAgr {

    GET_ALL_AIR_CONDITION_ONLINE_STATE("01 50 02 FF FF FF 50") {
        @Override
       public String signal() {return "查询所有空调的内外机地址和在线状态";
        }
    },
    GET_ALL_AIR_CONDITION_PARAMETE("01 50 FF FF FF FF 4D") {
        @Override
        public String signal() {return "查询所有空调当前运行状态";}
    },

    GET_ALL_FRESH_AIR_ONLINE_STATE("01 51 02 FF FF FF 51") {
        @Override
        public String signal() {return "查询所有新风的内外机地址和在线状态";
        }
    },
    GET_ALL_FRESH_AIR_PARAMETE("01 51 FF FF FF FF 4E") {
        @Override
        public String signal() {return "查询所有新风当前运行状态";}
    },

    GET_ALL_FLOOR_HOT_ONLINE_STATE("01 52 02 FF FF FF 52") {
        @Override
        public String signal() {return "查询所有地暖的内外机地址和在线状态";
        }
    },
    GET_ALL_FLOOR_HOT_PARAMETE("01 52 FF FF FF FF 4F") {
        @Override
        public String signal() {return "查询所有地暖当前运行状态";}
    },

    COMMAND_CHANGE_AIR_CONDITION_TYPE_CODE("40") {
        @Override
        public String signal() {return "切换空调品牌功能码";}
    };



    public String data;

    GetWayAgr(String v) {
        data=v;
    }

    public abstract String signal();

}
