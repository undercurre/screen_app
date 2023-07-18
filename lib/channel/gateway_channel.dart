
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

import '../common/logcat_helper.dart';
import '../widgets/event_bus.dart';

class GatewayChannel extends AbstractChannel {

  GatewayChannel.fromName(super.channelName) : super.fromName();

  /// 控制继电器开关一 开启
  Future<bool> controlRelay1Open(bool open) async {
    Log.i('继电器1操作', open);
    return await methodChannel.invokeMethod("controlRelay1Open", open) as bool;
  }
  /// 控制继电器开关二 开启
  Future<bool> controlRelay2Open(bool open) async {
    Log.i('继电器2操作');
    return await methodChannel.invokeMethod("controlRelay2Open", open) as bool;
  }
  /// 判断寄电器1是否打开
  Future<bool> relay1IsOpen() async {
    return await methodChannel.invokeMethod("relay1IsOpen") as bool;
  }
  /// 判断寄电器2是否打开
  Future<bool> relay2IsOpen() async {
    return await methodChannel.invokeMethod("relay2IsOpen") as bool;
  }
  /// 允许连入
  Future<bool> broadcastAllowLink() async {
    methodChannel.invokeMethod('allowLink');
    return true;
  }
  /// 重置本地网关
  Future<bool> resetGateway() async {
    methodChannel.invokeMethod('resetGateway');
    return true;
  }
  /// 检查当前运行的环境
  /// 返回值 0NONE 1美居 2美的照明
  Future<int> checkGatewayPlatform() async {
    return methodChannel.invokeMethod('checkGatewayPlatform') as int;
  }
  /// 设置网关运行环境为美居平台, 会导致子设备清空
  Future<bool> setMeijuPlatform() async {
    return methodChannel.invokeMethod('setMeijuPlatform') as bool;
  }
  /// 设置网关运行环境为美的照明，会导致子设备清空
  Future<bool> setHomluxPlatForm() async {
    return methodChannel.invokeMethod('setHomluxPlatForm') as bool;
  }
  /// 设置网关运行环境为美的照明，但子设备不会清空。为了兼容ota升级之后，恢复用户身份登录
  Future<bool> setMeijuPlatFormFlag() async {
    return methodChannel.invokeMethod('setMeijuPlatFormFlag') as bool;
  }


  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    final methodName = call.method;

    switch(methodName) {
      case "relay1Report":
        /// 通过事件总线通知继电器状态改变
        bus.emit("relay1StateChange", call.arguments as bool);
        break;
      case "relay2Report":
        /// 通过事件总线通知继电器状态改变
        bus.emit("relay2StateChange", call.arguments as bool);
        break;
    }

  }

}