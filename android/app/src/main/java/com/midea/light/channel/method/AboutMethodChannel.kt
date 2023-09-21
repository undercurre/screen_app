package com.midea.light.channel.method

import android.content.Context
import com.midea.iot.sdk.common.security.SecurityUtils
import com.midea.light.BuildConfig
import com.midea.light.MainApplication
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.common.utils.DataClearManager
import com.midea.light.setting.SystemUtil
import com.midea.smart.open.common.util.StringUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @ClassName AboutMethodChannel
 * @Description 关于页的Channel
 * @Author weinp1
 * @Date 2022/12/12 16:02
 * @Version 1.0
 */
class AboutMethodChannel(context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): AboutMethodChannel {
            val methodChannel = AboutMethodChannel(context)
            methodChannel.setup(binaryMessenger, channel);
            return methodChannel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val methodName = call.method
        val arguments = call.arguments
        when(methodName) {
            "getAppVersion" -> {
                val appVersion = SystemUtil.getAppVersion(context)
                result.safeSuccess(appVersion)
            }
            "getGatewayVersion" -> {
                val gatewayVersion = SystemUtil.getGatewayVersion(MainApplication.gatewayPlatform)
                result.safeSuccess(gatewayVersion)
            }
            "getMacAddress" -> {
                onHandlerMacAddress(result)
            }
            "getIpAddress" -> {
                onHandlerIpAddress(result)
            }
            "getSystemVersion" -> {
                onHandlerSystemVersion(result)
            }
            "getGatewaySn" -> {
                onHandlerGatewaySn(call, result)
            }
            "reboot" -> {
                onHandlerReboot(result)
            }
            "clearLocalCache" -> {
                onHandlerClearLocalCache(result)
            }
            "queryFlavor" -> {
                result.safeSuccess(BuildConfig.FLAVOR)
            }
            else -> {
                onCallNotImplement(result)
            }
        }
    }

    private fun onHandlerClearLocalCache(result: MethodChannel.Result) {
        Thread { DataClearManager.cleanApplicationData() }.start()
        result.safeSuccess(true)
    }

    private fun onHandlerReboot(result: MethodChannel.Result) {
        SystemUtil.reboot()
        onCallSuccess(result, true)
    }

    private fun onHandlerGatewaySn(call: MethodCall, result: MethodChannel.Result) {
        val isEncrypt = call.argument<Boolean?>("isEncrypt") ?: false
        val secretKey = call.argument<String?>("secretKey")
        assert(isEncrypt && !StringUtils.isEmpty(secretKey) || !isEncrypt)
        SystemUtil.getGatewaySn { t ->
            if(StringUtils.isEmpty(t)) {
                onCallError(result, errorMessage = "网关请求超时")
            } else {
                onCallSuccess(result, if(isEncrypt) SecurityUtils.encodeAES128(t, secretKey) else t)
            }
            t
        }
    }

    private fun onHandlerSystemVersion(result: MethodChannel.Result) {
        val appVersion = SystemUtil.getAppVersion(context)
        val gatewayVersion = SystemUtil.getGatewayVersion(MainApplication.gatewayPlatform)
        val romVersion = SystemUtil.getRomVersion()
        onCallSuccess(result, "$romVersion$appVersion$gatewayVersion")
    }

    private fun onHandlerIpAddress(result: MethodChannel.Result) {
        onCallSuccess(result, SystemUtil.getIpAddress(context))
    }

    private fun onHandlerMacAddress(result: MethodChannel.Result) {
        onCallSuccess(result, SystemUtil.getMacAddress())
    }




}