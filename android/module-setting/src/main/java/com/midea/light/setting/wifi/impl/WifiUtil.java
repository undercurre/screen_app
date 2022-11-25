package com.midea.light.setting.wifi.impl;

import static android.content.Context.CONNECTIVITY_SERVICE;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.text.TextUtils;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import com.midea.light.BaseApplication;
import com.midea.light.log.LogUtil;
import com.midea.light.setting.wifi.impl.entity.WiFiAccountPasswordBean;
import com.midea.light.setting.wifi.impl.repositories.WiFiRecordRepositories;
import com.midea.light.utils.GsonUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Created by Administrator on 2016/8/28.
 */
public class WifiUtil {

    static int WIFI_MAX_LEVEL = 100;

    public WifiManager mWifiManager;

    private WifiInfo mWifiInfo;

    private List<ScanResult> mWifiList;

    private Context context;

    private List<WifiConfiguration> mWificonfiguration;

    private WifiManager.WifiLock mWifiLock;


    public WifiUtil(Context context) {
        mWifiManager = (WifiManager) context.getSystemService(context.WIFI_SERVICE);
        this.context = context;
        mWifiInfo = mWifiManager.getConnectionInfo();
    }

    public void open() {
        if (!mWifiManager.isWifiEnabled()) {
            mWifiManager.setWifiEnabled(true);
        }
    }

    public void close() {
        if (mWifiManager.isWifiEnabled()) {
            mWifiManager.setWifiEnabled(false);
        }
    }

    public int checkState() {
        return mWifiManager.getWifiState();
    }

    public void acquireWifiLoc() {
        mWifiLock.acquire();
    }

    public void releaseWifiLock() {
        if (mWifiLock.isHeld()) {
            mWifiLock.acquire();
        }
    }

    public void createWifiLock() {
        mWifiLock = mWifiManager.createWifiLock("test");
    }

    public List<WifiConfiguration> getConfigurations() {
        return mWificonfiguration;
    }

    public Boolean connectConfiguration(int index) {

//        if(index > mWificonfiguration.size()) {
//            return;
//        }
        mWifiManager.enableNetwork(index, true);
        mWifiManager.saveConfiguration();
        mWifiManager.reconnect();

        return true;
    }

    public void startScan() {
        mWifiManager.startScan();
        mWifiList = mWifiManager.getScanResults();
        mWificonfiguration = mWifiManager.getConfiguredNetworks();
    }

    public List<ScanResult> getmWifiList() {
        return mWifiList;
    }

    public StringBuilder lookUpScan() {
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i < mWifiList.size(); i++) {
            stringBuilder.append("Index_" + String.valueOf(i + 1) + ":");
            stringBuilder.append(mWifiList.get(i).toString());
            stringBuilder.append("/n");
        }
        return stringBuilder;
    }

    public String getMacAddress() {
        return (mWifiInfo == null) ? "NULL" : mWifiInfo.getMacAddress();
    }

    public String getSSID() {
        return (mWifiInfo == null) ? "NULL" : mWifiInfo.getSSID();
    }

    public int getIpAddress() {
        return (mWifiInfo == null) ? 0 : mWifiInfo.getIpAddress();
    }

    public int getNetworkId() {
        return (mWifiInfo == null) ? 0 : mWifiInfo.getNetworkId();

    }

    public boolean isWifiConnect() {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
        NetworkInfo wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (wifi.isConnected()) {
            return true;
        } else {
            return false;
        }
    }

    public String getWifiInfo() {
        return (mWifiInfo == null) ? "NULL" : mWifiInfo.toString();
    }

    public boolean addNetWork(WifiConfiguration wifiConfiguration) {
        int wcgID = mWifiManager.addNetwork(wifiConfiguration);
        Log.e("wcgID", wcgID + "true");
        mWifiManager.enableNetwork(wcgID, true);
        mWifiManager.saveConfiguration();
        return mWifiManager.reconnect();
    }

    public void disconnectWifi(int netId) {
        mWifiManager.disableNetwork(netId);
        mWifiManager.disconnect();
    }

    public WifiConfiguration createWifiInfo(String SSID, String Password, int Type) {
        WifiConfiguration configuration = new WifiConfiguration();
        configuration.allowedAuthAlgorithms.clear();
        configuration.allowedGroupCiphers.clear();
        configuration.allowedKeyManagement.clear();
        configuration.allowedPairwiseCiphers.clear();
        configuration.allowedProtocols.clear();
        configuration.SSID = "\"" + SSID + "\"";

        WifiConfiguration tempConfig = this.isExsits(SSID);
        if (tempConfig != null) {
            mWifiManager.removeNetwork(tempConfig.networkId);
        }

        switch (Type) {
            case 1://没加密
                configuration.wepKeys[0] = "";
                configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
                configuration.wepTxKeyIndex = 0;
                configuration.priority = 20000;
                break;
            case 2://wep加密
                configuration.hiddenSSID = false;
                configuration.wepKeys[0] = "\"" + Password + "\"";
                configuration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);
                configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);

                break;
            case 3://wpa加密

                configuration.preSharedKey = "\"" + Password + "\"";
                configuration.hiddenSSID = false;
                // configuration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
                configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);
                configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
                configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
                configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
                configuration.status = WifiConfiguration.Status.ENABLED;
                break;
        }
        return configuration;
    }

    public int calculateWifiEncryptType(String encryptType) {
        if (encryptType == null)
            return -1;
        else {
            if ("WPA".equals(encryptType)) {
                return 3;
            } else if ("WEP".equals(encryptType)) {
                return 2;
            } else {
                return 1;
            }
        }
    }

    public int calculateWifiEncryptType(ScanResult scanResult) {
        String encryptType = getEncrypt(scanResult);
        return calculateWifiEncryptType(encryptType);
    }

    private WifiConfiguration isExsits(String SSID) {
        List<WifiConfiguration> existingConfigs = mWifiManager.getConfiguredNetworks();
        for (WifiConfiguration existingConfig :
                existingConfigs) {
            if (existingConfig.SSID.equals("\"" + SSID + "\"")) {
                return existingConfig;
            }
        }
        return null;
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
