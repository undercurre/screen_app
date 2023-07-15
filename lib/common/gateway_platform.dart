
import 'package:flutter/material.dart';

/// 定义网关运行环境
enum GatewayPlatform {
  NONE,           /// 空
  MEIJU,          /// 美居
  HOMLUX;         /// 美的照明

  bool inMeiju() {
    return this == MEIJU;
  }

  bool inHomlux() {
    return this == HOMLUX;
  }
}

/// 网关环境切换通知
class MideaRuntimePlatform extends ChangeNotifier {
  GatewayPlatform platform = GatewayPlatform.NONE;

  void setPlatform(GatewayPlatform platform) {
    this.platform = platform;
    notifyListeners();
  }

}