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
import com.midea.light.device.explore.beans.ZigbeeScanResult
import com.midea.light.device.explore.config.BaseConfig
import com.midea.light.utils.GsonUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class ManagerDeviceChannel(context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create( channelName: String, binaryMessenger: BinaryMessenger, context: Context): ManagerDeviceChannel {
            val channel = ManagerDeviceChannel(context)
            channel.setup(binaryMessenger, channelName)
            return channel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        when(method) {
            "init" -> {
                val host = requireNotNull(call.argument<String?>("host"))
                val token = requireNotNull(call.argument<String?>("token"))
                val httpSign = requireNotNull(call.argument<String?>("httpSign"))
                val seed = requireNotNull(call.argument<String?>("seed"))
                val key = requireNotNull(call.argument<String?>("seed"))
                val deviceId = requireNotNull(call.argument<String?>("deviceId"))
                val userId = requireNotNull(call.argument<String?>("userId"))
                val iotAppCount = requireNotNull(call.argument<String?>("iotAppCount"))
                val iotSecret = requireNotNull(call.argument<String?>("iotSecret"))
                val httpHeaderDataKey = requireNotNull(call.argument<String?>("httpHeaderDataKey"))
                init(host, token, httpSign, seed, key, deviceId, userId, iotAppCount, iotSecret, httpHeaderDataKey)
            }
            "reset" -> { reset() }
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
        }
    }

    var serverMessenger: Messenger? = null
    var clientMessenger: Messenger? = null
    var serviceConnection: ServiceConnection? =null
    var isConnectedService = false
    var isInit = false

    var zigbeeDevices: MutableList<ZigbeeScanResult> = mutableListOf()

    val receiveDataFromServer = @SuppressLint("HandlerLeak")
    object : Handler() {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            msg.data?.run {
                val actionType = requireNotNull(this.getString(Portal.ACTION_TYPE))
                val methodType = requireNotNull(this.getString(Portal.METHOD_TYPE))
                when(actionType) {
                    Portal.REQUEST_BIND_ZIGBEE_DEVICES -> {
                        zigbeeBindMethodHandle(methodType, this)
                    }
                    Portal.REQUEST_MODIFY_DEVICE_ROOM -> {
                        modifyDeviceHandler(methodType, this)
                    }
                    Portal.RESULT_SCAN_ZIGBEE_DEVICES -> {
                        findZigbeeHandle(methodType, this)
                    }
                }
            }
        }
    }

    private fun findZigbeeHandle(methodType: String, bundle: Bundle) {
        if(methodType == Portal.METHOD_SCAN_ZIGBEE_START) {
            val devices = bundle.getParcelableArrayList<ZigbeeScanResult>(Portal.RESULT_SCAN_ZIGBEE_DEVICES)
            if(devices?.isNotEmpty() == true) {
                zigbeeDevices.addAll(devices)
                val json = GsonUtils.stringify(devices)
                val jsonArray = JSONArray(json)
                mMethodChannel.invokeMethod("findZigbeeResult", jsonArray)
            }
        }
    }

    private fun modifyDeviceHandler(methodType: String, bundle: Bundle) {
        if(methodType == Portal.METHOD_MODIFY_DEVICE) {
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
        when(method) {
            Portal.METHOD_BIND_ZIGBEE -> {
                val bindResult: BindResult = requireNotNull(data.getParcelable(Portal.RESULT_BIND_ZIGBEE_DEVICES))
                val json = JSONObject()
                json.put("code", bindResult.code) // 0成功 -1失败
                json.put("message", bindResult.message) // 如果失败会有报错的原因，此字段用处不大
                json.put("waitDeviceBind", bindResult.waitDeviceBind) // 剩下多少设备需要绑定
                json.put("findInfo", JSONObjectUtils.objectToJson(bindResult.deviceInfo as ZigbeeScanResult))
                if(bindResult.code == 0) {
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
        if(isInit) return

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
        if(!isInit) return
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
        zigbeeDevices.clear()
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
                            applianceCodes.find { code->
                                code.equals(zigbeeScanResult.device.applianceCode) } != null
                        }
                        .toTypedArray()

        if(devices.isNotEmpty()) {
            val message = Message()
            val data = Bundle()
            data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_ZIGBEE_DEVICES)
            data.putString(Portal.METHOD_TYPE, Portal.METHOD_BIND_ZIGBEE)
            data.putParcelableArray(Portal.PARAM_BIND_PARAMETER, devices)
            data.putString(Portal.PARAM_BIND_ZIGBEE_HOME_GROUP_ID, homeGroupId)
            data.putString(Portal.PARAM_BIND_ZIGBEE_HOME_ROOM_ID, roomId)
            message.data = data
            message.replyTo = clientMessenger
            serverMessenger?.send(message)
            zigbeeDevices.removeIf { zigbeeScanResult ->
                applianceCodes.find { code->
                    code.equals(zigbeeScanResult.device.applianceCode) } != null
            }
        }
    }

    private fun stopBindZigbee() {
        val message = Message()
        message.data = Bundle()
        message.data.putString(Portal.ACTION_TYPE, Portal.REQUEST_BIND_ZIGBEE_DEVICES)
        message.data.putString(Portal.METHOD_TYPE, Portal.METHOD_STOP_ZIGBEE_BIND)
        serverMessenger?.send(message)
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


}