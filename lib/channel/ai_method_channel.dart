import 'dart:async';
import 'package:flutter/services.dart';

import 'models/music_state.dart';

class AiMethodChannel {
  // 通道名称
  final String _channelName;

  // 构造器函数
  AiMethodChannel.fromName(this._channelName);

  late final _aiChangeCallbacks = <void Function(AiMusicState)>[];


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
            default:
              throw Exception("没有支持的方法");
          }
        }));
    return channel;
  }

  Future<bool> initialAi(value) async {
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

  void transmitDataToAiChangeCallBack(AiMusicState state) {
    for (var callback in _aiChangeCallbacks) {
      callback.call(state);
    }
  }

}
