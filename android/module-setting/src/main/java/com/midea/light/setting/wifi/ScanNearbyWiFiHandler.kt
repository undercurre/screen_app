package com.midea.light.setting.wifi

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import androidx.annotation.MainThread
import androidx.core.app.ActivityCompat
import com.midea.light.log.LogUtil

/**
 * @ClassName ScanNearbyWiFiHandler
 * @Description 搜索附近的WiFi
 * @Author weinp1
 * @Date 2022/11/16 15:15
 * @Version 1.0
 */
object ScanNearbyWiFiHandler {

    interface ICallBack {
        fun call(result: List<ScanResult>)
    }

    var register = false
    val callbacks = lazy { mutableSetOf<ICallBack>() }
    lateinit var wifiManager: WifiManager;

    val mScanWiFiReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {
            if (intent?.action?.equals(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION) == true) {
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    callbacks.value.forEach { action -> action.call(wifiManager.scanResults) }
                }
                com.midea.light.thread.MainThread.postDelayed({ wifiManager.startScan() },2000L)
            }
        }
    }

    fun register(callback: ICallBack) {
        callbacks.value.add(callback)
    }

    fun unRegister(callBack: ICallBack) {
        callbacks.value.remove(callBack)
    }

    fun start(context: Context) {
        if (!register) {
            LogUtil.tag("NET").msg("scan wiFi start -----")
            context.registerReceiver(mScanWiFiReceiver, IntentFilter().apply {
                addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
            })
            wifiManager =
                context.getSystemService(android.content.Context.WIFI_SERVICE) as android.net.wifi.WifiManager
            wifiManager.startScan()
            register = true
        }
    }

    fun stop(context: Context) {
        if (register) {
            LogUtil.tag("NET").msg("scan wiFi stop -----")
            context.unregisterReceiver(mScanWiFiReceiver)
            register = false
        }
    }

}