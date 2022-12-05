package com.midea.light.setting.wifi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager.CONNECTIVITY_ACTION
import android.net.wifi.WifiInfo
import com.midea.light.BaseApplication
import com.midea.light.setting.wifi.util.EthernetUtil
import com.midea.light.setting.wifi.util.WifiUtil

/**
 * @ClassName ConnectStateHandler
 * @Description 连接控制器
 * @Author weinp1
 * @Date 2022/12/5 17:59
 * @Version 1.0
 */
object ConnectStateHandler {

    var register = false
    val callbacks = lazy { mutableSetOf<ICallBack>() }

    interface ICallBack {
        // 0 未连接 1 连接中 2 已连接
        fun connectedState(ethernet: Int, wifi: Int, wifiInfo: WifiInfo?)
    }

    val mScanWiFiReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {
            if(intent?.action?.equals(CONNECTIVITY_ACTION) == true) {
                val ethernetState = EthernetUtil.connectedState(BaseApplication.getContext())
                val wifiState = WifiUtil.connectedState(BaseApplication.getContext())
                callbacks.value.forEach { action -> action.connectedState(
                    ethernetState,
                    wifiState,
                    WifiUtil.getWiFiConnectedInfo(BaseApplication.getContext())
                )}
            }
        }
    }

    fun register(callback: ICallBack) {
        callbacks.value.add(callback)
    }

    fun unRegister(callback: ICallBack) {
        callbacks.value.remove(callback)
    }

    fun start(context: Context) {
        if(!register) {
            // 启动检查
            val ethernetState = EthernetUtil.connectedState(BaseApplication.getContext())
            val wifiState = WifiUtil.connectedState(BaseApplication.getContext())
            callbacks.value.forEach { action -> action.connectedState(
                ethernetState,
                wifiState,
                WifiUtil.getWiFiConnectedInfo(BaseApplication.getContext())
            )}

            context.registerReceiver(mScanWiFiReceiver, IntentFilter().apply {
                addAction(CONNECTIVITY_ACTION)
            })
            register = true
        }
    }

    fun stop(context: Context) {
        if(register) {
            callbacks.value.clear()
            context.unregisterReceiver(mScanWiFiReceiver)
            register = false
        }
    }

}