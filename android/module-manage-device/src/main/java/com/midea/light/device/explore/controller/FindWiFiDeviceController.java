package com.midea.light.device.explore.controller;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Message;
import android.os.RemoteException;

import androidx.core.app.ActivityCompat;

import com.midea.light.device.explore.ClientMessenger;
import com.midea.light.device.explore.IServiceController;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.PortalContext;
import com.midea.light.device.explore.beans.WiFiScanResult;
import com.midea.light.device.explore.database.DeviceDatabaseHelper;
import com.midea.light.device.explore.database.entity.CommonDeviceIconAndNameEntity;
import com.midea.light.log.LogUtil;
import com.midea.light.utils.CollectionUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.functions.Consumer;
import io.reactivex.rxjava3.schedulers.Schedulers;

/**
 * @ClassName FindWiFiDeviceController
 * @Description 发现wifi设备Controller
 * @Author weinp1
 * @Date 2022/12/22 9:20
 * @Version 1.0
 */
public class FindWiFiDeviceController extends AbstractController implements IServiceController {
    // 搜索的wifi设备名称，要匹配下面wifi的正则表达式
    private final static String WIFI_TEMPLATE = "midea_(..)_....";
    // 每隔五秒搜索一次
    private final static long FAST_SEARCH_INTERVAL = 5000;
    // 扫描WiFi结果接收器
    private WifiScanReceiver mWifiScanReceiver;
    // wifi管理器
    private WifiManager wifiManager;
    // 用于保存此已经提醒过的设备[静态变量]
    protected Map<String, ScanResult> alreadyMap = new HashMap<>();
    // 标识当前的WiFi扫描是否启动
    private Boolean startScan = Boolean.FALSE;
    // 定时器句柄
    Disposable mDisposable;

    private class WifiScanReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context c, Intent intent) {
            String action = intent.getAction();
            if (action.equals(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)) {
                notifyWiFiListChange();
            }
        }
    }

    public FindWiFiDeviceController(PortalContext context) {
        super(context);
    }

    @Override
    public void request(String method, Bundle bundle) {
        if (Portal.METHOD_SCAN_WIFI_START.equals(method)) {
            startLoopScanWifi();
        } else if (Portal.METHOD_SCAN_WIFI_STOP.equals(method)) {
            //停止循环
            stopLoopScanWifi();
        }
    }

    @Override
    protected void onHandleMessageToCallback(Message msg) {

    }
    // 启动扫描wifi
    public synchronized void startLoopScanWifi() {
        if(!startScan) {
            // 初始化接收器
            mWifiScanReceiver = new WifiScanReceiver();
            getContext().registerReceiver(
                    mWifiScanReceiver,
                    new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
            wifiManager = (WifiManager) getContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            startScan = Boolean.TRUE;
            // 启动定时器
            Observable.interval(FAST_SEARCH_INTERVAL, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.io())
                    .doOnSubscribe(new Consumer<Disposable>() {
                        @Override
                        public void accept(Disposable disposable) throws Throwable {
                            mDisposable = disposable;
                        }
                    })
                    .subscribe(new Consumer<Long>() {
                        @Override
                        public void accept(Long aLong) throws Throwable {
                            if (ActivityCompat.checkSelfPermission(getContext(),
                                    Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                                throw new RuntimeException("暂未有权限，启动wifi天线扫描设备");
                            }
                            // 只有wifi天线是打开的时候，才会扫描附近的设备
                            if(wifiManager.isWifiEnabled()) {
                                wifiManager.startScan();
                                LogUtil.i("启动wifi扫描");
                            }
                        }
                    });
        }
    }

    // 停止扫描wifi
    public synchronized void stopLoopScanWifi() {
        if(mDisposable != null && !mDisposable.isDisposed()) {
            mDisposable.dispose();
        }
        try {
            if (mWifiScanReceiver != null) {
                getContext().unregisterReceiver(mWifiScanReceiver);
                mWifiScanReceiver = null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        startScan = Boolean.FALSE;
    }

    // 通知wifi列表内容发生变化
    protected void notifyWiFiListChange() {
        if (!startScan) { return; }
        @SuppressLint("MissingPermission")
        List<ScanResult> wifiList = wifiManager.getScanResults();
        LogUtil.i("扫描到的wifi数量: " + wifiList.size());
        if(CollectionUtil.isNotEmpty(wifiList)) {

            wifiList = wifiList.stream()
                    .filter(FindWiFiDeviceController.this::isRssiPass)
                    .collect(Collectors.toList());

            if(CollectionUtil.isNotEmpty(wifiList)) {
                // 回调数据到上游
                List<ScanResult> finalWifiList = wifiList;
                getHandler().post(() -> {
                    sendDataToClient(finalWifiList);
                });
            }
        }
    }

    // 判定当前的wifi是否符合模板
    boolean isRssiPass(ScanResult scanResult) {
        //匹配模板{ midea_.._.... } WiFi强度的范围指需满足范围：[-82 , 0]
        if (!scanResult.SSID.isEmpty() && scanResult.SSID.replaceAll(WIFI_TEMPLATE, "").equals("")) {
            if (scanResult.level < 0 && scanResult.level > -82) {
                LogUtil.i("找寻到设备热点的WiFi" + scanResult.toString());
                return true;
            } else {
                LogUtil.i("强度不够：设备热点的WiFi" + scanResult.toString());
                return false;
            }
        }
        return false;
    }

    public int sendDataToClient(List<ScanResult> list) {
        int count = 0;
        try {
            ArrayList<WiFiScanResult> newList = convert(list);
            count = newList != null ? newList.size() : 0;
            for (ClientMessenger messenger : getMessengerList()) {
                Message message = Message.obtain();
                Bundle bundle = new Bundle();
                bundle.putParcelableArrayList(Portal.RESULT_SCAN_WIFI_DEVICES, newList);
                message.setData(bundle);
                messenger.send(message);
            }

        } catch (RemoteException e) {
            e.printStackTrace();
        }
        return count;
    }

    protected ArrayList<WiFiScanResult> convert(List<ScanResult> list) {
        if(CollectionUtil.isEmpty(list)) return null;

        return (ArrayList<WiFiScanResult>) list.stream()
                .peek(e -> alreadyMap.put(e.SSID, e))
                .map(scanResult -> {
                    WiFiScanResult scanResult1 = new WiFiScanResult();
                    scanResult1.setScanResult(scanResult);
                    Matcher matcher = Pattern.compile(WIFI_TEMPLATE).matcher(scanResult.SSID);
                    if (matcher.find()) {
                        String code = matcher.group(1);
                        CommonDeviceIconAndNameEntity entity = DeviceDatabaseHelper.getInstant().finDeviceInCommon(code);
                        if (entity != null) {
                            scanResult1.setIcon(entity.icon);
                            scanResult1.setName(entity.name);
                        }
                    }
                    return scanResult1;
                })
                .collect(Collectors.toList());
    }

}
