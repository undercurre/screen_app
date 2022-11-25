import 'dart:async';
import 'dart:ffi';
import './models/wifi_scan_result.dart';
import 'package:flutter/services.dart';

class NetMethodChannel {
  // 通道名称
  final String _channelName;

  // 构造器函数
  NetMethodChannel.fromName(this._channelName);

  late MethodChannel _NetMethodChannel = _initialMethodChannel();

  MethodChannel _initialMethodChannel() {
    var channel = MethodChannel(_channelName, const JSONMethodCodec());
    channel.setMethodCallHandler((call) => Future(() {
          final method = call.method;
          final args = call.arguments;
          switch (method) {
            case "replyNearbyWiFi":
              print("Android2 -> mehod $method");
              List<WiFiScanResult>? wifis = WiFiScanResult.scanResultListFromJsonArray(args as List<Map<String, dynamic>>);
              print(wifis?.length);
              print("Android1 -> mehod $method");
              break;
            default:
              throw Exception("没有支持的方法");
          }
        }));
    return channel;
  }

  // 启动扫描WiFi
  void scanNearbyWiFi() {
    _NetMethodChannel.invokeMethod("scanNearbyWiFi");
  }

  // 停止扫描WiFi
  void stopScanNearbyWiFi() {
    _NetMethodChannel.invokeMethod("stopScanNearbyWiFi");
  }

}
