package com.midea.light.channel.method

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import com.midea.light.MainApplication
import com.midea.light.RxBus
import com.midea.light.bean.GatewayPlatform
import com.midea.light.bean.GatewayPlatformBean
import com.midea.light.bean.GatewaySetPlatformBean
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.config.GatewayConfig
import com.midea.light.gateway.GateWayUtils
import com.midea.light.gateway.GatewayCallback
import com.midea.light.issued.relay.RelayDeviceChangeEvent
import com.midea.light.issued.switchModel.SwitchModelEvent
import com.midea.light.log.LogUtil
import com.midea.light.setting.SystemUtil
import com.midea.light.setting.relay.RelayRepository
import com.midea.light.thread.MainThread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

/**
 * @ClassName GatewayChannel
 * @Description
 * @Author weinp1
 * @Date 2023/2/15 11:07
 * @Version 1.0
 */
@SuppressLint("CheckResult")
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

        RxBus.getInstance().toObservableInSingle(SwitchModelEvent::class.java)
            .subscribe({ mSwitchModelEvent: SwitchModelEvent ->
                if (mSwitchModelEvent.switchModelBean.ep1 != null) {
                    RelayRepository.getInstance().gP0Model = mSwitchModelEvent.switchModelBean.ep1
                    if (RelayRepository.getInstance().gP0Model == 0) {
                        GatewayConfig.relayControl.controlRelay1Open(false)
                        val relay1= GatewayConfig.relayControl.isRelay1Open
                        MainThread.run { mMethodChannel.invokeMethod("relay1Report", relay1) }
                    } else {
                        SystemUtil.CommandGP(0, true)
                        val relay1 = GatewayConfig.relayControl.isRelay1Open
                        MainThread.run { mMethodChannel.invokeMethod("relay1Report", relay1) }
                    }
                }
                if (mSwitchModelEvent.switchModelBean.ep2 != null) {
                    RelayRepository.getInstance().gP1Model = mSwitchModelEvent.switchModelBean.ep2
                    if (RelayRepository.getInstance().gP1Model == 0) {
                        GatewayConfig.relayControl.controlRelay2Open(false)
                        val relay1 = GatewayConfig.relayControl.isRelay2Open
                        MainThread.run{ mMethodChannel.invokeMethod("relay2Report", relay1) }
                    } else {
                        SystemUtil.CommandGP(1, true)
                        val relay1= GatewayConfig.relayControl.isRelay2Open
                        MainThread.run { mMethodChannel.invokeMethod("relay2Report", relay1) }
                    }
                }
            }
            ) { throwable: Throwable? ->
                Log.e(
                    "sky",
                    "rxBus错误",
                    throwable
                )
            }


    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        when (method) {
            "controlRelay1Open" -> {
                GatewayConfig.relayControl.controlRelay1Open(call.arguments as Boolean)
                result.safeSuccess(true)
//                val dialog = AirConditionDialog(
//                    MainApplication.mMainActivity,
//                    AirConditionController.getInstance().AirConditionList[0]
//                )
//                dialog.create()
//                dialog.show()

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
            "resetGateway" -> {
                GateWayUtils.resetGateway()
                result.safeSuccess(true)
            }
            "resetRelayModel" -> {
                RelayRepository.getInstance().gP0Model=0
                RelayRepository.getInstance().gP1Model=0
                GatewayConfig.relayControl.controlRelay1Open(false)
                GatewayConfig.relayControl.controlRelay2Open(false)
                result.safeSuccess(true)
            }
            "checkGatewayPlatform" -> {
                // 检查当前运行的环境
                //0NONE 1美居 2美的照明
                GateWayUtils.checkGatewayPlatform(object : GatewayCallback.CheckPlatform(
                    System.currentTimeMillis() + 3000,
                    TimeUnit.MILLISECONDS
                ) {
                    override fun callback(msg: GatewayPlatformBean?) {
                        if (msg == null) {
                            result.safeSuccess(-1)
                            LogUtil.tag("网关运行环境").msg("网关未运行")
                        } else {
                            MainApplication.gatewayPlatform = msg.platform
                            //0NONE 1美居 2美的照明
                            result.safeSuccess(msg.platform.rawPlatform())
                            LogUtil.tag("网关运行环境").msg("网关运行运行环境为${msg.platform}")
                        }
                    }
                })
            }
            "setMeijuPlatform" -> {
                // 设置网关运行环境为美居平台
                GateWayUtils.setMeijuPlatform(object : GatewayCallback.SetPlatform(
                    System.currentTimeMillis() + 3000,
                    TimeUnit.MILLISECONDS
                ) {
                    override fun callback(msg: GatewaySetPlatformBean?) {
                        if (msg == null) {
                            result.safeSuccess(false)
                        } else {
                            MainApplication.gatewayPlatform = GatewayPlatform.MEIJU
                            result.safeSuccess(true)
                        }
                    }
                })
            }
            "setHomluxPlatForm" -> {
                // 设置网关运行环境为美的照明
                GateWayUtils.setHomluxPlatForm(object : GatewayCallback.SetPlatform(
                    System.currentTimeMillis() + 3000,
                    TimeUnit.MILLISECONDS
                ) {
                    override fun callback(msg: GatewaySetPlatformBean?) {
                        if (msg == null) {
                            result.safeSuccess(false)
                        } else {
                            MainApplication.gatewayPlatform = GatewayPlatform.HOMLUX
                            result.safeSuccess(true)
                        }
                    }
                })
            }
            "setMeijuPlatFormFlag" -> {
                // 重新设置网关运行环境为美的照明，并不清除网关子设备，适用于ota升级之后的状态回复
                GateWayUtils.setMeijuPlatFormFlag(object : GatewayCallback.SetPlatform(
                    System.currentTimeMillis() + 3000,
                    TimeUnit.MILLISECONDS
                ) {
                    override fun callback(msg: GatewaySetPlatformBean?) {
                        if (msg == null) {
                            result.safeSuccess(false)
                        } else {
                            MainApplication.gatewayPlatform = GatewayPlatform.MEIJU
                            result.safeSuccess(true)
                        }
                    }
                })
            }
        }
    }

}

