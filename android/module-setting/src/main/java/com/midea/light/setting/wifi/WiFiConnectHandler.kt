package com.midea.light.setting.wifi

import android.content.Context
import android.net.wifi.ScanResult
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import com.midea.light.setting.wifi.impl.IConnectedCallback
import com.midea.light.setting.wifi.impl.Wifi
import com.midea.light.setting.wifi.impl.WifiConnector
import java.lang.ref.WeakReference

/**
 * @ClassName WiFiConnectHandler
 * @Description WiFi连接控制器
 * @Author weinp1
 * @Date 2022/12/5 19:49
 * @Version 1.0
 */
object WiFiConnectHandler : IConnectedCallback {

    // ##WiFi连接器
    private var wifiConnector: WeakReference<WifiConnector>? = null
    // ##WiFi连接回调
    private var callback: IConnectedCallback? = null

    fun connect(context: Context, scanResult: ScanResult, pwd: String, changePwd: Boolean, callback: IConnectedCallback) {

        var wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        //提前断开有线连接
        val security: String = Wifi.ConfigSec.getScanResultSecurity(scanResult)
        val isOpen: Boolean = Wifi.ConfigSec.isOpenNetwork(security)
        val config: WifiConfiguration? = Wifi.getWifiConfiguration(wifiManager, scanResult, security)
        val wifiConnector: WifiConnector = createWiFiConnector(context, scanResult)
        if(isOpen) {
            wifiConnector.connectNewWifi(null, this)
        } else if(config != null) {
            if(changePwd) {
                wifiConnector.changePwd(pwd, this)
            } else {
                wifiConnector.connect(this)
            }
        } else {
            wifiConnector.connectNewWifi(pwd, this)
        }

    }

    private fun createWiFiConnector(context: Context, scanResult: ScanResult) : WifiConnector {
        wifiConnector?.get()?.clear()
        wifiConnector = WeakReference(WifiConnector(context, scanResult))
        return wifiConnector!!.get()!!
    }

    override fun invalidConnect(pwd: String?, scanResult: ScanResult?) {
        callback?.invalidConnect(pwd, scanResult)
        callback = null
        wifiConnector = null
    }

    override fun validConnected(scanResult: ScanResult?) {
        callback?.validConnected(scanResult)
        callback = null
        wifiConnector = null
    }


}