

import 'package:flutter/services.dart';
import 'package:screen_app/common/index.dart';

import '../common/logcat_helper.dart';
import 'asb_channel.dart';


typedef MqttCallback = void Function(String topic, String msg);

typedef LogCallback = void Function(String log);

class LanDeviceControlChannel extends AbstractChannel {

  MqttCallback? mqttCallback;

  LogCallback? logCallback;

  LanDeviceControlChannel.fromName(super.channelName) : super.fromName();


  @override
  Future onMethodCallHandler(MethodCall call) async {

    super.onMethodCallHandler(call);

    String methodName = call.method;

    switch(methodName) {
      case 'mqttHandler':
        Map<String, dynamic>? map = call.arguments as Map<String, dynamic>?;
        String? topic = map?['topic'];
        String? msg = map?['msg'];
        Log.file('HomeOs 接收到mqtt数据 topic= $topic \n msg= $msg');
        if(StrUtils.isNotNullAndEmpty(topic) && StrUtils.isNotNullAndEmpty(msg)) {
          mqttCallback?.call(topic!, msg!);
        }
        break;
      case 'log':
        Map<String, dynamic>? map = call.arguments as Map<String, dynamic>?;
        String? msg = map?['msg'];
        Log.file('HomeOs 接收到日志数据 msg= $msg');
        if(StrUtils.isNotNullAndEmpty(msg)) {
          logCallback?.call(msg!);
        }
        break;
    }
  }

  /// ******************
  /// 初始化局域网控制
  /// *******************
  void init() {
    methodChannel.invokeMethod('init');
  }

  /// ******************
  /// 尝试登录
  /// *******************
  void login(String homeId, String key) {
    methodChannel.invokeMethod('login', {
      'homeId': homeId,
      'key': key
    });
  }

  /// ******************
  /// 退出局域网控制
  /// *******************
  void logout() {
    methodChannel.invokeMethod('logout');
  }

  /// ******************
  /// 请求获取设备列表
  /// *******************
  void getDeviceInfo() {
    methodChannel.invokeMethod('getDeviceInfo');
  }

  /// ******************
  /// 请求获取具体的设备状态
  /// *******************
  void getDeviceStatus(String? deviceId) {
    methodChannel.invokeMethod('getDeviceStatus', {
      'deviceId': deviceId
    });
  }

  /// ******************
  /// 行局域网设备控制
  /// *******************
  void deviceControl(String deviceId, Map<String, dynamic> action) {
    methodChannel.invokeMethod('deviceControl', {
      'deviceId': deviceId,
      'action': action
    });
  }

  /// ******************
  /// 获取灯组信息
  /// *******************
  void getGroupInfo() {
    methodChannel.invokeMethod('getGroupInfo');
  }

  /// ******************
  /// 灯组控制
  /// *******************
  void groupControl(int deviceId, Map<String, dynamic> action) {
    methodChannel.invokeMethod('groupControl', {
        'deviceId': deviceId,
        'action': action
    });
  }

  /// ******************
  /// 获取场景列表
  /// *******************
  void getSceneInfo() {
    methodChannel.invokeMethod('getSceneInfo');
  }

  /// ******************
  /// 场景执行
  /// *******************
  void sceneExcute(String sceneId) {
    methodChannel.invokeMethod('sceneExcute', {
      'sceneId': sceneId
    });
  }

}