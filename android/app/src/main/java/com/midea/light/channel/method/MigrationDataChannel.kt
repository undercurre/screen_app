package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.log.LogUtil
import com.midea.light.migration.*
import com.midea.light.utils.CollectionUtil
import com.midea.smart.open.common.util.StringUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * @ClassName MigrationChannel
 * @Description 数据迁移通道
 * @Author weinp1
 * @Date 2023/3/2 18:00
 * @Version 1.0
 */
class MigrationDataChannel(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): MigrationDataChannel {
            val methodChannel = MigrationDataChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method;
        when(method) {
            "syncWiFi" -> {
                val wifis = MigrateWiFiRecordCache.getInstance().alreadyLoginWiFis
                LogUtil.tag("migrate").array(wifis)
                if(CollectionUtil.isEmpty(wifis)) {
                    result.safeError()
                } else {
                    val jsonArray = JSONArray(wifis)
                    if(jsonArray.length() <= 0) {
                        result.safeError()
                    } else {
                        result.safeSuccess(jsonArray)
                    }
                }
            }
            "syncToken" -> {
                val token = MigrateTokenCache.getInstance().token
                val userid = MigrateTokenCache.getInstance().userID
                val iotUserId = MigrateTokenCache.getInstance().iotUserId
                val dataDecodeKey = MigrateTokenCache.getInstance().dataDecodeKey
                val dataEncodeKey = MigrateTokenCache.getInstance().dataEncodeKey
                val deviceId = MigrateDeviceIdUtil.getDeviceId(context)
                if(StringUtils.isEmpty(token)
                    || StringUtils.isEmpty(userid)
                    || StringUtils.isEmpty(iotUserId)
                    || StringUtils.isEmpty(dataDecodeKey)
                    || StringUtils.isEmpty(dataEncodeKey)) {
                    result.safeError()
                } else {
                    val json = JSONObject()
                    json.put("token", JSONObject(token))
                    json.put("userid", userid)
                    json.put("iotUserId", iotUserId)
                    json.put("dataDecodeKey", dataDecodeKey)
                    json.put("dataEncodeKey", dataEncodeKey)
                    json.put("deviceId", deviceId)
                    LogUtil.tag("migrate").msg(json.toString())
                    result.safeSuccess(json)
                }
            }
            "syncUserData" -> {
                val userInfo = MigrateUserDataCache.create().userInfo
                LogUtil.tag("migrate").msg(userInfo)
                if(StringUtils.isEmpty(userInfo)) {
                    result.safeError()
                } else {
                    result.safeSuccess(JSONObject(userInfo))
                }
            }

            //homlux数据迁移
            "syncHomluxToken" -> {
                val token = MigrateHomluxCache.getInstance().token
                if(StringUtils.isEmpty(token)) {
                    result.safeError()
                } else {
                    val json = JSONObject()
                    json.put("token", JSONObject(token))
                    LogUtil.tag("migrate").msg(json.toString())
                    result.safeSuccess(json)
                }
            }

            "syncHomluxUserData" -> {
                val userData = MigrateHomluxCache.getInstance().userData
                LogUtil.tag("migrate").msg(userData)
                if(StringUtils.isEmpty(userData)) {
                    result.safeError()
                } else {
                    result.safeSuccess(JSONObject(userData))
                }
            }

            "syncHomluxFamily" -> {
                val family = MigrateHomluxCache.getInstance().family
                LogUtil.tag("migrate").msg(family)
                if(StringUtils.isEmpty(family)) {
                    result.safeError()
                } else {
                    result.safeSuccess(JSONObject(family))
                }
            }

            "syncHomluxRoom" -> {
                val room = MigrateHomluxCache.getInstance().room
                LogUtil.tag("migrate").msg(room)
                if(StringUtils.isEmpty(room)) {
                    result.safeError()
                } else {
                    result.safeSuccess(JSONObject(room))
                }
            }

            "syncGatewayApplianceCode" -> {
                val bindGatewayInfo = MigrateHomluxCache.getInstance().bindGatewayInfo
                LogUtil.tag("migrate").msg(bindGatewayInfo)
                if(StringUtils.isEmpty(bindGatewayInfo)) {
                    result.safeError()
                } else {
                    result.safeSuccess(JSONObject(bindGatewayInfo))
                }
            }
        }

    }

}