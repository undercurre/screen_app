import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/channel/index.dart';

import '../../common/global.dart';

/// 设备管理SDK初始化器
mixin DeviceManagerSDKInitialize<T extends StatefulWidget> on State<T> {

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  @override
  void dispose() {
    super.dispose();
    resetSDK();
  }

  void initSDK() {
    /// 初始化入口，可重复初始化[幂等函数]
    deviceManagerChannel.init(
        dotenv.get("IOT_URL"),
        Global.user?.accessToken ?? "",
        dotenv.get("HTTP_SIGN_SECRET"),
        Global.user?.seed ?? "",
        Global.user?.key ?? "",
        Global.profile.deviceId ?? "",
        Global.user?.uid ?? "",
        dotenv.get("IOT_APP_COUNT"),
        dotenv.get("IOT_SECRET"),
        dotenv.get("IOT_REQUEST_HEADER_DATA_KEY")
    );
  }

  void resetSDK() {
    /// 重置SDK
    deviceManagerChannel.reset();
  }

}