package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.setting.SystemUtil
import com.midea.smart.open.common.util.StringUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.function.Function

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
                onHandlerGatewaySn(result)
            }
            "reboot" -> {
                onHandlerReboot(result)
            }
            else -> {
                onCallNotImplement(result)
            }
        }
    }

    private fun onHandlerReboot(result: MethodChannel.Result) {
        SystemUtil.reboot()
        onCallSuccess(result, true)
    }

    private fun onHandlerGatewaySn(result: MethodChannel.Result) {
        SystemUtil.getGatewaySn { t ->
            if(StringUtils.isEmpty(t)) {
                onCallError(result, errorMessage = "网关请求超时")
            } else {
                onCallSuccess(result, t)
            }
            t
        }
    }

    private fun onHandlerSystemVersion(result: MethodChannel.Result) {
        val appVersion = SystemUtil.getAppVersion(context)
        val gatewayVersion = SystemUtil.getGatewayVersion()
        onCallSuccess(result, "0000$appVersion$gatewayVersion")
    }

    private fun onHandlerIpAddress(result: MethodChannel.Result) {
        onCallSuccess(result, SystemUtil.getIpAddress(context))
    }

    private fun onHandlerMacAddress(result: MethodChannel.Result) {
        onCallSuccess(result, SystemUtil.getMacAddress())
    }




}