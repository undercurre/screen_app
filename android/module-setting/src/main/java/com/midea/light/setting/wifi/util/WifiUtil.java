package com.midea.light.setting.wifi.util;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.text.TextUtils;

import com.midea.light.log.LogUtil;
import com.midea.light.setting.wifi.impl.Wifi;
import com.midea.light.setting.wifi.impl.entity.WiFiAccountPasswordBean;
import com.midea.light.setting.wifi.impl.repositories.WiFiRecordRepositories;
import com.midea.light.utils.GsonUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static android.content.Context.CONNECTIVITY_SERVICE;


/**
 * Created by Administrator on 2016/8/28.
 */
public class WifiUtil {

    static int WIFI_MAX_LEVEL = 100;

    // 0 未连接 1 连接中 2已连接
    public static int connectedState(Context context) {
        NetworkInfo networkInfo = getNetworkInfo(context);
        if(null != networkInfo) {
            if(networkInfo.isConnected()) {
                return 2;
            } else if(networkInfo.isConnectedOrConnecting()){
                return 1;
            }
        }
        return 0;
    }

    public static String getEncrypt(ScanResult scanResult) {
        String capabilities = scanResult.capabilities;
        if (!TextUtils.isEmpty(capabilities)) {
            if (capabilities.contains("IEEE8021X") || capabilities.contains("ieee8021x")) {
                return "IEEE8021X";
            } else if (capabilities.contains("WPA-EAP") || capabilities.contains("wpa-eap")) {
                return "WPA-EAP";
            } else if (capabilities.contains("WPA2") || capabilities.contains("wpa2")) {
                return "WPA2";
            } else if (capabilities.contains("WPA") || capabilities.contains("wpa")) {
                return "WPA";
            } else if (capabilities.contains("WEP") || capabilities.contains("wep")) {
                return "WEP";
            } else {
                return "";
            }
        }
        return null;
    }

    public static String getWifiConfigurationSecurity(WifiConfiguration wifiConfig) {

        if (wifiConfig.allowedKeyManagement.get(WifiConfiguration.KeyMgmt.NONE)) {
            // If we never set group ciphers, wpa_supplicant puts all of them.
            // For open, we don't set group ciphers.
            // For WEP, we specifically only set WEP40 and WEP104, so CCMP
            // and TKIP should not be there.
            if (!wifiConfig.allowedGroupCiphers.get(WifiConfiguration.GroupCipher.CCMP)
                    &&
                    (wifiConfig.allowedGroupCiphers.get(WifiConfiguration.GroupCipher.WEP40)
                            || wifiConfig.allowedGroupCiphers.get(WifiConfiguration.GroupCipher.WEP104))) {
                return "WEP";
            } else {
                return "";
            }
        } else if (wifiConfig.allowedProtocols.get(WifiConfiguration.Protocol.RSN)) {
            return "WPA2";
        } else if (wifiConfig.allowedKeyManagement.get(WifiConfiguration.KeyMgmt.WPA_EAP)) {
            return "WPA_EAP";
        } else if (wifiConfig.allowedKeyManagement.get(WifiConfiguration.KeyMgmt.IEEE8021X)) {
            return "IEEE8021X";
        } else if (wifiConfig.allowedProtocols.get(WifiConfiguration.Protocol.WPA)) {
            return "WPA";
        } else {
            return "";
        }
    }

