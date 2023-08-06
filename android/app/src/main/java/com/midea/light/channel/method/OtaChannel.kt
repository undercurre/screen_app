package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.setting.ota.OTAUpgradeHelper
import com.midea.light.setting.ota.V2IOTCallback
import com.midea.light.upgrade.UpgradeType
import com.midea.light.upgrade.control.UpgradeDownloadControl
import com.midea.light.upgrade.control.UpgradeInstallControl
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.midea.light.MainApplication
import com.midea.light.bean.GatewayPlatform


/**
 * @ClassName OtaChannel
 * @Description OTA通道
 * @Author weinp1
 * @Date 2022/12/14 17:14
 * @Version 1.0
 */
class OtaChannel(override val context: Context) : AbsMZMethodChannel(context) {

    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): OtaChannel {
            val methodChannel = OtaChannel(context)
            methodChannel.setup(binaryMessenger, channel);
            return methodChannel
        }
    }

    var downloadControl: UpgradeDownloadControl? = null
    var installControl: UpgradeInstallControl? = null



    val callback = object: V2IOTCallback {

        override fun setDownloadControl(downloadControl: UpgradeDownloadControl?) {
            super.setDownloadControl(downloadControl)
            this@OtaChannel.downloadControl = downloadControl
        }

        override fun setUpgradeInstallControl(control: UpgradeInstallControl?) {
            super.setUpgradeInstallControl(control)
            this@OtaChannel.installControl = control
        }

        override fun downloadSuc() {
            mMethodChannel.invokeMethod("downloadSuc", null)
        }

        override fun downloadFail() {
            mMethodChannel.invokeMethod("downloadFail", null)

        }

        override fun upgradeSuc(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            mMethodChannel.invokeMethod("installSuc", null)
        }

        override fun upgradeFail(code: Int, msg: String?) {
            mMethodChannel.invokeMethod("installFail", null)
        }

        override fun upgradeProcess(process: Int) {
            mMethodChannel.invokeMethod("downloading", process)
        }

        override fun newVersion(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            entity?.apply {
                mMethodChannel.invokeMethod("newVersion", entity.versionDesc)
            }
        }

        override fun noUpgrade() {
            mMethodChannel.invokeMethod("noNewVersion", null)
        }

        override fun confirmInstall(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            // 直接进入安装
            installControl?.confirm()
        }

    }

    init {
        OTAUpgradeHelper.globalInit(context, callback)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "supportNormalOTA" -> {
                result.safeSuccess(OTAUpgradeHelper.supportNormalOTA)
            }
            "supportDirectOTA" -> {
                result.safeSuccess(OTAUpgradeHelper.supportDirectOTA)
            }
            "supportRomOTA" -> {
                result.safeSuccess(OTAUpgradeHelper.supportRomOTA)
            }
            "reset" -> {
                OTAUpgradeHelper.treatDown()
                onCallSuccess(result, true)
            }
            "checkUpgrade" -> {
                if(OTAUpgradeHelper.unable()) {
                    onCallError(result, errorCode = "-1", errorMessage = "请先调用init方法")
                } else if(OTAUpgradeHelper.isDownload()) {
                    onCallError(result, errorCode = "-2", errorMessage = "已经在下载或者安装中")
                } else {
                    assert(call.hasArgument("uid"))
                    assert(call.hasArgument("deviceId"))
                    assert(call.hasArgument("token"))
                    assert(call.hasArgument("sn"))

                    val uid = call.argument<String>("uid")
                    val deviceId = call.argument<String>("deviceId")
                    val token = call.argument<String>("token")
                    val sn = call.argument<String>("sn")
                    val type = call.argument<Int>("numType")

                    OTAUpgradeHelper.initUserConfig(uid, deviceId, token, sn, MainApplication.gatewayPlatform.rawPlatform())

                    OTAUpgradeHelper.queryUpgrade(when(type) {
                        3 -> UpgradeType.ROOM
                        2 -> UpgradeType.DIRECT
                        else -> UpgradeType.NORMAL
                    })
                    onCallSuccess(result, true)
                }
            }
            "confirmDownload" -> {
                downloadControl?.confirm()
                onCallSuccess(result, downloadControl != null)
            }
            "cancelDownload" -> {
                downloadControl?.cancel()
                onCallSuccess(result, downloadControl != null)
            }
            "isInit" -> {
                onCallSuccess(result, OTAUpgradeHelper.unable())
            }
            "isDownloading" -> {
                onCallSuccess(result, OTAUpgradeHelper.isDownload())
            }
            else -> {
                onCallNotImplement(result)
            }
        }
    }

}