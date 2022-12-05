package com.midea.light.setting.wifi.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import androidx.annotation.NonNull;

import com.midea.light.setting.SystemUtil;

/**
 * @ClassName EthernetUtil
 * @Description 有线局域网工具类
 * @Author weinp1
 * @Date 2021/8/17 20:30
 * @Version 1.0
 */
public class EthernetUtil {

    /**
     * @param context
     * @return 0 (断开连接) 1(正在连接) 2(已经连接)
     */
    public static int connectedState(@NonNull Context context) {
        ConnectivityManager mConnectivityManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = mConnectivityManager
                .getNetworkInfo(ConnectivityManager.TYPE_ETHERNET);

        if (info == null)
            return 0;
        if (info.getState() == NetworkInfo.State.CONNECTING)
            return 1;
        else if (info.getState() == NetworkInfo.State.CONNECTED)
            return 2;
        return 0;
    }

    public static boolean isConnected(@NonNull Context context) {
        ConnectivityManager mConnectivityManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = mConnectivityManager
                .getNetworkInfo(ConnectivityManager.TYPE_ETHERNET);
        return info != null && info.isConnected();
    }

    public static void open() {
        SystemUtil.connectEth();
    }

    public static void close() {
        SystemUtil.disconnectEth();
    }

}
