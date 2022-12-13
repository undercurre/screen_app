package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.common.config.AppCommonConfig
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @ClassName ConfigChannel
 * @Description 初始化配置
 * @Author weinp1
 * @Date 2022/12/13 17:18
 * @Version 1.0
 */
class ConfigChannel(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): ConfigChannel {
            val methodChannel = ConfigChannel(context)
            methodChannel.setup(binaryMessenger, channel);
            return methodChannel
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "initConfig" -> {
                assert(call.hasArgument("env"))
                val env = call.argument<String>("env")
                AppCommonConfig.init(if(env == "prod") AppCommonConfig.CONFIG_TYPE_PRODUCT else AppCommonConfig.CONFIG_TYPE_DEVELOP)
            }
        }
    }


}