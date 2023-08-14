
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/system.dart';

import 'adapter/ai_data_adapter.dart';

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

  /// 检查网关运行的环境
  /// 返回值 0NONE 1美居 2美的照明
  static Future<int> checkGatewayPlatform() async {
    return gatewayChannel.checkGatewayPlatform();
  }

  /// 设置网关运行环境为美的照明，但子设备不会清空。为了兼容ota升级之后，恢复用户身份登录
  Future<bool> setMeijuPlatFormFlag() async {
    return gatewayChannel.setMeijuPlatFormFlag();
  }


  /// 切换到美居
  /// gatewaySubDeviceDel 参数含义：是否要将网关子设备清空
  static Future<bool> changeToMeiju([bool gatewaySubDeviceDel = true]) async {
    if(gatewaySubDeviceDel) {
      bool suc = await gatewayChannel.setMeijuPlatform();
      if(suc) {
        HomluxGlobal.setLogout();
        MeiJuApi.init();
        System.initForMeiju();
        AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
        MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
      }
      return suc;
    } else {
      HomluxGlobal.setLogout();
      MeiJuApi.init();
      System.initForMeiju();
      AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
      MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
      return true;
    }
  }

  /// 切换到Homlux
  /// gatewaySubDeviceDel 参数含义：是否要将网关子设备清空
  static Future<bool> changeToHomlux([bool gatewaySubDeviceDel = true]) async {
    if(gatewaySubDeviceDel) {
      bool suc = await gatewayChannel.setHomluxPlatForm();
      if(suc) {
        MeiJuGlobal.setLogout();
        HomluxApi.init();
        System.initForHomlux();
        AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
        MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
      }
      return suc;
    } else {
      MeiJuGlobal.setLogout();
      HomluxApi.init();
      System.initForHomlux();
      AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
      MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
      return true;
    }

  }

}