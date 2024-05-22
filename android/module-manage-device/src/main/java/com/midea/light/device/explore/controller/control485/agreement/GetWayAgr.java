package com.midea.light.device.explore.controller.control485.agreement;

public enum GetWayAgr {

    GET_ALL_AIR_CONDITION_ONLINE_STATE(new byte[]{(byte) (0x01), (byte) (0x50),  (byte) (0x02), (byte) (0xFF), (byte) (0xFF), (byte) (0xFF),(byte) (0x50)}) {
        @Override
       public String signal() {return "查询所有空调的内外机地址和在线状态";
        }
    },
    GET_ALL_AIR_CONDITION_PARAMETE(new byte[]{(byte)(0x01), (byte) (0x50),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0x4D)}) {
        @Override
        public String signal() {return "查询所有空调当前运行状态";}
    },

    GET_ALL_FRESH_AIR_ONLINE_STATE(new byte[]{(byte)(0x01), (byte)(0x51), (byte)(0x02),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0xFF),(byte) (0x51)}) {
        @Override
        public String signal() {return "查询所有新风的内外机地址和在线状态";
        }
    },
    GET_ALL_FRESH_AIR_PARAMETE(new byte[]{(byte)(0x01), (byte)(0x51),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0xFF),  (byte) (0xFF), (byte) (0x4E)}) {
        @Override
        public String signal() {return "查询所有新风当前运行状态";}
    },

    GET_ALL_FLOOR_HOT_ONLINE_STATE(new byte[]{(byte)(0x01), (byte)(0x52), (byte)(0x02), (byte) (0xFF), (byte) (0xFF), (byte) (0xFF), (byte) (0x52)}) {
        @Override
        public String signal() {return "查询所有地暖的内外机地址和在线状态";
        }
    },
    GET_ALL_FLOOR_HOT_PARAMETE(new byte[]{(byte)(0x01), (byte)(0x52), (byte) (0xFF), (byte) (0xFF), (byte) (0xFF), (byte) (0xFF), (byte) (0x4F)}) {
        @Override
        public String signal() {return "查询所有地暖当前运行状态";}
    },

    COMMAND_CHANGE_AIR_CONDITION_TYPE_CODE(new byte[]{(byte)(0x40)}) {
        @Override
        public String signal() {return "切换空调品牌功能码";}
    };



    public byte[] data;

    GetWayAgr(byte[] v) {
        data=v;
    }

    public abstract String signal();

}
