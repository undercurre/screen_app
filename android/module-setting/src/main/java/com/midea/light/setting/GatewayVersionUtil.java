package com.midea.light.setting;

import android.content.Context;

import androidx.annotation.NonNull;

import com.midea.light.bean.GatewayPlatform;

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
    public static String getSystemVersion(Context context, GatewayPlatform gatewayPlatform) {
        return "0000" +
                getAppVersion(context) +
                getGatewayVersion(gatewayPlatform);
    }
    public static String getGatewayVersion(GatewayPlatform gatewayPlatform) {
        return com.midea.light.gateway.GatewayVersionUtil.getGatewayVersion(gatewayPlatform.rawPlatform());
    }
    public static String getAppVersion(Context context) {
        String version =  com.midea.light.gateway.GatewayVersionUtil.getAppVersion();
        StringBuilder builder = new StringBuilder();
        String[] s = version.split("\\.");
        for (String s1 : s) {
            builder.append(s1);
        }
        // 小于四位前面补零
        if(builder.length() < 4) {
            for (int i = builder.length(); i < 4; i++) {
                builder.insert(0,"0");
            }
        }
        return builder.toString();
    }
}
