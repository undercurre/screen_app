package com.midea.homlux.ai.brocast;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import com.midea.light.log.LogUtil;

//注册成功：安卓系统主动发送WiFi连接状态，网络是否连接的广播
public class NetWorkStateReceiver extends BroadcastReceiver {
    private static NetWorkStateReceiver INSTANT;
    private static final boolean DEBUG = false;

    public static NetWorkStateReceiver getInstant() {
        if (INSTANT == null) {
            INSTANT = new NetWorkStateReceiver();
        }
        return INSTANT;
    }

    private NetWorkStateReceiver() {

    }

    //WiFi是否开启
    private boolean wifiEnable;
    /**
     * 当前连接的wifi信息
     * SSID: Midea, BSSID: 0c:45:ba:99:38:60, MAC: 02:00:00:00:00:00, Supplicant state: COMPLETED,
     * RSSI: -68, Link speed: 65Mbps, Frequency: 2437MHz, Net ID: 28, Metered hint: false, score: 100
     */
    private WifiInfo wifiInfo;

    /**
     * 网络信息类
     * 1. 硬件设备未建立网络连接
     * -1）为空
     * -2）isAvailable() 返回 false
     * 2. 硬件设备建立网络连接
     * -1）不为空
     * -2）isAvailable() 返回 true
     * 3. 当前连接的网络类型
     * -1）getType()
     * <p>
     * TO-STRING
     * [type: WIFI[], state: CONNECTED/CONNECTED, reason: (unspecified), extra: "Midea",
     * failover: false, available: true, roaming: false, metered: false]
     */
    NetworkInfo mNetworkInfo;

    public boolean isWifiEnable() {
        return wifiEnable;
    }

    //获取wifi强度
    public Integer getRRssi() {
        if (wifiInfo == null)
            return null;
        return wifiInfo.getRssi();
    }


    public int getNetWorkType() {
        if (mNetworkInfo == null)
            return -1;
        return mNetworkInfo.getType();
    }

    public boolean netWorkConnect() {
        return mNetworkInfo != null;
    }

    public NetworkInfo getNetworkInfo() {
        return mNetworkInfo;
    }

    public boolean netWorkAvailable() {
        return mNetworkInfo != null && mNetworkInfo.isAvailable();
    }


    @Override
    public void onReceive(Context context, Intent intent) {
        // 监听wifi的打开与关闭，与wifi的连接无关
        if (WifiManager.WIFI_STATE_CHANGED_ACTION.equals(intent.getAction())) {
            int wifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, 0);

            switch (wifiState) {
                case WifiManager.WIFI_STATE_DISABLED:
                    //wifi关闭成功
                    LogUtil.enable(DEBUG).msg("wifiState:" + "WIFI_STATE_DISABLED");
                    wifiEnable = false;
                    break;
                case WifiManager.WIFI_STATE_DISABLING:
                    //wifi正在关闭
                    LogUtil.enable(DEBUG).msg("wifiState:" + "WIFI_STATE_DISABLING");
                    break;
                case WifiManager.WIFI_STATE_ENABLED:
                    //wifi开启成功
                    LogUtil.enable(DEBUG).msg("wifiState:" + "WIFI_STATE_ENABLED");
                    wifiEnable = true;
                    break;
                case WifiManager.WIFI_STATE_ENABLING:
                    //wifi正在开启
                    LogUtil.enable(DEBUG).msg("wifiState:" + "WIFI_STATE_ENABLING");
                    break;
            }
        }


        // 监听网络连接，包括wifi和移动数据的打开和关闭,以及连接上可用的连接都会接到监听
        if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
            //获取联网状态的NetworkInfo对象
            NetworkInfo info = intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);

            if (info != null) {
                //如果当前的网络连接成功并且网络连接可用
                if (NetworkInfo.State.CONNECTED == info.getState() && info.isAvailable()) {
                    if (info.getType() == ConnectivityManager.TYPE_WIFI
                            || info.getType() == ConnectivityManager.TYPE_MOBILE
                            || info.getType() == ConnectivityManager.TYPE_ETHERNET) {
                        LogUtil.enable(DEBUG).msg(getConnectionType(info.getType()) + "连上");
                        LogUtil.enable(DEBUG).msg(info.toString());
                        mNetworkInfo = info;
                        if (info.getType() == ConnectivityManager.TYPE_WIFI) {
                            WifiManager mWifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
                            wifiInfo = mWifiManager.getConnectionInfo();
                        }
                    }
                } else {
                    LogUtil.enable(DEBUG).msg(getConnectionType(info.getType()) + "断开");
                    wifiInfo = null;
                    mNetworkInfo = null;
                }
            }

            if (wifiInfo != null)
                LogUtil.enable(DEBUG).msg("wifi信号强度" + wifiInfo.toString());
        }


    }

    private String getConnectionType(int type) {
        if (type == ConnectivityManager.TYPE_WIFI)
            return "wifi";
        else
            return "mobile";
    }

}
