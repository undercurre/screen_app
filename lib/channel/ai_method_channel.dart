import 'dart:async';

import 'package:flutter/services.dart';
import 'package:screen_app/common/global.dart';

import 'models/music_state.dart';
import '../common/setting.dart';


class AiMethodChannel {
  // 通道名称
  final String _channelName;

  // 构造器函数
  AiMethodChannel.fromName(this._channelName);

  late final _aiChangeCallbacks = <void Function(AiMusicState)>[];
  late final _aiStateCallbacks = <void Function(int)>[];
  late final _aiInitFinishCallbacks = <void Function()>[];
  late final _aiAiSetVoiceCallbacks = <void Function(int)>[];
  late final _aiControlDeviceErrorCallbacks = <void Function()>[];





  late final MethodChannel _AiMethodChannel = _initialMethodChannel();

  MethodChannel _initialMethodChannel() {
    var channel = MethodChannel(_channelName, const JSONMethodCodec());
    channel.setMethodCallHandler((call) => Future(() {
          final method = call.method;
          final args = call.arguments;
          switch (method) {
            case "musicResult":
              AiMusicState musicState = AiMusicState.fromJson(args);
              transmitDataToAiChangeCallBack(musicState);
              break;
            case "aiWakeUpState":
              transmitDataToAiStatCallBack(args);
              break;
            case "AISetVoice":
              transmitDataToAiSetVoiceCallBack(args);
              break;
            case "AiControlDeviceError":
              transmitDataToAiControlDeviceErrorCallBack();
              break;
            case "AiInitFinish":
              transmitDataToAiInitFinishCallBack();
            default:
              throw Exception("没有支持的方法");
          }
        }));
    return channel;
  }

  Future<bool> initialAi(value) async {
    logger.i("初始化语音参数$value");
    bool result =  await _AiMethodChannel.invokeMethod('InitialAi',value);
    return result;
  }

  Future<bool> wakeUpAi() async {
    bool result =  await _AiMethodChannel.invokeMethod('WakeUpAi');
    return result;
  }

  Future<bool> enableAi(value) async {
    bool result =  await _AiMethodChannel.invokeMethod('EnableAi', value);
    return result;
  }

  Future<bool> setFullDuplex(value) async {
    bool result =  await _AiMethodChannel.invokeMethod('SetFullDuplex', value);
    Setting.instant().aiDuplexModeFullDuplex = result;
    return result;
  }

  Future<String> aes128Encode(String value,String seed) async {
    String result =  await _AiMethodChannel.invokeMethod('Aes128Encode', {"data":value,"seed":seed});
    return result;
  }

  Future<String> musicStart() async {
    String result =  await _AiMethodChannel.invokeMethod('AiMusicStart');
    return result;
  }

  Future<String> musicPause() async {
    String result =  await _AiMethodChannel.invokeMethod('AiMusicPause');
    return result;
  }

  Future<String> musicPrev() async {
    String result =  await _AiMethodChannel.invokeMethod('AiMusicPrevious');
    return result;
  }

  Future<String> stopAi() async {
    String result = await _AiMethodChannel.invokeMethod('StopAi');
    return result;
  }

  Future<String> musicNext() async {
    String result =  await _AiMethodChannel.invokeMethod('AiMusicNext');
    return result;
  }

  Future<bool> musicIsPaying() async {
      bool result =  await _AiMethodChannel.invokeMethod('AiMusicIsPlaying');
    return result;
  }

  Future<bool> musicInforGet() async {
    bool result =  await _AiMethodChannel.invokeMethod('AiMusicInforGet');
    return result;
  }

  // 注册回调
  void registerAiCallBack(
      void Function(AiMusicState) action) {
    if (!_aiChangeCallbacks.contains(action)) {
      _aiChangeCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterAiCallBack(
      void Function(AiMusicState) action) {
    final position = _aiChangeCallbacks.indexOf(action);
    if (position != -1) {
      _aiChangeCallbacks.remove(action);
    }
  }

  void registerAiInitFinishCallBack(void Function() action) {
    if (!_aiInitFinishCallbacks.contains(action)) {
      _aiInitFinishCallbacks.add(action);
    }
  }

  void unregisterAiInitFinishCallBack(void Function() action) {
    final position = _aiInitFinishCallbacks.indexOf(action);
    if (position != -1) {
      _aiInitFinishCallbacks.remove(action);
    }
  }

  // 注册回调
  void registerAiStateCallBack(
      void Function(int) action) {
    if (!_aiStateCallbacks.contains(action)) {
      _aiStateCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterAiStateCallBack(
      void Function(int) action) {
    final position = _aiStateCallbacks.indexOf(action);
    if (position != -1) {
      _aiStateCallbacks.remove(action);
    }
  }

  // 注册回调
  void registerAiSetVoiceCallBack (
      void Function(int) action) {
    if (!_aiAiSetVoiceCallbacks.contains(action)) {
      _aiAiSetVoiceCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterAiSetVoiceCallBack(
      void Function(int) action) {
    final position = _aiAiSetVoiceCallbacks.indexOf(action);
    if (position != -1) {
      _aiAiSetVoiceCallbacks.remove(action);
    }
  }

  // 注册回调
  void registerAiControlDeviceErrorCallBack (
      void Function() action) {
    if (!_aiControlDeviceErrorCallbacks.contains(action)) {
      _aiControlDeviceErrorCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterAiControlDeviceErrorCallBack(
      void Function() action) {
    final position = _aiControlDeviceErrorCallbacks.indexOf(action);
    if (position != -1) {
      _aiControlDeviceErrorCallbacks.remove(action);
    }
  }

  void transmitDataToAiChangeCallBack(AiMusicState state) {
    for (var callback in _aiChangeCallbacks) {
      callback.call(state);
    }
  }

  void transmitDataToAiStatCallBack(int state) {
    for (var callback in _aiStateCallbacks) {
      callback.call(state);
    }
  }

  void transmitDataToAiSetVoiceCallBack(int voice) {
    for (var callback in _aiAiSetVoiceCallbacks) {
      callback.call(voice);
    }
  }

  void transmitDataToAiControlDeviceErrorCallBack() {
    for (var callback in _aiControlDeviceErrorCallbacks) {
      callback.call();
    }
  }

  void transmitDataToAiInitFinishCallBack() {
    for (var callback in _aiInitFinishCallbacks) {
      callback.call();
    }
  }

}
