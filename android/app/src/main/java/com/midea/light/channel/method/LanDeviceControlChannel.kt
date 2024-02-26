package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.common.thread.MainThread
import com.midea.light.homeos.HomeOsClient
import com.midea.light.homeos.HomeOsControllerCallback
import com.midea.light.homeos.MessageQueue
import com.midea.light.log.LogUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

// 局域网设备控制Channel通道
class LanDeviceControlChannel(override val context: Context): AbsMZMethodChannel(context) , HomeOsControllerCallback {

    var hasInit = false

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): LanDeviceControlChannel {
            val methodChannel = LanDeviceControlChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }

    // 消息缓冲队列
    var messageQueue = MessageQueue(object : MessageQueue.Callback {

        override fun filter(topic: String?, message: String?): Boolean {
            return true
        }

        override fun handler(msg: String?) {
            val topic = "暂未用到字段"
            MainThread.run {
                LogUtil.tag("homeOs").msg("topic = $topic msg = $msg")
                mMethodChannel.invokeMethod("mqttHandler", mapOf(
                    "topic" to topic,
                    "msg" to msg
                ))
            }
        }

    })

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val methodName = call.method
        when(methodName) {
            "init" -> {
                if(!hasInit) {
                    HomeOsClient.getOsController().netCardRegister("lo")
                    HomeOsClient.getOsController().netCardRegister("wlan0")
                    HomeOsClient.getOsController().init()
                    hasInit = false
                    LogUtil.tag("homeOs").msg("请求init")
                }
            }
            "login" -> {
                val homeId = call.argument<String?>("homeId")
                val key = call.argument<String?>("key")
                if(homeId != null && key != null) {
                    HomeOsClient.getOsController().login(homeId, key)
                }
                HomeOsClient.getOsController().setCallback(this)
                LogUtil.tag("homeOs").msg("请求login")
                messageQueue.start()
            }
            "logout" -> {
                HomeOsClient.getOsController().logout()
                HomeOsClient.getOsController().setCallback(null)
                LogUtil.tag("homeOs").msg("请求logout")
                messageQueue.stop()
            }
            "getDeviceInfo" -> {
                val requestId = call.argument<String>("requestId")
                LogUtil.tag("homeOs").msg("请求getDeviceInfo")
                if(HomeOsClient.getOsController().getDeviceInfo(requestId) != 0) {
                    LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                }
            }
            "getDeviceStatus" -> {
                val deviceId = call.argument<String?>("deviceId")
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求getDeviceStatus")
                if (HomeOsClient.getOsController().getDeviceStatus(requestId, deviceId) != 0) {
                    LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                }
            }
            "deviceControl" -> {
                val actions = call.argument<JSONArray?>("actions")
                val deviceId = call.argument<String?>("deviceId")
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求deviceControl")
                if(deviceId != null && actions != null) {
                    val jsonObject = JSONObject()
                    jsonObject.put("actions", actions)
                    if (HomeOsClient.getOsController().deviceControl(requestId, deviceId, jsonObject.toString()) != 0) {
                        LogUtil.tag("homeOs").msg("请求getDeviceInfo失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("传入的DeviceId为空")
                }
            }
            "getGroupInfo" -> {
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求getGroupInfo")
                if(HomeOsClient.getOsController().getGroupInfo(requestId) != 0) {
                    LogUtil.tag("homeOs").msg("请求getGroupInfo失败")
                }
            }
            "groupControl" -> {
                val action = call.argument<JSONObject?>("action")
                val deviceId = call.argument<String?>("deviceId")
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求groupControl")
                if(action != null && deviceId != null) {
                    val actions = JSONObject()
                    actions.put("actions", action)
                    if(HomeOsClient.getOsController().groupControl(requestId, deviceId, actions.toString()) != 0) {
                        LogUtil.tag("homeOs").msg("请求groupControl失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("请求groupControl失败")
                }
            }
            "getSceneInfo" -> {
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求getSceneInfo")
                if (HomeOsClient.getOsController().getSceneInfo(requestId) != 0) {
                    LogUtil.tag("homeOs").msg("请求getSceneInfo失败")
                }
            }
            "sceneExcute" -> {
                val sceneId = call.argument<String?>("sceneId")
                val requestId = call.argument<String?>("requestId")
                LogUtil.tag("homeOs").msg("请求sceneExcute")
                if(sceneId != null) {
                    if(HomeOsClient.getOsController().sceneExcute(requestId, sceneId) != 0) {
                        LogUtil.tag("homeOs").msg("请求sceneExcute失败")
                    }
                } else {
                    LogUtil.tag("homeOs").msg("请求sceneExcute失败")
                }
            }
            "adjustSpeedToLow" -> {
                messageQueue.adjustSpeedToLow()
            }
            "adjustSpeedToNormal" -> {
                messageQueue.adjustSpeedToNormal()
            }
        }
    }

    override fun msg(topic: String?, msg: String?) {
        messageQueue.addMessage(topic, msg)
    }

    override fun log(msg: String?) {
        MainThread.run {
            LogUtil.tag("homeOs").msg("log = msg")
            mMethodChannel.invokeMethod("log", mapOf(
                "msg" to msg
            ))
        }
    }

}