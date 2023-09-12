import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/gateway_platform.dart';

import '../../common/meiju/meiju_global.dart';
import '../../common/system.dart';
/// 设备管理SDK初始化器
mixin DeviceManagerSDKInitialize<T extends StatefulWidget> on State<T> {

  @override
  void initState() {
    super.initState();
    initDeviceSDK();
  }

  @override
  void dispose() {
    super.dispose();
    resetDeviceSDK();
  }

  void initDeviceSDK() {
    /// 初始化入口，可重复初始化[幂等函数]
    if(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      if(MeiJuGlobal.isLogin) {
        deviceManagerChannel.init(
            dotenv.get("IOT_URL"),
            MeiJuGlobal.token?.accessToken ?? "",
            dotenv.get("HTTP_SIGN_SECRET"),
            MeiJuGlobal.token?.seed ?? "",
            MeiJuGlobal.token?.key ?? "",
            System.deviceId ?? "",
            MeiJuGlobal.token?.uid ?? "",
            dotenv.get("IOT_APP_COUNT"),
            dotenv.get("IOT_SECRET"),
            dotenv.get("IOT_REQUEST_HEADER_DATA_KEY")
        );
      }
    }

  }

  void resetDeviceSDK() {
    /// 重置SDK
    deviceManagerChannel.reset();
  }

}