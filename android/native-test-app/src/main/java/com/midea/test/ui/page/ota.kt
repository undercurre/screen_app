package com.midea.test.ui.page

import android.content.Context
import android.util.Log
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.midea.light.common.config.AppCommonConfig
import com.midea.light.log.config.MSmartLogger
import com.midea.light.setting.ota.OTAUpgradeHelper
import com.midea.light.setting.ota.V2IOTCallback
import com.midea.light.upgrade.UpgradeType


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OTA(modifier: Modifier = Modifier) {
    var context = LocalContext.current
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(text = "OTA测试升级") }) },
        content = { it ->
            Box(Modifier.padding(it), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Button(onClick = {
                        initOTA(context)
                    }) {
                        Text(text = "初始化OTA")
                    }
                    Button(onClick = {
                        queryRomType()
                    }) {
                        Text(text = "请求ROM包")
                    }
                    Button(onClick = {
                    }) {
                        Text(text = "暂停")
                    }
                    Button(onClick = {
                    }) {
                        Text(text = "循环播放五次")
                    }
                }
            }
        }
    )
}

fun initOTA(context: Context) {
    MSmartLogger.init(
        com.midea.light.log.config.LogConfiguration.LogConfigurationBuilder.create()
            .withEnable(true)
            .withStackFrom(0)
            .withStackTo(4)
            .withTag("M-Smart")
            .build()
    )
    OTAUpgradeHelper.globalInit(context, object: V2IOTCallback{
        override fun downloadSuc() {
            Log.i("ota", "downloadSuc")
        }

        override fun downloadFail() {
            Log.i("ota", "downloadFail")
        }

        override fun upgradeSuc(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            Log.i("ota", "upgradeSuc")

        }

        override fun upgradeFail(code: Int, msg: String?) {
            Log.i("ota", "upgradeFail")

        }

        override fun upgradeProcess(process: Int) {
            Log.i("ota", "upgradeProcess")

        }

        override fun newVersion(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            Log.i("ota", "newVersion")

        }

        override fun noUpgrade() {
            Log.i("ota", "noUpgrade")

        }

        override fun confirmInstall(entity: com.midea.light.upgrade.entity.UpgradeResultEntity?) {
            Log.i("ota", "confirmInstall")
        }
    })
    OTAUpgradeHelper.initUserConfig("123", "123", "123", "123", 1)
    val channel = AppCommonConfig.getChannel()
    AppCommonConfig.init("development")
    Log.i("ota", "channel = $channel")
}

fun queryRomType() {
    OTAUpgradeHelper.queryUpgrade(UpgradeType.ROOM)
}