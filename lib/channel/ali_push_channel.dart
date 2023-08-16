import 'dart:async';

import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';

import '../common/logcat_helper.dart';
import '../common/meiju/push/meiju_push_manager.dart';

class AliPushMethodChannel extends AbstractChannel{
  // 构造器函数
  AliPushMethodChannel.fromName(super.channelName) : super.fromName();

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    switch (call.method) {
      case "notifyPushMessage":
        onHandlerNotifyPushMessage(call.arguments);
        break;
    }
  }

  Future<String> getDeviceId() async {
    String result =  await methodChannel.invokeMethod('getAliPushDeviceId');
    return result;
  }

  void onHandlerNotifyPushMessage(dynamic arguments) async {
    String title = arguments;
    Log.i("aliPushLog rev $title");
    MeiJuPushManager.notifyPushMessage(title);
  }
}