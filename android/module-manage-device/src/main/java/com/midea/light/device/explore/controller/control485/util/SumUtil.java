package com.midea.light.device.explore.controller.control485.util;

public class SumUtil {
    public static String sum(String data){
        String[] hexStrings=data.split(" ");
        int sum = 0; // 求和变量
        for (String hexStr : hexStrings) {
            int num = Integer.parseInt(hexStr, 16); // 将16进制字符串转换为int类型
            sum += num; // 累加求和
        }
        String sumHexStr = Integer.toHexString(sum); // 将求和结果转换为16进制字符串
        if(sumHexStr.length()>2){
            return sumHexStr.substring(sumHexStr.length()-2);
        }else if(sumHexStr.length()==1){
            return "0"+sumHexStr;
        }else{
            return sumHexStr;
        }
    }
}
