package com.midea.light.channel.method

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.PowerManager
import com.midea.light.MainApplication
import com.midea.light.common.config.AppCommonConfig
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.log.LogUtil
import com.midea.light.setting.SystemUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*


private const val TAG = "Setting"


/**
 * @ClassName NetMethodChanel
 * @Description 设置 -- 方法通道
 * @Author yangyl19
 * @Date 2022/12/10 13:37
 * @Version 1.0
 */
class SettingMethodChannel constructor(override val context: Context) : AbsMZMethodChannel(context) {

    // 屏幕亮灭 -- 广播接收器
    private val mScreenReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (Intent.ACTION_SCREEN_ON == intent.action) {
                LogUtil.i("屏幕点亮")
                mMethodChannel.invokeMethod("broadcastScreenState", true)
            } else if(Intent.ACTION_SCREEN_OFF == intent.action) {
                LogUtil.i("屏幕关闭")
                mMethodChannel.invokeMethod("broadcastScreenState", false)
            }
        }
    }

    companion object {
        // 屏幕亮灭 -- 广播接收器 是否被注册
        var  screenReceiverRegister: Boolean = false

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
            "registerScreenBroadcast" -> {
                if (!screenReceiverRegister) {
                    screenReceiverRegister = true
                    context.registerReceiver(mScreenReceiver, IntentFilter().apply {
                        this.addAction(Intent.ACTION_SCREEN_ON)
                        this.addAction(Intent.ACTION_SCREEN_OFF)
                    })
                }
            }
            "unRegisterScreenBroadcast" -> {
                if(screenReceiverRegister) {
                    screenReceiverRegister = false
                    context.unregisterReceiver(mScreenReceiver)
                }
            }
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
                if(Objects.equals(AppCommonConfig.getChannel(), "JH")) {
                    SystemUtil.openOrCloseScreen(call.arguments as Boolean)
                } else {
                    SystemUtil.openOrCloseScreen(call.arguments as Boolean)
                }
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