package com.midea.light.setting.wifi.impl;

import android.net.wifi.ScanResult;

/**
 * @ClassName IConnectedCallback
 * @Description 回调wifi是否连接成功
 * @Author weinp1
 * @Date 2021/11/26 17:03
 * @Version 1.0
 */
public interface IConnectedCallback {
    void invalidConnect(String pwd, ScanResult scanResult);

    void validConnected(ScanResult scanResult);
}
