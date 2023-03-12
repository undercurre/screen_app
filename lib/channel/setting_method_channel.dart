import 'dart:async';
import 'package:flutter/services.dart';

import 'asb_channel.dart';

typedef ScreenStateCallback = void Function(bool);

class SettingMethodChannel extends AbstractChannel{

  ScreenStateCallback? _screenStateCallback;

  SettingMethodChannel.fromName(super.channelName) : super.fromName();
  
  set screenStateCallback(ScreenStateCallback? callback) {
    _screenStateCallback = callback;
  }
  
  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    final methodName = call.method;
    final argument = call.arguments;
    switch(methodName) {
      case "broadcastScreenState":
        _screenStateCallback?.call(argument as bool);
        break;
    }
  }
  
  void registerScreenBroadcast() async {
    methodChannel.invokeMethod("registerScreenBroadcast");
  }
  
  void unRegisterScreenBroadcast() async {
    methodChannel.invokeMethod("unRegisterScreenBroadcast");
  }

  Future<num> setSystemVoice(num value) async {
    num result =  await methodChannel.invokeMethod('SettingMediaVoiceValue', value);
    return result;
  }

  Future<num> getSystemVoice() async {
    num result =  await methodChannel.invokeMethod('GettingMediaVoiceValue');
    return result;
  }

  Future<num> setSystemLight(num value) async {
    num result =  await methodChannel.invokeMethod('SettingLightValue', value);
    return result;
  }

  Future<num> getSystemLight() async {
    num result =  await methodChannel.invokeMethod('GettingLightValue');
    return result;
  }

  Future<bool> setAutoLight(bool value) async {
    bool result =  await methodChannel.invokeMethod('SettingAutoLight', value);
    return result;
  }

  Future<bool> getAutoLight() async {
    bool result =  await methodChannel.invokeMethod('GettingAutoLight');
    return result;
  }

  Future<bool> setNearWakeup(bool value) async {
    bool result =  await methodChannel.invokeMethod('SettingNearWakeup', value);
    return result;
  }

  Future<bool> noticeNativeStandbySate(bool value) async {
    bool result =  await methodChannel.invokeMethod('NoticeNativeStandbySate', value);
    return result;
  }

  Future<bool> getNearWakeup() async {
    bool result =  await methodChannel.invokeMethod('GettingNearWakeup');
    return result;
  }

  Future<bool> setScreenClose(bool close) async {
    return await methodChannel.invokeMethod("openOrCloseScreen", close) as bool;
  }

  Future<bool> getScreenOpenCloseState() async {
    return await methodChannel.invokeMethod('screenOpenCloseState') as bool;
  }

}
