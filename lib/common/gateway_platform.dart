
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
  /// 默认为NONE
  static GatewayPlatform platform = GatewayPlatform.NONE;

}

/// 切换平台Helper
/// 切换逻辑与初始化平台相关的统一写在此处
class ChangePlatformHelper {

  /// 切换到美居
  static void changeToMeiju(BuildContext context) async {
    MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
  }

  /// 切换到Homlux
  static void changeToHomlux(BuildContext context) async {
    MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
  }

}