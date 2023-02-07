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
        // 最多尝试到currentScanCount值为0就停止扫描
        if(currentScanCount <= 0) {
            stopLoopScanWifi();
        } else {
            super.notifyWiFiListChange();
        }
        currentScanCount --;
    }

    @Override
    protected ArrayList<WiFiScanResult> convert(final List<ScanResult> list) {
        List<ScanResult> newList = null;
        if(CollectionUtil.isNotEmpty(list)) {
            newList = list.stream()
                    .filter(s -> !alreadyMap.containsKey(s.SSID))
                    .collect(Collectors.toList());
        }
        return super.convert(newList);
    }

    @Override
    public int sendDataToClient(List<ScanResult> list) {
        int count = super.sendDataToClient(list);
        if(count > 0) {
            currentScanCount = 0;
            stopLoopScanWifi();
        }
        return count;
    }

}
