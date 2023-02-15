import 'dart:async';

import 'package:flutter/services.dart';

class SettingMethodChannel {
  // 通道名称
  final String _channelName;

  // 构造器函数
  SettingMethodChannel.fromName(this._channelName);

  late final MethodChannel _SettingMethodChannel = _initialMethodChannel();

  MethodChannel _initialMethodChannel() {
    var channel = MethodChannel(_channelName, const JSONMethodCodec());
    channel.setMethodCallHandler((call) => Future(() {
          final method = call.method;
          final args = call.arguments;
          switch (method) {
            case "replySystemVoice":

              break;
            default:
              throw Exception("没有支持的方法");
          }
        }));
    return channel;
  }

  Future<num> setSystemVoice(num value) async {
    num result =  await _SettingMethodChannel.invokeMethod('SettingMediaVoiceValue', value);
    return result;
  }

  Future<num> getSystemVoice() async {
    num result =  await _SettingMethodChannel.invokeMethod('GettingMediaVoiceValue');
    return result;
  }

  Future<num> setSystemLight(num value) async {
    num result =  await _SettingMethodChannel.invokeMethod('SettingLightValue', value);
    return result;
  }

  Future<num> getSystemLight() async {
    num result =  await _SettingMethodChannel.invokeMethod('GettingLightValue');
    return result;
  }

  Future<bool> setAutoLight(bool value) async {
    bool result =  await _SettingMethodChannel.invokeMethod('SettingAutoLight', value);
    return result;
  }

  Future<bool> getAutoLight() async {
    bool result =  await _SettingMethodChannel.invokeMethod('GettingAutoLight');
    return result;
  }

  Future<bool> setNearWakeup(bool value) async {
    bool result =  await _SettingMethodChannel.invokeMethod('SettingNearWakeup', value);
    return result;
  }

  Future<bool> getNearWakeup() async {
    bool result =  await _SettingMethodChannel.invokeMethod('GettingNearWakeup');
    return result;
  }

  Future<bool> setScreenClose(bool close) async {
    return await _SettingMethodChannel.invokeMethod("openOrCloseScreen", close) as bool;
  }

  Future<bool> getScreenOpenCloseState() async {
    return await _SettingMethodChannel.invokeMethod('screenOpenCloseState') as bool;
  }

}
