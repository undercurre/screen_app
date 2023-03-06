package com.midea.light.channel

import ManagerDeviceChannel
import android.app.Application
import android.content.Context

import com.midea.light.channel.method.*
import io.flutter.plugin.common.BinaryMessenger

/**
 * @ClassName Channels
 * @Description TODO
 * @Author weinp1
 * @Date 2022/11/21 17:20
 * @Version 1.0
 */
// 网络相关的Channel
const val CHANNEL_NAME_NET = "com.midea.light/net"
const val CHANNEL_NAME_SETTING = "com.midea.light/set"
const val CHANNEL_NAME_AI = "com.midea.light/ai"


const val CHANNEL_NAME_ABOUT = "com.midea.light/about"
const val CHANNEL_CONFIG = "com.midea.light/config"
const val CHANNEL_OTA = "com.midea.light/ota"
const val CHANNEL_MANAGER_DEVICES = "com.midea.light/deviceManager"
const val CHANNEL_GATEWAY = "com.midea.light/gateway";
const val CHANNEL_BUGLY = "com.midea.light/bugly"
const val CHANNEL_ALI_PUSH = "com.midea.light/push"
const val CHANNEL_MIGRATE = "com.midea.light/migrate"

class Channels {
    // Channel信使
    private lateinit var binaryMessenger: BinaryMessenger

    lateinit var netMethodChannel: NetMethodChannel
    lateinit var settingMethodChannel: SettingMethodChannel
    lateinit var aiMethodChannel: AiMethodChannel


    lateinit var aboutMethodChannel: AboutMethodChannel
    lateinit var configChannel: ConfigChannel
    lateinit var otaChannel: OtaChannel
    lateinit var managerDeviceChannel: ManagerDeviceChannel
    lateinit var gatewayChannel: GatewayChannel
    lateinit var aliPushChannel: AliPushChannel
    lateinit var buglyReportChannel: BuglyReportChannel
    lateinit var migrateChannel: MigrationDataChannel

    private var isInit = false

    fun init(context: Context, binaryMessenger: BinaryMessenger) {
        if (!isInit) {
            this.binaryMessenger = binaryMessenger
            netMethodChannel = NetMethodChannel.create(CHANNEL_NAME_NET, binaryMessenger, context)
            settingMethodChannel = SettingMethodChannel.create(CHANNEL_NAME_SETTING, binaryMessenger, context)
            aiMethodChannel = AiMethodChannel.create(CHANNEL_NAME_AI, binaryMessenger, context)
            netMethodChannel = NetMethodChannel.create(CHANNEL_NAME_NET, binaryMessenger, context)
            aboutMethodChannel = AboutMethodChannel.create(CHANNEL_NAME_ABOUT, binaryMessenger, context)
            configChannel = ConfigChannel.create(CHANNEL_CONFIG, binaryMessenger, context)
            otaChannel = OtaChannel.create(CHANNEL_OTA, binaryMessenger, context)
            managerDeviceChannel = ManagerDeviceChannel.create(CHANNEL_MANAGER_DEVICES, binaryMessenger, context)
            gatewayChannel = GatewayChannel.create(CHANNEL_GATEWAY, binaryMessenger, context)
            aliPushChannel = AliPushChannel.create(CHANNEL_ALI_PUSH,binaryMessenger,context)
            buglyReportChannel = BuglyReportChannel.create(CHANNEL_BUGLY, binaryMessenger, context)
            migrateChannel = MigrationDataChannel.create(CHANNEL_MIGRATE, binaryMessenger, context)
            isInit = true
        }
    }

}