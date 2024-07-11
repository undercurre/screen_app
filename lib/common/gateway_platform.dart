
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/system.dart';
import 'package:screen_app/common/utils.dart';
import 'package:screen_app/states/layout_notifier.dart';

import 'adapter/ai_data_adapter.dart';
import 'adapter/push_data_adapter.dart';
import 'homlux/api/homlux_user_api.dart';
import 'homlux/lan/homlux_lan_control_device_manager.dart';
import 'logcat_helper.dart';
import 'meiju/api/meiju_device_api.dart';

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
  /// 在美居平台
  static bool inMeiJu() => platform == GatewayPlatform.MEIJU;
  /// 在Homlux平台
  static bool inHomlux() => platform == GatewayPlatform.HOMLUX;
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
        try {
          try {
            if(HomluxGlobal.isLogin) { // 刪除Homlux设备
              int count = 3;
              while(count > 0) {
                var result = await HomluxUserApi.deleteDevices([
                  {
                    'deviceId': HomluxGlobal.gatewayApplianceCode ?? '',
                    'deviceType': '1'
                  }
                ]);
                count --;
                if(result.isSuccess) {
                  break;
                }
              }
            }
          } on Exception catch(e, trace) {
            Log.file('删除屏失败', e, trace);
          }
          HomluxGlobal.setLogout("从Homlux切换到美居平台");
          MeiJuApi.init();
          await System.initForMeiju();
          AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
          PushDataAdapter(MideaRuntimePlatform.platform).stopConnect();
          // 删除本地所有缓存
          LocalStorage.clearAllData();
          LayoutModel.removeLayoutStorage();
        } on Exception catch(e) {
          Log.file(e.toString());
        } finally {
          MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
        }
      }
      return suc;
    } else {
      try {
        HomluxGlobal.setLogout("从Homlux切换到美居平台");
        MeiJuApi.init();
        await System.initForMeiju();
        AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
        PushDataAdapter(MideaRuntimePlatform.platform).stopConnect();
      } catch(e) {
        Log.file(e.toString());
      } finally {
        MideaRuntimePlatform.platform = GatewayPlatform.MEIJU;
      }
      return true;
    }
  }

  /// 切换到Homlux
  /// gatewaySubDeviceDel 参数含义：是否要将网关子设备清空
  static Future<bool> changeToHomlux([bool gatewaySubDeviceDel = true]) async {
    if(gatewaySubDeviceDel) {
      bool suc = await gatewayChannel.setHomluxPlatForm();
      if(suc) {
        try {
          try {
            if(MeiJuGlobal.isLogin) { //删除屏设备
              int count = 3;
              while(count > 0) {
                var result = await MeiJuDeviceApi.deleteDevices(
                    [MeiJuGlobal.gatewayApplianceCode ?? ''],
                    System.familyInfo?.familyId ?? '');
                count --;
                if(result.isSuccess){
                  break;
                }
              }
            }
          } on Exception catch(e, trace) {
            Log.file('删除屏失败', e, trace);
          }

          MeiJuGlobal.setLogout("从Meiju切换到Homlux平台");
          HomluxApi.init();
          await System.initForHomlux();
          AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
          PushDataAdapter(MideaRuntimePlatform.platform).stopConnect();
          HomluxLanControlDeviceManager.getInstant().init();
          LayoutModel.removeLayoutStorage();
          // 删除本地所有缓存
          LocalStorage.clearAllData();
        } on Exception catch(e) {
          Log.file(e.toString());
        } finally {
          MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
        }
      }
      return suc;
    } else {
      try {
        MeiJuGlobal.setLogout("从Meiju切换到Homlux平台");
        HomluxApi.init();
        await System.initForHomlux();
        AiDataAdapter(MideaRuntimePlatform.platform).stopAiVoice();
        PushDataAdapter(MideaRuntimePlatform.platform).stopConnect();
        HomluxLanControlDeviceManager.getInstant().init();
      } on Exception catch(e) {
        Log.file(e.toString());
      } finally {
        MideaRuntimePlatform.platform = GatewayPlatform.HOMLUX;
      }
      return true;
    }

  }

}