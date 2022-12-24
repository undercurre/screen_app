package com.midea.light.device.explore;

import android.annotation.SuppressLint;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Build;

import com.midea.light.utils.CollectionUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * @ClassName NetUtil
 * @Description 网络工具
 * @Author weinp1
 * @Date 2022/12/23 15:52
 * @Version 1.0
 */
public class NetUtil {

    public static List<WifiConfiguration> getSaveWifiConfiguration(WifiManager wifiManager, String ssid, String bssid) {
        @SuppressLint("MissingPermission") List<WifiConfiguration> configs = wifiManager.getConfiguredNetworks();
        if(CollectionUtil.isNotEmpty(configs)) {
            List<WifiConfiguration> result = new ArrayList<>();
            for (WifiConfiguration config : configs) {
                if(equalRemoveDoubleQuotes(bssid, config.BSSID)) {
                    result.add(config);
                }
            }
            if(CollectionUtil.isEmpty(result)) {
                for (WifiConfiguration config : configs) {
                    if (equalRemoveDoubleQuotes(ssid, config.SSID)) {
                        result.add(config);
                    }
                }
            }
            return result;
        }
        return null;
    }

    public static boolean forgetWiFi(final WifiManager wifiManager, final List<WifiConfiguration> configs) {
        boolean result = true;
        if (CollectionUtil.isNotEmpty(configs)) {
            for (WifiConfiguration config : configs) {
                result &= wifiManager.removeNetwork(config.networkId)
                        && wifiManager.saveConfiguration();
            }
        }
        return result;
    }

    public static boolean connectAlreadySaveWifi(WifiManager wifiManager, WifiConfiguration configuration) {
        if(Build.VERSION.SDK_INT >= 23 ) {
            if (!wifiManager.enableNetwork(configuration.networkId, true)) {
                return false;
            }
            return wifiManager.reconnect();
        } else {
            throw new RuntimeException("目前只支持大于23的机型");
        }
    }

    // 去除双引号
    public static boolean equalRemoveDoubleQuotes(String value1, String value2) {
        value1 = value1.replace("\"","");
        value2 = value2.replace("\"","");
        return Objects.equals(value1, value2);
    }

}
