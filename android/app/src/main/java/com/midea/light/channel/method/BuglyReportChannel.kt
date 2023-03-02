package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.log.LogUtil
import com.tencent.bugly.crashreport.CrashReport
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

/**
 * @ClassName BuglyReportChannel
 * @Description 崩溃日志上班
 * @Author weinp1
 * @Date 2023/3/1 11:38
 * @Version 1.0
 */


class BuglyReportChannel(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): BuglyReportChannel {
            val methodChannel = BuglyReportChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }

    override fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        mMethodChannel = MethodChannel(binaryMessenger, channel, StandardMethodCodec.INSTANCE)
        mMethodChannel.setMethodCallHandler { call, result ->
            LogUtil.tag("channel").msg("Method=${call.method} Arguments=${call.arguments}")
            this.onMethodCall(call, result)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method

        when(method) {
            // 异常上报
            "postException" -> {
                val array = call.arguments<List<String?>>()
                val type = array?.get(0)
                val exception = array?.get(1)
                val stack = array?.get(2)
                // 测试打印
                LogUtil.tag("bugly").msg("$type $exception $stack")
                CrashReport.postException(4, type, exception, stack, null)
            }
        }

    }

}