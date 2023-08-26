package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.homeos.HomeOsClient
import com.midea.light.homeos.HomeOsController
import com.midea.light.log.LogUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

// 局域网设备控制Channel通道
class LanDeviceControlChannel(override val context: Context): AbsMZMethodChannel(context) , HomeOsController.ICallback {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): LanDeviceControlChannel {
            val methodChannel = LanDeviceControlChannel(context)
            methodChannel.setup(binaryMessenger, channel);
            return methodChannel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val methodName = call.method
        when(methodName) {
            "init" -> {
                HomeOsClient.getOsController().init()
            }
            "login" -> {
                val homeId = call.argument<String?>("homeId")
                val key = call.argument<String?>("key")
                if(homeId != null && key != null) {
                    HomeOsClient.getOsController().login(homeId, key)
                }
                HomeOsClient.getOsController().setCallback(this)
            }
            "logout" -> {
                HomeOsClient.getOsController().logout()
                HomeOsClient.getOsController().setCallback(null)
            }
            "getDeviceInfo" -> {
                if(HomeOsClient.getOsController().deviceList != 0) {
                    LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                }
            }
            "getDeviceStatus" -> {
                val deviceId = call.argument<String?>("deviceId")
                if (HomeOsClient.getOsController().getDeviceStatus(deviceId) != 0) {
                    LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                }
            }
            "deviceControl" -> {
                val action = call.argument<Map<String, Any>?>("action")
                val deviceId = call.argument<String?>("deviceId")
                if(deviceId != null && action != null) {
                    if (HomeOsClient.getOsController().deviceControl(deviceId,
                            JSONObject.wrap(action)?.toString() ?: "") != 0) {
                        LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("传入的DeviceId为空")
                }
            }
            "getGroupInfo" -> {
                if(HomeOsClient.getOsController().groupInfo != 0) {
                    LogUtil.tag("homeOs").msg("请求getGroupInfo失败")
                }
            }
            "groupControl" -> {
                val action = call.argument<Map<String, Any>?>("action")
                val deviceId = call.argument<Int?>("deviceId")
                if(action != null && deviceId != null) {
                    if(HomeOsClient.getOsController().groupControl(deviceId,
                            JSONObject.wrap(action)?.toString() ?: "") != 0) {
                        LogUtil.tag("homeOs").msg("请求groupControl失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("请求groupControl失败")
                }
            }
            "getSceneInfo" -> {
                if (HomeOsClient.getOsController().sceneInfo != 0) {
                    LogUtil.tag("homeOs").msg("请求getSceneInfo失败")
                }
            }
            "sceneExcute" -> {
                val sceneId = call.argument<String?>("sceneId")
                if(sceneId != null) {
                    if(HomeOsClient.getOsController().sceneExcute(sceneId) != 0) {
                        LogUtil.tag("homeOs").msg("请求sceneExcute失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("请求sceneExcute失败")
                }
            }
        }
    }

    override fun msg(topic: String?, msg: String?) {
        mMethodChannel.invokeMethod("mqttHandler", mapOf(
            "topic" to topic,
            "msg" to msg
        ))
    }

    override fun log(msg: String?) {
        mMethodChannel.invokeMethod("log", mapOf(
            "msg" to msg
        ))
    }

}