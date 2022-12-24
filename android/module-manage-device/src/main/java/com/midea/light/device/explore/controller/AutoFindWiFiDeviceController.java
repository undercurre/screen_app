package com.midea.light.device.explore.controller;

import android.net.wifi.ScanResult;
import android.os.Bundle;

import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.beans.WiFiScanResult;
import com.midea.light.utils.CollectionUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @ClassName AutoScanDeviceController
 * @Description 自动扫描检测服务
 * @Author weinp1
 * @Date 2021/8/24 20:23
 * @Version 1.0
 */
public class AutoFindWiFiDeviceController extends FindWiFiDeviceController {
    public static final int MAX_AUTO_SCAN_COUNT = 3;
    int currentScanCount;

    public AutoFindWiFiDeviceController(PortalContext context) {
        super(context);
    }

    @Override
    public void request(String method, Bundle bundle) {
        super.request(method, bundle);
        if (Portal.METHOD_SCAN_WIFI_START.equals(method)) {
            currentScanCount = MAX_AUTO_SCAN_COUNT;
        }
    }

    @Override
    protected void notifyWiFiListChange() {
        super.notifyWiFiListChange();
        currentScanCount --;
        if(currentScanCount == 0) {
            stopLoopScanWifi();
        }
    }

    @Override
    protected ArrayList<WiFiScanResult> convert(List<ScanResult> list) {
        ArrayList<WiFiScanResult> wiFiScanResults = super.convert(list);
        if(CollectionUtil.isNotEmpty(wiFiScanResults)) {
            wiFiScanResults = (ArrayList<WiFiScanResult>) wiFiScanResults.stream()
                    .filter(e-> alreadyMap.containsKey(e.SSID()))
                    .collect(Collectors.toList());
        }
        return wiFiScanResults;
    }

}
