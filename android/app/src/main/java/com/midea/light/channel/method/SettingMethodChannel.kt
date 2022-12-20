package com.midea.light.channel.method

import android.content.Context
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.channel.HybridResult
import com.midea.light.log.LogUtil
import com.midea.light.setting.SystemUtil
import com.midea.light.setting.voice.VoiceSettingManager
import com.midea.light.setting.wifi.ScanNearbyWiFiHandler
import com.midea.light.setting.wifi.impl.ConfigurationSecurities
import com.midea.light.setting.wifi.impl.ConfigurationSecuritiesOld
import com.midea.light.setting.wifi.impl.ConfigurationSecuritiesV8
import com.midea.light.setting.wifi.impl.Version
import com.midea.light.thread.MainThread
import com.midea.light.utils.CollectionUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject


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