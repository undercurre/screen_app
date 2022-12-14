package com.midea.light.setting;

import android.content.Context;

import androidx.annotation.NonNull;

/**
 * @ClassName GatewayVersionUtil
 * @Description 为了适配Flutter，在外定制一层
 * @Author weinp1
 * @Date 2022/12/14 15:40
 * @Version 1.0
 */
public class GatewayVersionUtil {
    public static int compare(@NonNull String v1, @NonNull String v2) {
        return com.midea.light.gateway.GatewayVersionUtil.compare(v1, v2);
    }
    public static String getSystemVersion(Context context) {
        return "0000" +
                getAppVersion(context) +
                getGatewayVersion();
    }
    public static String getGatewayVersion() {
        return com.midea.light.gateway.GatewayVersionUtil.getGatewayVersion();
    }
    public static String getAppVersion(Context context) {
        String version =  com.midea.light.gateway.GatewayVersionUtil.getAppVersion(context);
        String[] s = version.split("\\.");
        StringBuilder builder = new StringBuilder();
        builder.append(0);
        for (String s1 : s) {
            builder.append(s1);
        }
        return builder.toString();
    }
}