    public static boolean isEncrypt(ScanResult scanResult) {
        String capabilities = scanResult.capabilities;
        if (!TextUtils.isEmpty(capabilities)) {
            if (capabilities.contains("WPA") || capabilities.contains("wpa")) {
                return true;
            } else if (capabilities.contains("WEP") || capabilities.contains("wep")) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }

    public static boolean forgetWifi(final Context context, final String ssid, final String bssid) {
        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        WifiConfiguration config = Wifi.getWifiConfiguration(wifiManager, ssid, bssid);
        return Wifi.forgetWifi(wifiManager, config);
    }

    public static void open(Context context) {
        WifiManager wifiManager = (WifiManager) context.getSystemService(context.WIFI_SERVICE);
        if (!wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(true);
        }
    }

    public static void close(Context context) {
        WifiManager wifiManager = (WifiManager) context.getSystemService(context.WIFI_SERVICE);
        if (wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(false);
        }
    }

    public static boolean wifiEnable(Context context) {
        WifiManager wifiManager = (WifiManager) context.getSystemService(context.WIFI_SERVICE);
        return wifiManager.isWifiEnabled();
    }

    public static boolean isWiFiConnected(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
        NetworkInfo wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (wifi.isConnected()) {
            return true;
        } else {
            return false;
        }
    }

    public static NetworkInfo getNetworkInfo(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
        return cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
    }

    public static WifiInfo getWiFiConnectedInfo(Context context) {
        WifiManager mWifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        return mWifiManager.getConnectionInfo();
    }

    public static void disconnectWifi(Context context, int netId) {
        WifiManager mWifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        mWifiManager.disableNetwork(netId);
        mWifiManager.disconnect();
    }

    public static void filterWifi(List<ScanResult> list) {
        Iterator<ScanResult> iter = list.iterator();
        Map<String, ScanResult> map = new HashMap<>();
        while (iter.hasNext()) {
            ScanResult info = iter.next();
            if (WifiManager.calculateSignalLevel(info.level, WIFI_MAX_LEVEL) <= 1) {
                iter.remove();
            } else if (TextUtils.isEmpty(info.SSID.replace("\"", ""))) {
                iter.remove();
            } else {
                ScanResult scanResult = map.get(info.SSID);
                if (scanResult != null)
                    iter.remove();
                else
                    map.put(info.SSID, info);
            }
        }
        Collections.sort(list, (wifi1, wifi2) -> WifiManager.calculateSignalLevel(wifi2.level, WIFI_MAX_LEVEL) - WifiManager.calculateSignalLevel(wifi1.level, WIFI_MAX_LEVEL));
    }

    public static WiFiAccountPasswordBean findLocalWiFiRecord(String ssid, String bssid) {
        List<String> wifis = WiFiRecordRepositories.getInstance().getAlreadyLoginWiFis();
        if (wifis != null) {
            Iterator<String> iterator = wifis.iterator();
            while (iterator.hasNext()) {
                WiFiAccountPasswordBean bean = GsonUtils.tryParse(WiFiAccountPasswordBean.class, iterator.next());
                if (bean != null) {
                    if (Objects.equals(bean.getSsid(), ssid) && Objects.equals(bean.getBssid(), bssid)) {
                        return bean;
                    } else if(Objects.equals(bean.getSsid(), ssid)) {
                        return bean;
                    }
                }
            }
        }
        return null;
    }

    @SuppressLint("MissingPermission")
    public static void removeAllConfiguration(Context context) {
        WifiManager wifiMgr = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        final List<WifiConfiguration> configs = wifiMgr.getConfiguredNetworks();
        List<String> wifis = WiFiRecordRepositories.getInstance().getAlreadyLoginWiFis();
        if (null != configs) {
            for (WifiConfiguration config : configs) {
                boolean result = wifiMgr.removeNetwork(config.networkId)
                        && wifiMgr.saveConfiguration();
                if (result) {
                    LogUtil.i(config.SSID + "wifi配置清除失败");
                    if (wifis != null) {
                        Iterator<String> iterator = wifis.iterator();
                        while (iterator.hasNext()) {
                            WiFiAccountPasswordBean bean = GsonUtils.tryParse(WiFiAccountPasswordBean.class, iterator.next());
                            if (bean != null) {
                                if (Objects.equals(bean.getSsid(), config.SSID)) {
                                    iterator.remove();
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            WiFiRecordRepositories.getInstance().clearAllWiFi();
            if (wifis != null && wifis.size() > 0) {
                WiFiRecordRepositories.getInstance().saveWiFi(wifis);
            }
        }

    }


}
