
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

import '../widgets/event_bus.dart';

class GatewayChannel extends AbstractChannel {

  GatewayChannel.fromName(super.channelName) : super.fromName();

  /// 控制继电器开关一 开启
  Future<bool> controlRelay1Open(bool open) async {
    return await methodChannel.invokeMethod("controlRelay1Open", open) as bool;
  }
  /// 控制继电器开关二 开启
  Future<bool> controlRelay2Open(bool open) async {
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