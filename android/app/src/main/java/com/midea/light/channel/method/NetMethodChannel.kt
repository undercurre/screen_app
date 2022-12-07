package com.midea.light.channel.method

import android.content.Context
import android.net.wifi.ScanResult
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.channel.HybridResult
import com.midea.light.common.config.AppCommonConfig
import com.midea.light.log.LogUtil
import com.midea.light.setting.wifi.ConnectStateHandler
import com.midea.light.setting.wifi.ScanNearbyWiFiHandler
import com.midea.light.setting.wifi.WiFiConnectHandler
import com.midea.light.setting.wifi.impl.ConfigurationSecurities
import com.midea.light.setting.wifi.impl.IConnectedCallback
import com.midea.light.setting.wifi.impl.Version
import com.midea.light.setting.wifi.util.EthernetUtil
import com.midea.light.setting.wifi.util.WifiUtil
import com.midea.light.thread.MainThread
import com.midea.light.utils.CollectionUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject


private const val TAG = "NET"

private const val MIN_RSSI = -100
private const val MAX_RSSI = -55

/**
 * @ClassName NetMethodChanel
 * @Description 网络 -- 方法通道
 * @Author weinp1
 * @Date 2022/11/17 13:37
 * @Version 1.0
 */
class NetMethodChannel constructor(override val context: Context) : AbsMZMethodChannel(context),
    ScanNearbyWiFiHandler.ICallBack, ConnectStateHandler.ICallBack {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): NetMethodChannel {
            val methodChannel = NetMethodChannel(context)
            methodChannel.setup(binaryMessenger, channel);
            return methodChannel
        }
    }


    var mWifiManager: WifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager

    // 保存最新的wifi列表
    var wifiList: HashMap<String, ScanResult>? = null //缓存所有的历史扫描的wifi记录

    override fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        super.setup(binaryMessenger, channel)
        LogUtil.tag(TAG).msg("ScanNearbyWiFiHandler Register")
        ScanNearbyWiFiHandler.register(this)
        ConnectStateHandler.register(this)
    }

    override fun teardown() {
        super.teardown()
        ScanNearbyWiFiHandler.unRegister(this)
        ConnectStateHandler.unRegister(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        var reply: Boolean = false
        LogUtil.tag(TAG).msg("flutter -> method: ${call.method}")
        when (call.method) {
            "scanNearbyWiFi" -> {
                ScanNearbyWiFiHandler.start(context)
                // 加快列表展示的数据，使用冷数据进行预加载
                if (wifiList?.isEmpty() == false) {
                    onReplyNearbyWiFi(wifiList!!.values)
                }
            }
            "stopScanNearbyWiFi" -> {
                ScanNearbyWiFiHandler.stop(context)
                onCallSuccess(result, true)
            }
            "listenerConnectState" -> {
                ConnectStateHandler.start(context)
                onCallSuccess(result, true)
            }
            "removeListenerConnectState" -> {
                ConnectStateHandler.stop(context)
                onCallSuccess(result, true)
            }
            "supportWiFiControl" -> {
               onCallSuccess(result, true)
            }
            "supportEthernetControl" -> {
                onCallSuccess(result, AppCommonConfig.getChannel().equals("LD"))
            }
            "enableWiFi" -> {
                assert(call.hasArgument("enable"))
                val enable = call.argument<Boolean>("enable")
                if(enable!!) {
                    WifiUtil.open(context)
                } else {
                    WifiUtil.close(context)
                }
                onCallSuccess(result, true)
            }
            "enableEthernet" -> {
                assert(call.hasArgument("enable"))
                val enable = call.argument<Boolean>("enable")
                if(enable!!) {
                    Thread { EthernetUtil.open() }.start()
                } else {
                    Thread { EthernetUtil.close() }.start()
                }
                onCallSuccess(result, HybridResult.SUCCESS)
            }
            "connectWiFi" -> {
                assert(call.hasArgument("ssid"))// wifi名
                assert(call.hasArgument("pwd"))// wifi密码
                assert(call.hasArgument("changePwd")) //是否改变密码
                assert(wifiList?.get(call.argument<String>("ssid")) != null)
                WiFiConnectHandler.connect(
                    context,
                    wifiList!![call.argument<String>("ssid")]!!,
                    call.argument<String>("pwd")?:"",call.argument<Boolean>("changePwd")?:false ,
                    object : IConnectedCallback{
                        override fun invalidConnect(pwd: String?, scanResult: ScanResult?) {
                            onCallSuccess(result, false)
                        }

                        override fun validConnected(scanResult: ScanResult?) {
                            onCallSuccess(result, true)
                        }
                    })
                onCallSuccess(result, HybridResult.SUCCESS)
            }
            else -> {
                onCallNotImplement(result)
            }
        }
    }

    fun onReplyNearbyWiFi(list: Collection<ScanResult>) {
        MainThread.run {
            mMethodChannel?.invokeMethod(
                "replyNearbyWiFi",
                scanResultListToJsonArray(list)
            )
        }
    }

    fun resultJson(code: Int, message: String, jsonObject: JSONObject?) : JSONObject{
        val result = JSONObject()
        result.put("code", code)
        result.put("message", message)
        result.put("data", jsonObject)
        return result
    }

    override fun call(result: List<ScanResult>) {
        wifiList = wifiList ?: hashMapOf()
        if(CollectionUtil.isNotEmpty(result)) {
            for (scanResult in result) {
                wifiList?.put(scanResult.SSID, scanResult)
            }
        }
        LogUtil.tag("NET").msg("扫描到的WiFi数量：${result.size}")
        onReplyNearbyWiFi(result)
    }


    private fun scanResultListToJsonArray(list: Collection<ScanResult>): JSONArray {
        if (CollectionUtil.isEmpty(list)) {
            return JSONArray();
        }

        val array = JSONArray()
        list.forEach { item ->
            val json = scanResultToJsonObject(item)
            array.put(json)
        }

        return array

    }


    private fun scanResultToJsonObject(scanResult: ScanResult): JSONObject {
        val json = JSONObject()
        json.put("ssid", scanResult.SSID)
        json.put("bssid", scanResult.BSSID)
        json.put("auth", authType(scanResult))
        json.put("level", calculateSignalLevel(scanResult.level, 4))
        return json
    }

    private fun connectedStateToJsonObject(ethernet: Int, wifi: Int, wifiInfo: WifiInfo?): JSONObject {
        val json = JSONObject()
        val scanJson = JSONObject()

        json.put("ethernetState", ethernet)
        json.put("wifiState", wifi)
        json.put("wifiInfo", scanJson)
        wifiInfo?.apply {
            scanJson.put("ssid", this.ssid.replace("\"", ""))
            scanJson.put("bssid", this.bssid)
            scanJson.put("auth", "encryption")
            scanJson.put("level", calculateSignalLevel(this.rssi, 4))
        }
        return json
    }

    private fun calculateSignalLevel(rssi: Int, numLevels: Int): Int {
        return if (rssi <= MIN_RSSI) {
            0
        } else if (rssi >= MAX_RSSI) {
            numLevels - 1
        } else {
            val inputRange: Float = (MAX_RSSI - MIN_RSSI).toFloat()
            val outputRange = (numLevels - 1).toFloat()
            ((rssi - MIN_RSSI).toFloat() * outputRange / inputRange).toInt()
        }
    }

    private fun authType(scanResult: ScanResult) : String {
        val security = ConfigurationSecurities.newInstance().getScanResultSecurity(scanResult)
        return if (Version.SDK < 8) {
            if (security.equals("Open")) "open" else "encryption"
        } else {
            if (security.equals("0")) "open" else "encryption"
        }
    }

    override fun connectedState(ethernet: Int, wifi: Int, wifiInfo: WifiInfo?) {
        LogUtil.tag("NET").msg("以太网连接状态 = $ethernet wifi连接状态 = $wifi" )
        MainThread.run {
            mMethodChannel?.invokeMethod(
                "replyConnectChange",
                connectedStateToJsonObject(ethernet, wifi, wifiInfo)
            )
        }
    }


}