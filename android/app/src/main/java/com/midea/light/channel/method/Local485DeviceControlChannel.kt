import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.midea.light.RxBus
import com.midea.light.bean.Add485DeviceBean.PLC.AddDev
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.device.explore.controller.control485.controller.AirConditionController
import com.midea.light.device.explore.controller.control485.controller.FloorHotController
import com.midea.light.device.explore.controller.control485.controller.FreshAirController
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent
import com.midea.light.gateway.GateWayUtils
import com.midea.light.setting.SystemUtil
import com.midea.light.utils.GsonUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class Local485DeviceControlChannel(context: Context) : AbsMZMethodChannel(context) {

    lateinit var cMethodChannel: MethodChannel

    companion object {
        fun create(
            channelName: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): Local485DeviceControlChannel {
            val channel = Local485DeviceControlChannel(context)
            channel.setup(binaryMessenger, channelName)
            return channel
        }
    }

    override fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        super.setup(binaryMessenger, channel)
        cMethodChannel = mMethodChannel
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        when (method) {
            "find485Device" -> {
                Log.e("sky", "查找本地485设备")
                find485Device(result)
            }
            "get485DeviceStateByAddr" -> {
                Log.e("sky", "查询485设备状态")
                var addr = requireNotNull(call.argument<String?>("addr"))
                for (i in AirConditionController.getInstance().AirConditionList.indices) {
                    val deviceAddr =
                        AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
                    if (deviceAddr == addr) {
                        RxBus.getInstance().post(AirConditionChangeEvent().setAirConditionModel(AirConditionController.getInstance().AirConditionList[i]))
                    }
                }
                for (i in FreshAirController.getInstance().FreshAirList.indices) {
                    val deviceAddr =
                        FreshAirController.getInstance().FreshAirList[i].outSideAddress + FreshAirController.getInstance().FreshAirList[i].inSideAddress
                    if (deviceAddr == addr) {
                        RxBus.getInstance().post(FreshAirChangeEvent().setFreshAirModel(FreshAirController.getInstance().FreshAirList[i]))
                    }
                }
                for (i in FloorHotController.getInstance().FloorHotList.indices) {
                    val deviceAddr =
                        FloorHotController.getInstance().FloorHotList[i].outSideAddress + FloorHotController.getInstance().FloorHotList[i].inSideAddress
                    if (deviceAddr == addr) {
                        RxBus.getInstance().post(FloorHotChangeEvent().setFloorHotModel(FloorHotController.getInstance().FloorHotList[i]))
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirConditionPower" -> {
                Log.e("sky", "本地485空调开关控制")
                var power = requireNotNull(call.argument<String?>("power"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + power)
                for (i in AirConditionController.getInstance().AirConditionList.indices) {
                    val deviceAddr =
                        AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        if (power == "0") {
                            Log.e("sky", "控制关")
                            AirConditionController.getInstance()
                                .close(AirConditionController.getInstance().AirConditionList[i])
                        } else {
                            Log.e("sky", "控制开")
                            AirConditionController.getInstance()
                                .open(AirConditionController.getInstance().AirConditionList[i])
                        }
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirConditionTemper" -> {
                Log.e("sky", "本地485空调温度控制")
                var temp = requireNotNull(call.argument<String?>("temper"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + temp)
                for (i in AirConditionController.getInstance().AirConditionList.indices) {
                    val deviceAddr =
                        AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        AirConditionController.getInstance().setTemp(
                            AirConditionController.getInstance().AirConditionList[i],
                            Integer.toHexString(Integer.parseInt(temp))
                        )
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirConditionWindSpeed" -> {
                Log.e("sky", "本地485空调风速控制")
                var windSpeed = requireNotNull(call.argument<String?>("windSpeed"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + windSpeed)
                for (i in AirConditionController.getInstance().AirConditionList.indices) {
                    val deviceAddr =
                        AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        AirConditionController.getInstance().setWindSpeedLevl(
                            AirConditionController.getInstance().AirConditionList[i],
                            Integer.toHexString(Integer.parseInt(windSpeed))
                        )
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirConditionModel" -> {
                Log.e("sky", "本地485空调模式控制")
                var model = requireNotNull(call.argument<String?>("model"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + model)
                for (i in AirConditionController.getInstance().AirConditionList.indices) {
                    val deviceAddr =
                        AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        AirConditionController.getInstance().setModel(
                            AirConditionController.getInstance().AirConditionList[i],
                            Integer.toHexString(Integer.parseInt(model))
                        )
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirFreshPower" -> {
                Log.e("sky", "本地485新风开关控制")
                var power = requireNotNull(call.argument<String?>("power"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + power)
                for (i in FreshAirController.getInstance().FreshAirList.indices) {
                    val deviceAddr =
                        FreshAirController.getInstance().FreshAirList[i].outSideAddress + FreshAirController.getInstance().FreshAirList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        if (power == "0") {
                            Log.e("sky", "控制关")
                            FreshAirController.getInstance()
                                .close(FreshAirController.getInstance().FreshAirList[i])
                        } else {
                            Log.e("sky", "控制开")
                            FreshAirController.getInstance()
                                .open(FreshAirController.getInstance().FreshAirList[i])
                        }
                    }
                }
                result.success(true)
            }
            "ControlLocal485AirFreshWindSpeed" -> {
                Log.e("sky", "本地485新风风速控制")
                var windSpeed = requireNotNull(call.argument<String?>("windSpeed"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + windSpeed)
                for (i in FreshAirController.getInstance().FreshAirList.indices) {
                    val deviceAddr =
                        FreshAirController.getInstance().FreshAirList[i].outSideAddress + FreshAirController.getInstance().FreshAirList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        FreshAirController.getInstance().setWindSpeedLevl(
                            FreshAirController.getInstance().FreshAirList[i],
                            Integer.toHexString(Integer.parseInt(windSpeed))
                        )
                    }
                }
                result.success(true)
            }
            "ControlLocal485FloorHeatPower" -> {
                Log.e("sky", "本地485地暖开关控制")
                var power = requireNotNull(call.argument<String?>("power"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + power)
                for (i in FloorHotController.getInstance().FloorHotList.indices) {
                    val deviceAddr =
                        FloorHotController.getInstance().FloorHotList[i].outSideAddress + FloorHotController.getInstance().FloorHotList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")
                        if (power == "0") {
                            Log.e("sky", "控制关")
                            FloorHotController.getInstance()
                                .close(FloorHotController.getInstance().FloorHotList[i])
                        } else {
                            Log.e("sky", "控制开")
                            FloorHotController.getInstance()
                                .open(FloorHotController.getInstance().FloorHotList[i])
                        }
                    }
                }
                result.success(true)
            }
            "ControlLocal485FloorHeatTemper" -> {
                Log.e("sky", "本地485地暖温度控制")
                var temp = requireNotNull(call.argument<String?>("temper"))
                var addr = requireNotNull(call.argument<String?>("addr"))
                Log.e("sky", "控制地址:" + addr + "---控制内容:" + temp)
                for (i in FloorHotController.getInstance().FloorHotList.indices) {
                    val deviceAddr =
                        FloorHotController.getInstance().FloorHotList[i].outSideAddress + FloorHotController.getInstance().FloorHotList[i].inSideAddress
                    if (deviceAddr == addr) {
                        Log.e("sky", "找到了要控制的设备")

                        FloorHotController.getInstance().setTemp(
                            FloorHotController.getInstance().FloorHotList[i],
                            Integer.toHexString(Integer.parseInt(temp))
                        )
                    }
                }
                result.success(true)
            }
            "send485DeviceList" -> {
                var list = requireNotNull(call.argument<JSONArray>("485DeviceList"))
                device485ListToGatWay(list)
            }

        }
    }

    private fun find485Device(result: MethodChannel.Result) {
        val jsonObject = JSONObject()
        jsonObject.put("AirConditionList", AirConditionController.getInstance().AirConditionList)
        jsonObject.put("FreshAirList", FreshAirController.getInstance().FreshAirList)
        jsonObject.put("FloorHotList", FloorHotController.getInstance().FloorHotList)
        result.success(GsonUtils.stringify(jsonObject))
    }

    private fun device485ListToGatWay(list: JSONArray) {
        Log.e("sky", "接收到网关配网状态,空调设备数量:" + AirConditionController.getInstance().AirConditionList.size)
        Log.e("sky", "接收到网关配网状态,新风设备数量:" + FreshAirController.getInstance().FreshAirList.size)
        Log.e("sky", "接收到网关配网状态,地暖设备数量:" + FloorHotController.getInstance().FloorHotList.size)
        val AddDevList = ArrayList<AddDev>()
        for (i in AirConditionController.getInstance().AirConditionList.indices) {
            val AddDev = AddDev()
            AddDev.addr =
                AirConditionController.getInstance().AirConditionList[i].outSideAddress + AirConditionController.getInstance().AirConditionList[i].inSideAddress
            AddDev.modelId = "zhonghong.cac.002"
            AddDevList.add(AddDev)
        }
        for (i in FreshAirController.getInstance().FreshAirList.indices) {
            val AddDev = AddDev()
            AddDev.addr =
                FreshAirController.getInstance().FreshAirList[i].outSideAddress + FreshAirController.getInstance().FreshAirList[i].inSideAddress
            AddDev.modelId = "zhonghong.air.001"
            AddDevList.add(AddDev)
        }
        for (i in FloorHotController.getInstance().FloorHotList.indices) {
            val AddDev = AddDev()
            AddDev.addr =
                FloorHotController.getInstance().FloorHotList[i].outSideAddress + FloorHotController.getInstance().FloorHotList[i].inSideAddress
            AddDev.modelId = "zhonghong.heat.001"
            AddDevList.add(AddDev)
        }
        val noNeedDevList = ArrayList<AddDev>()
        val nodeIdList = java.util.ArrayList<String>()
        for (i in 0 until list.length()) {
            nodeIdList.add(list.getString(i))
        }
//        Log.e("sky", "已经有的的设备列表:${Gson().toJson(nodeIdList)}")
        val mac=SystemUtil.getMacAddress().replace(":","").uppercase()
//        Log.e("sky", "本机mac:$mac")
        for (dev in AddDevList) {
            for (nodeId in nodeIdList) {
                if (nodeId.split("-")[0] == mac&&nodeId.split("-")[1]==dev.addr) {
                    noNeedDevList.add(dev)
                }
            }
        }
//        Log.e("sky", "需要删除的设备列表:${Gson().toJson(noNeedDevList)}")
        AddDevList.removeAll(noNeedDevList.toSet())
        Log.e("sky", "给网关的设备列表:${Gson().toJson(AddDevList)}")
        GateWayUtils.add485(AddDevList)
    }

}