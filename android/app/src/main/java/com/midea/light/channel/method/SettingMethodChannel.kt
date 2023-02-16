package com.midea.light.channel.method

import android.content.Context
import android.os.PowerManager
import com.midea.light.MainApplication
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.log.LogUtil
import com.midea.light.setting.SystemUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


private const val TAG = "Setting"


/**
 * @ClassName NetMethodChanel
 * @Description 设置 -- 方法通道
 * @Author yangyl19
 * @Date 2022/12/10 13:37
 * @Version 1.0
 */
class SettingMethodChannel constructor(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): SettingMethodChannel {
            val methodChannel = SettingMethodChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }


    override fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        super.setup(binaryMessenger, channel)
        LogUtil.tag(TAG).msg("系统设置通道启动")
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        LogUtil.tag(TAG).msg("flutter -> method: ${call.method}")
        when (call.method) {
            "SettingMediaVoiceValue" -> {
                SystemUtil.setSystemAudio(call.arguments as Int)
                result.success(SystemUtil.getSystemAudio())
            }
            "GettingMediaVoiceValue" -> {
                result.success(SystemUtil.getSystemAudio())
            }
            "SettingLightValue" -> {
                SystemUtil.lightSet(call.arguments as Int)
                result.success(SystemUtil.lightGet())
            }
            "GettingLightValue" -> {
                result.success(SystemUtil.lightGet())
            }
            "SettingAutoLight" -> {
                SystemUtil.setScreenAutoMode(call.arguments as Boolean)
            }
            "SettingNearWakeup" -> {
                SystemUtil.setNearWakeup(call.arguments as Boolean)
            }
            "NoticeNativeStandbySate" -> {
                MainApplication.standbyState=(call.arguments as Boolean)
            }
            "openOrCloseScreen" -> {
                SystemUtil.openOrCloseScreen(call.arguments as Boolean)
                result.success(true)
            }
            "screenOpenCloseState" -> {
//                var manager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
//                onCallSuccess(result, manager.inKeyguardRestrictedInputMode())

                val pm =  context.getSystemService(Context.POWER_SERVICE) as PowerManager
                val isScreenOn = pm.isScreenOn()
                onCallSuccess(result, isScreenOn)
            }
            "GettingNearWakeup" -> {
                result.success(SystemUtil.isNearWakeup())
            }
            "GettingAutoLight" -> {
                result.success(SystemUtil.isScreenAutoMode())
            }
            else -> {
                // 对应的方法没有报错
                onCallNotImplement(result)
            }
        }
    }


}