package com.midea.light.channel

import android.content.Context
import com.midea.light.channel.method.NetMethodChannel
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

class Channels {
    // Channel信使
    private lateinit var binaryMessenger: BinaryMessenger

    lateinit var netMethodChannel: NetMethodChannel

    private var isInit = false

    fun init(context: Context, binaryMessenger: BinaryMessenger) {
        if (!isInit) {
            this.binaryMessenger = binaryMessenger
            netMethodChannel = NetMethodChannel.create(CHANNEL_NAME_NET, binaryMessenger, context);
            isInit = true
        }
    }

}