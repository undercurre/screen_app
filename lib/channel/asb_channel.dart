
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class AbstractChannel {
  // 通道名称
  final String _channelName;

  // *****真正的通信Channel******
  late MethodChannel _MethodChannel;

  // 构造器函数
  AbstractChannel.fromName(this._channelName) {
    _MethodChannel = _initialMethodChannel();
  }

  MethodChannel get methodChannel => _MethodChannel;

  MethodChannel _initialMethodChannel() {
    debugPrint("初始化 ${this.runtimeType} ");
    var channel = MethodChannel(_channelName, const JSONMethodCodec());
    // 持续性的数据上报，写到此处
    channel.setMethodCallHandler(onMethodCallHandler);
    return channel;
  }

  // 接收原生请求
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    debugPrint('Method= ${call.method} arguments= ${call.arguments}');
  }


}