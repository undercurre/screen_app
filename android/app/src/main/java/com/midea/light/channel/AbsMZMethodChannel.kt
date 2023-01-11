package com.midea.light.channel

import android.content.Context
import com.midea.light.log.LogUtil
import com.midea.light.thread.MainThread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @ClassName AbsMZMethodChannel
 * @Description 所有的channel的基类
 * @Author weinp1
 * @Date 2022/11/17 13:45
 * @Version 1.0
 */
abstract class AbsMZMethodChannel constructor(open val context: Context) : MethodChannel.MethodCallHandler {

    protected lateinit var mMethodChannel: MethodChannel

    // 安装
    open fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        // 使用 `JSONMethodCodec` 解析传入与传出的参数
        mMethodChannel = MethodChannel(binaryMessenger, channel, JSONMethodCodec.INSTANCE)
        mMethodChannel.setMethodCallHandler { call, result ->
            LogUtil.tag("channel").msg("Method=${call.method} Arguments=${call.arguments}")
            this@AbsMZMethodChannel.onMethodCall(call, result)
        }
    }

    abstract override fun onMethodCall(call: MethodCall, result: MethodChannel.Result)

    open fun onCallSuccess(result: MethodChannel.Result, any: Any) {
        MainThread.run { result.success(any) }
    }

    open fun onCallError(result: MethodChannel.Result, errorCode :String = "-1",
                         errorMessage: String = "请求异常", errorDetail: Any? = null) {
        MainThread.run { result.error(errorCode, errorMessage, errorDetail) }
    }

    open fun onCallNotImplement(result: MethodChannel.Result) {
        MainThread.run { result.notImplemented() }
    }

    // 卸载
    open fun teardown() {
        mMethodChannel.setMethodCallHandler(null)
    }



}