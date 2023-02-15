package com.midea.light.channel.method

import android.content.Context
import androidx.lifecycle.Observer
import com.midea.light.RxBus
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.config.GatewayConfig
import com.midea.light.issued.relay.RelayDeviceChangeEvent
import com.midea.light.thread.MainThread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.function.Consumer

/**
 * @ClassName GatewayChannel
 * @Description
 * @Author weinp1
 * @Date 2023/2/15 11:07
 * @Version 1.0
 */
class GatewayChannel(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): GatewayChannel {
            val methodChannel = GatewayChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }

    init {
        RxBus.getInstance()
            .toObservableInSingle(RelayDeviceChangeEvent::class.java)
            .subscribe {
                val relay1 = GatewayConfig.relayControl.isRelay1Open
                val relay2 = GatewayConfig.relayControl.isRelay2Open
                MainThread.run {
                    mMethodChannel.invokeMethod("relay1Report", relay1)
                    mMethodChannel.invokeMethod("relay2Report", relay2)
                }
            }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        when(method) {
            "controlRelay1Open" -> {
                GatewayConfig.relayControl.controlRelay1Open(call.arguments as Boolean)
                result.safeSuccess(true)
            }
            "controlRelay2Open" -> {
                GatewayConfig.relayControl.controlRelay2Open(call.arguments as Boolean)
                result.safeSuccess(true)
            }
            "relay1IsOpen" -> {
                result.safeSuccess(GatewayConfig.relayControl.isRelay1Open)
            }
            "relay2IsOpen" -> {
                result.safeSuccess(GatewayConfig.relayControl.isRelay2Open)
            }
        }
    }

}

