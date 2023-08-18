import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.*
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.common.utils.JSONArrayUtils
import com.midea.light.common.utils.JSONObjectUtils
import com.midea.light.device.explore.DevicesExploreService
import com.midea.light.device.explore.Portal
import com.midea.light.device.explore.api.entity.ApplianceBean
import com.midea.light.device.explore.beans.BindResult
import com.midea.light.device.explore.beans.WiFiScanResult
import com.midea.light.device.explore.beans.ZigbeeScanResult
import com.midea.light.device.explore.config.BaseConfig
import com.midea.light.device.explore.controller.control485.controller.AirConditionController
import com.midea.light.device.explore.controller.control485.controller.FloorHotController
import com.midea.light.device.explore.controller.control485.controller.FreshAirController
import com.midea.light.issued.plc.PLCControlEvent
import com.midea.light.log.LogUtil
import com.midea.light.utils.CollectionUtil
import com.midea.light.utils.GsonUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class ManagerDeviceChannel(context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(channelName: String, binaryMessenger: BinaryMessenger, context: Context): ManagerDeviceChannel {
            val channel = ManagerDeviceChannel(context)
            channel.setup(binaryMessenger, channelName)
            return channel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        when (method) {
            "updateToken" -> {
                val token = requireNotNull(call.argument<String>("token"))
                updateToken(token)
            }
            "init" -> {
                val host = requireNotNull(call.argument<String?>("host"))
                val token = requireNotNull(call.argument<String?>("token"))
                val httpSign = requireNotNull(call.argument<String?>("httpSign"))
                val seed = requireNotNull(call.argument<String?>("seed"))
                val key = requireNotNull(call.argument<String?>("key"))
                val deviceId = requireNotNull(call.argument<String?>("deviceId"))
                val userId = requireNotNull(call.argument<String?>("userId"))
                val iotAppCount = requireNotNull(call.argument<String?>("iotAppCount"))
                val iotSecret = requireNotNull(call.argument<String?>("iotSecret"))
                val httpHeaderDataKey = requireNotNull(call.argument<String?>("httpHeaderDataKey"))
                init(host, token, httpSign, seed, key, deviceId, userId, iotAppCount, iotSecret, httpHeaderDataKey)
            }
            "reset" -> {
                reset()
            }
            "findZigbee" -> {
                assert(isInit)
                val homeGroupId = requireNotNull(call.argument<String?>("homeGroupId"))
                val gatewayApplianceCode = requireNotNull(call.argument<String?>("gatewayApplianceCode"))
                findZigbee(homeGroupId, gatewayApplianceCode)
            }
            "stopFindZigbee" -> {
                assert(isInit)
                val gatewayApplianceCode = requireNotNull(call.argument<String?>("gatewayApplianceCode"))
                val homeGroupId = requireNotNull(call.argument<String?>("homeGroupId"))
                stopFindZigbee(gatewayApplianceCode, homeGroupId)
            }
            "bindZigbee" -> {
                assert(isInit)
                val homeGroupId = requireNotNull(call.argument<String?>("homeGroupId"))
                val roomId = requireNotNull(call.argument<String?>("roomId"))
                val codes = JSONArrayUtils.toStringArray(requireNotNull(call.argument<JSONArray?>("applianceCodes")))
                bindZigbee(homeGroupId, roomId, codes.toList())
            }
            "stopBindZigbee" -> {
                assert(isInit)
                stopBindZigbee()
            }
            "modifyDevicePosition" -> {
                assert(isInit)
                val homeGroupId = requireNotNull(call.argument<String?>("homeGroupId"))
                val roomId = requireNotNull(call.argument<String?>("roomId"))
                val applianceCode = requireNotNull(call.argument<String?>("applianceCode"))
                modifyDevicePosition(homeGroupId, roomId, applianceCode)
            }
            "findWiFi" -> {
                assert(isInit)
                findWifi()
            }
            "stopFindWiFi" -> {
                assert(isInit)
                stopWifi()
            }
            "bindWiFi" -> {
                assert(isInit)
                val homeGroupId = requireNotNull(call.argument<String?>("homeGroupId"))
                val roomId = requireNotNull(call.argument<String?>("roomId"))
                val wifiBssId = requireNotNull(call.argument<String?>("wifiBssid"))
                val wifiSsid = requireNotNull(call.argument<String?>("wifiSsid"))
                val wifiPassword = requireNotNull(call.argument<String?>("wifiPassword"))
                val encrypt = requireNotNull(call.argument<String?>("wifiEncrypt"))

                val devices = JSONArrayUtils.toJsonArray(requireNotNull(call.argument<JSONArray?>("devices")))
                val scanResults = mutableListOf<WiFiScanResult>()
                devices.forEach { wifi ->
                    val ssid = wifi.get("ssid")
                    val bssid = wifi.get("bssid")
                    val scanResult = requireNotNull(wifiDevices.find { it.scanResult.SSID == ssid && it.scanResult.BSSID == bssid })
                    scanResults.add(scanResult)
                }

                if (CollectionUtil.isEmpty(scanResults)) {
                    throw java.lang.RuntimeException("请指定需要绑定的wifi设备")
                }

                bindWifi(homeGroupId, roomId, wifiBssId, wifiSsid, wifiPassword, encrypt, scanResults)
            }
            "stopBindWiFi" -> {
                assert(isInit)
                stopBindWifi()
            }
            "autoFindWiFi" -> {
                assert(isInit)
                autoFindWiFi()
            }
        }
    }

    var serverMessenger: Messenger? = null
    var clientMessenger: Messenger? = null
    var serviceConnection: ServiceConnection? = null
    var isConnectedService = false
    var isInit = false

    var zigbeeDevices: MutableSet<ZigbeeScanResult> = mutableSetOf()
    var wifiDevices: MutableSet<WiFiScanResult> = mutableSetOf()

    val receiveDataFromServer = @SuppressLint("HandlerLeak")
    object : Handler() {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            msg.data?.run {
                LogUtil.tag("device_zigbee_wifi").bundle(this)
                val actionType = requireNotNull(this.getString(Portal.ACTION_TYPE))
                val methodType = requireNotNull(this.getString(Portal.METHOD_TYPE))
                when (actionType) {
                    Portal.REQUEST_BIND_ZIGBEE_DEVICES -> {
                        zigbeeBindMethodHandle(methodType, this)
                    }
                    Portal.REQUEST_MODIFY_DEVICE_ROOM -> {
                        modifyDeviceHandler(methodType, this)
                    }
                    Portal.REQUEST_SCAN_ZIGBEE_DEVICES -> {
                        findZigbeeHandle(methodType, this)
                    }
                    Portal.REQUEST_SCAN_WIFI_DEVICES -> {
                        findWifiHandle(methodType, this)
                    }
                    Portal.REQUEST_BIND_WIFI_DEVICES -> {
                        wifiBindMethodHandle(methodType, this)
                    }
                }
            }
        }
    }

    private fun updateToken(token: String) {
        Portal.updateToken(token)
    }

    private fun findZigbeeHandle(methodType: String, bundle: Bundle) {
        if (methodType == Portal.METHOD_SCAN_ZIGBEE_START) {
            val devices = bundle.getParcelableArrayList<ZigbeeScanResult>(Portal.RESULT_SCAN_ZIGBEE_DEVICES)
            LogUtil.tag("device_zigbee_wifi").array(devices)
            if (devices?.isNotEmpty() == true) {
                zigbeeDevices.addAll(devices)
                val json = GsonUtils.stringify(devices)
                val jsonArray = JSONArray(json)
                mMethodChannel.invokeMethod("findZigbeeResult", jsonArray)
            }
        }
    }

    private fun modifyDeviceHandler(methodType: String, bundle: Bundle) {
        if (methodType == Portal.METHOD_MODIFY_DEVICE) {
            val suc = requireNotNull(bundle.getInt(Portal.RESULT_MODIFY_DEVICE)) == 0
            //val applianceBean: ApplianceBean? = bundle.getParcelable(Portal.RESULT_MODIFY_DEVICE_DATA)
            val jsonObject = JSONObject()
            jsonObject.put("suc", suc)
            jsonObject.put("homeGroupId", bundle.getString(Portal.PARAM_MODIFY_DEVICE_HOME_ID))
            jsonObject.put("roomId", bundle.getString(Portal.PARAM_MODIFY_DEVICE_ROOM_ID))
            jsonObject.put("applianceCode", bundle.getString(Portal.PARAM_MODIFY_DEVICE_APPLIANCE_CODE))
            //applianceBean?.run { jsonObject.put("data", JSONObjectUtils.objectToJson(applianceBean))  }
            mMethodChannel.invokeMethod("modifyDeviceResult", jsonObject)
        }
    }

    fun zigbeeBindMethodHandle(method: String, data: Bundle) {
        when (method) {
            Portal.METHOD_BIND_ZIGBEE -> {
                val bindResult: BindResult = requireNotNull(data.getParcelable(Portal.RESULT_BIND_ZIGBEE_DEVICES))
                val json = JSONObject()
                json.put("code", bindResult.code) // 0成功 -1失败
                json.put("message", bindResult.message) // 如果失败会有报错的原因，此字段用处不大
                json.put("waitDeviceBind", bindResult.waitDeviceBind) // 剩下多少设备需要绑定
                json.put("findResult", JSONObjectUtils.objectToJson(bindResult.deviceInfo as ZigbeeScanResult))
                if (bindResult.code == 0) {
                    json.put("bindInfo", JSONObjectUtils.objectToJson(bindResult.bindResult as ApplianceBean))
                }
                mMethodChannel.invokeMethod("zigbeeBindResult", json)
            }
            Portal.METHOD_STOP_ZIGBEE_BIND -> {}
        }
    }


    // 初始化
    fun init(host: String, token: String, httpSign: String,
             seed: String, key: String, deviceId: String, userId: String,
             iotAppCount: String, iotSecret: String, httpHeaderDataKey: String) {
        if (isInit) return

        val baseConfig = BaseConfig(host, token, httpSign, seed, key, deviceId, userId, iotAppCount, iotSecret, httpHeaderDataKey)
        Portal.initBaseConfig(baseConfig)

        context.bindService(
                Intent(context, DevicesExploreService::class.java),
                object : ServiceConnection {
                    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                        serverMessenger = Messenger(service)
                        clientMessenger = Messenger(receiveDataFromServer)
                        serviceConnection = this
                        isConnectedService = true
                    }

                    override fun onServiceDisconnected(name: ComponentName?) {
                        isConnectedService = false
                    }
                },
                Context.BIND_AUTO_CREATE
        )

        isInit = true
    }

    // 重置
    fun reset() {
        if (!isInit) return
        Portal.resetBaseConfig()
        serviceConnection?.run { context.unbindService(this) }
        isInit = false
    }


    // 1.zigbee设备扫描
    fun findZigbee(homeGroupId: String, gatewayApplianceCode: String) {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_SCAN_ZIGBEE_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_SCAN_ZIGBEE_START)
        data.putString(Portal.PARAM_SCAN_HOME_GROUP_ID, homeGroupId)
        data.putString(Portal.PARAM_GATEWAY_APPLIANCE_CODE, gatewayApplianceCode)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    fun stopFindZigbee(gatewayApplianceCode: String, homeGroupId: String) {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_SCAN_ZIGBEE_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_SCAN_ZIGBEE_STOP)
        data.putString(Portal.PARAM_GATEWAY_APPLIANCE_CODE, gatewayApplianceCode)
        data.putString(Portal.PARAM_SCAN_HOME_GROUP_ID, homeGroupId)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    // 2.zigbee设备绑定
    private fun bindZigbee(homeGroupId: String, roomId: String?, applianceCodes: List<String>) {
        val devices = zigbeeDevices
                .filter { zigbeeScanResult ->
                    applianceCodes.find { code ->
                        code.equals(zigbeeScanResult.device.applianceCode)
                    } != null
                }
                .toTypedArray()

        if (devices.isNotEmpty()) {
            val message = Message()
            val data = Bundle()
            data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_ZIGBEE_DEVICES)
            data.putString(Portal.METHOD_TYPE, Portal.METHOD_BIND_ZIGBEE)
            data.putParcelableArray(Portal.PARAM_BIND_ZIGBEE_PARAMETER, devices)
            data.putString(Portal.PARAM_BIND_ZIGBEE_HOME_GROUP_ID, homeGroupId)
            data.putString(Portal.PARAM_BIND_ZIGBEE_HOME_ROOM_ID, roomId)
            message.data = data
            message.replyTo = clientMessenger
            serverMessenger?.send(message)
            zigbeeDevices.removeIf { zigbeeScanResult ->
                applianceCodes.find { code ->
                    code.equals(zigbeeScanResult.device.applianceCode)
                } != null
            }
        }
    }

    private fun stopBindZigbee() {
        val message = Message()
        message.data = Bundle()
        message.data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_ZIGBEE_DEVICES)
        message.data.putString(Portal.METHOD_TYPE, Portal.METHOD_STOP_ZIGBEE_BIND)
        serverMessenger?.send(message)
        zigbeeDevices.clear()
    }

    // 3.修改房间
    private fun modifyDevicePosition(homeGroupId: String, roomId: String, applianceCode: String) {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_MODIFY_DEVICE_ROOM)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_MODIFY_DEVICE)
        data.putString(Portal.PARAM_MODIFY_DEVICE_APPLIANCE_CODE, applianceCode)
        data.putString(Portal.PARAM_MODIFY_DEVICE_HOME_ID, homeGroupId)
        data.putString(Portal.PARAM_MODIFY_DEVICE_ROOM_ID, roomId)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }


    // 4. wifi设备扫描
    private fun findWifi() {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_SCAN_WIFI_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_SCAN_WIFI_START)
        data.putBoolean(Portal.PARAM_SCAN_WIFI_LOOPER, true)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    private fun stopWifi() {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_SCAN_WIFI_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_SCAN_WIFI_STOP)
        data.putBoolean(Portal.PARAM_SCAN_WIFI_LOOPER, true)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    // 5. 绑定wifi设备
    private fun bindWifi(
            homeGroupId: String,
            roomId: String,
            wifiBssId: String,
            wifiName: String,
            wifiPassword: String,
            encrypt: String,
            scanResults: MutableList<WiFiScanResult>
    ) {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_WIFI_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_BIND_WIFI)
        data.putString(Portal.PARAM_BIND_WIFI_HOME_GROUP_ID, homeGroupId)
        data.putString(Portal.PARAM_BIND_WIFI_HOME_ROOM_ID, roomId)
        data.putString(Portal.PARAM_WIFI_NAME, wifiName)
        data.putString(Portal.PARAM_WIFI_PASSWORD, wifiPassword)
        data.putString(Portal.PARAM_WIFI_ENCRYPT_TYPE, encrypt)
        data.putString(Portal.PARAM_WIFI_BSSID, wifiBssId)
        data.putParcelableArray(Portal.PARAM_WIFI_BIND_PARAMETER, scanResults.toTypedArray())
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    private fun stopBindWifi() {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_WIFI_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_STOP_WIFI_BIND)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
        wifiDevices.clear()
    }

    // 6. 发现wifi设备结果
    private fun findWifiHandle(methodType: String, bundle: Bundle) {
        if (methodType == Portal.METHOD_SCAN_WIFI_START) {
            val result = bundle.getParcelableArrayList<WiFiScanResult>(Portal.RESULT_SCAN_WIFI_DEVICES)
            if (CollectionUtil.isNotEmpty(result)) {
                wifiDevices.addAll(result!!)
                val jsonArray = JSONArray()
                result.forEach { wiFiScanResult ->
                    jsonArray.put(covertWiFiScanResultToFlutterType(wiFiScanResult))
                }
                mMethodChannel.invokeMethod("findWiFiResult", jsonArray)
            }
        }
    }

    // 7. 绑定wifi设备结果
    private fun wifiBindMethodHandle(methodType: String, data: Bundle) {
        LogUtil.tag("BindDeviceController").bundle(data)
        if (methodType == Portal.METHOD_BIND_WIFI) {
            val bindResult: BindResult = requireNotNull(data.getParcelable(Portal.RESULT_BIND_WIFI_DEVICES))
            val json = JSONObject()
            json.put("code", bindResult.code) // 0成功 -1失败
            json.put("message", bindResult.message) // 如果失败会有报错的原因，此字段用处不大
            json.put("waitDeviceBind", bindResult.waitDeviceBind) // 剩下多少设备需要绑定
            json.put("findResult", (covertWiFiScanResultToFlutterType(bindResult.deviceInfo as WiFiScanResult)))
            if (bindResult.code == 0) {
                json.put("bindInfo", JSONObjectUtils.objectToJson(bindResult.bindResult as ApplianceBean))
            }
            mMethodChannel.invokeMethod("wifiBindResult", json)
        }
    }

    //8. 自动扫描WiFi设备
    private fun autoFindWiFi() {
        val message = Message()
        val data = Bundle()
        data.putString(Portal.ACTION_TYPE, Portal.REQUEST_SCAN_WIFI_DEVICES)
        data.putString(Portal.METHOD_TYPE, Portal.METHOD_SCAN_WIFI_START)
        data.putBoolean(Portal.PARAM_AUTO_SCAN_WIFI_LOOPER, true)
        message.data = data
        message.replyTo = clientMessenger
        serverMessenger?.send(message)
    }

    // WiFiScanResult -> Convert (用于转换数据类型到Flutter上去)
    private fun covertWiFiScanResultToFlutterType(wiFiScanResult: WiFiScanResult): JSONObject {
        val jsonObject = JSONObject()
        jsonObject.put("icon", wiFiScanResult.icon)
        jsonObject.put("name", wiFiScanResult.name)
        val infoJsonObject = JSONObject()
        infoJsonObject.put("ssid", wiFiScanResult.scanResult.SSID)
        infoJsonObject.put("bssid", wiFiScanResult.scanResult.BSSID)
        infoJsonObject.put("auth", "encryption")// 默认参数：需要传密钥
        infoJsonObject.put("level", 3)// 默认参数：信号强度最高
        infoJsonObject.put("alreadyConnected", false)
        jsonObject.put("info", infoJsonObject)
        return jsonObject
    }

}