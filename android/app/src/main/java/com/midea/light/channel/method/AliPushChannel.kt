package com.midea.light.channel.method

import android.app.Application
import android.content.Context
import android.content.IntentFilter
import com.alibaba.sdk.android.push.CloudPushService
import com.alibaba.sdk.android.push.CommonCallback
import com.alibaba.sdk.android.push.noonesdk.PushInitConfig
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import com.midea.light.BaseApplication
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.common.config.AppCommonConfig
import com.midea.light.push.AliPushReceiver
import com.midea.light.push.AliPushRepository
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


/**
 * @author Admin
 * @des
 * @version $
 * @updateAuthor $
 * @updateDes
 */
class AliPushChannel constructor(override val context: Context) : AbsMZMethodChannel(context){
    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): AliPushChannel {
            val methodChannel = AliPushChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }

        @JvmStatic
        fun aliPushInit(applicationContenxt: Application) {
            val config = PushInitConfig.Builder()
                .application(applicationContenxt)
                .appKey(AppCommonConfig.KEY_ALIPUSH)
                .appSecret(AppCommonConfig.SECRET_ALIPUSH)
                .build()
            PushServiceFactory.init(config)
            val pushService = PushServiceFactory.getCloudPushService()
            pushService.setLogLevel(CloudPushService.LOG_DEBUG)
            pushService.register(applicationContenxt, object : CommonCallback {
                override fun onSuccess(s: String) {
                    AliPushRepository.getInstance().aliPushDeviceId = pushService.deviceId;
                }
                override fun onFailed(s: String, s1: String) {

                }
            })
        }
    }

    fun notifyPushMessage(tittle: String) {
        mMethodChannel.invokeMethod("notifyPushMessage", tittle)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAliPushDeviceId" -> {
                result.safeSuccess(AliPushRepository.getInstance().aliPushDeviceId)
            } else -> {
            // 对应的方法没有报错
            onCallNotImplement(result)
        }
        }
    }
}