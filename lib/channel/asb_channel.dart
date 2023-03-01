
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class AbstractChannel {
  // 通道名称
  final String _channelName;

  // *****真正的通信Channel******
  late MethodChannel _MethodChannel;

  // 构造器函数
  AbstractChannel.fromName(this._channelName) {
    _MethodChannel = initialMethodChannel(_channelName);
    /// 2023/2/6 新增从初始化方法
    try {
      initChannel();
    } on Exception catch(e) {
      debugPrint(e.toString());
    }
  }

  MethodChannel get methodChannel => _MethodChannel;

  @protected
  MethodChannel initialMethodChannel(String channelName) {
    debugPrint("初始化 $runtimeType ");
    var channel = MethodChannel(channelName, const JSONMethodCodec());
    // 持续性的数据上报，写到此处
    channel.setMethodCallHandler(onMethodCallHandler);
    return channel;
  }

  @mustCallSuper
  void initChannel() {}

  // 接收原生请求
  @mustCallSuper
  @protected
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    debugPrint('Method= ${call.method} arguments= ${call.arguments}');
  }


}