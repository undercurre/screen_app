

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/platform_channel.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/index.dart';

import '../common/logcat_helper.dart';

class BuglyReportChannel extends AbstractChannel {

  BuglyReportChannel.fromName(super.channelName) : super.fromName();

  void report(String type, String message, String stack) async {
    Log.e(type, message);
    methodChannel.invokeMethod('postException', [
      type, message, stack.toString()
    ]);
  }

  void reportStack(String type, String message, StackTrace? stack) async {
    Log.e(type, message, stack);
    methodChannel.invokeMethod('postException', [
      type, message, stack?.toString()
    ]);
  }

  @override
  MethodChannel initialMethodChannel(String channelName) {
    debugPrint("初始化 $runtimeType ");
    var channel = MethodChannel(channelName, const StandardMethodCodec());
    // 持续性的数据上报，写到此处
    channel.setMethodCallHandler(onMethodCallHandler);
    return channel;
  }

  
}