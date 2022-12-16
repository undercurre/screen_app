package com.midea.light.channel.method

import android.content.Context
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.setting.ota.OTAUpgradeHelper
import com.midea.light.setting.ota.V2IOTCallback
import com.midea.light.upgrade.control.UpgradeDownloadControl
import com.midea.light.upgrade.control.UpgradeInstallControl
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

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

        override fun upgradeSuc(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            mMethodChannel.invokeMethod("downloadSuc", null)
        }

        override fun upgradeFail(code: Int, msg: String?) {
            mMethodChannel.invokeMethod("downloadFail", null)
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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "init"-> {
                assert(call.hasArgument("uid"))
                assert(call.hasArgument("deviceId"))
                assert(call.hasArgument("mzToken"))
                assert(call.hasArgument("sn"))
                val uid = call.argument<String>("uid")
                val deviceId = call.argument<String>("deviceId")
                val mzToken = call.argument<String>("mzToken")
                val sn = call.argument<String>("sn")
                OTAUpgradeHelper.init(context, callback, uid, deviceId, mzToken, sn)
                onCallSuccess(result, true)
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
                    val background = call.argument<Boolean?>("background") ?: false
                    OTAUpgradeHelper.queryAppAndRoomUpgrade(background)
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