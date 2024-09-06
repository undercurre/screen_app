import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/utils.dart';
import 'asb_channel.dart';

typedef ScreenStateCallback = void Function(bool);
typedef NearWakeupCallback = void Function(bool);

class SettingMethodChannel extends AbstractChannel{

  ScreenStateCallback? _screenStateCallback;
  NearWakeupCallback? _nearWakeupCallback;

  SettingMethodChannel.fromName(super.channelName) : super.fromName();
  
  set screenStateCallback(ScreenStateCallback? callback) {
    _screenStateCallback = callback;
  }

  set nearWakeupCallback(NearWakeupCallback? callback) {
    _nearWakeupCallback = callback;
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
      case "NearWakeupState":
        _nearWakeupCallback?.call(argument as bool);
        break;
    }
  }

  void registerNearWakeup() async {
    methodChannel.invokeListMethod("registerNearWakeup");
  }

  void unregisterNearWakeup() async {
    methodChannel.invokeListMethod("unregisterNearWakeup");
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
    LocalStorage.setItem("near_wake_up", value.toString());
    return true;
  }

  Future<bool> noticeNativeStandbySate(bool value) async {
    bool result =  await methodChannel.invokeMethod('NoticeNativeStandbySate', value);
    return result;
  }

  Future<bool> getNearWakeup() async {
    String? result = await LocalStorage.getItem("near_wake_up");
    if (result != null) {
      return bool.parse(result);
    }
    return false;
  }

  Future<bool> setScreenClose(bool close) async {
    return await methodChannel.invokeMethod("openOrCloseScreen", close) as bool;
  }

  Future<bool> getScreenOpenCloseState() async {
    return await methodChannel.invokeMethod('screenOpenCloseState') as bool;
  }

  void showLoading(String text) async {
      methodChannel.invokeMethod('showLoading',text);
  }

  void dismissLoading() async {
    methodChannel.invokeMethod('dismissLoading');
  }

}
