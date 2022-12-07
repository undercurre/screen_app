import 'dart:async';
import 'package:screen_app/channel/models/net_state.dart';

import './models/wifi_scan_result.dart';
import 'package:flutter/services.dart';

class NetMethodChannel {
  // 通道名称
  final String _channelName;

  // 构造器函数
  NetMethodChannel.fromName(this._channelName);

  // 储存扫描附近wifi结果的回调
  late final _nearbyWiFiCallbacks = <void Function(List<WiFiScanResult>)>[];
  // 存储监听网络状态变化的回调
  late final _netChangeCallbacks = <void Function(NetState)>[];

  // *****真正的通信Channel******
  late final MethodChannel _netMethodChannel = _initialMethodChannel();

  MethodChannel _initialMethodChannel() {
    var channel = MethodChannel(_channelName, const JSONMethodCodec());
    // 持续性的数据上报，写到此处
    channel.setMethodCallHandler((call) => Future(() {
          final method = call.method;
          final args = call.arguments;
          switch (method) {
            case "replyNearbyWiFi":
              List<WiFiScanResult>? wifis = WiFiScanResult.scanResultListFromJsonArray(args);
              transmitDataToNearbyWiFiCallBack(wifis);
              break;
            case "replyConnectChange":
              NetState netState = NetState.fromJson(args);
              transmitDataToNetChangeCallBack(netState);
              break;
            default:
              throw Exception("没有支持的方法");
          }
        }));
    return channel;
  }

  void transmitDataToNetChangeCallBack(NetState state) {
    for (var callback in _netChangeCallbacks) {
      callback.call(state);
    }
  }

  void transmitDataToNearbyWiFiCallBack(List<WiFiScanResult>? list) {
    // 如果为空，暂时不考虑传递到界面，进行渲染
    if (list != null && list.isNotEmpty) {
      for (var callback in _nearbyWiFiCallbacks) {
        callback.call(list);
      }
    }
  }


  // 注册回调
  void registerScanWiFiCallBack(
      void Function(List<WiFiScanResult> list) action) {
    if (!_nearbyWiFiCallbacks.contains(action)) {
      _nearbyWiFiCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterScanWiFiCallBack(
      void Function(List<WiFiScanResult> list) action) {
    final position = _nearbyWiFiCallbacks.indexOf(action);
    if (position != -1) {
      _nearbyWiFiCallbacks.remove(action);
    }
  }

  // 注册回调
  void registerNetChangeCallBack(
      void Function(NetState state) action) {
    if (!_netChangeCallbacks.contains(action)) {
      _netChangeCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterNetChangeCallBack(
      void Function(NetState state) action) {
    final position = _netChangeCallbacks.indexOf(action);
    if (position != -1) {
      _netChangeCallbacks.remove(action);
    }
  }

  Future<bool> connectedWiFi(String ssid, String pwd, bool changePwd) async {
    try {
     bool connected = await _netMethodChannel.invokeMethod('connectWiFi', {'ssid': ssid, 'pwd': pwd, 'changePwd': changePwd});
     return connected;
    } on PlatformException catch(e) {
      return false;
    }
  }

  Future<bool> enableEthernet(bool enable) async {
    bool result =  await _netMethodChannel.invokeMethod('enableEthernet', {'enable': enable});
    return result;
  }

  Future<bool> enableWiFi(bool enable) async {
    bool result =  await _netMethodChannel.invokeMethod('enableWiFi', {'enable': enable});
    return result;
  }

  // 返回的结果bool
  Future<bool> supportWiFiControl() async {
    bool support =  await  _netMethodChannel.invokeMethod('supportWiFiControl');
    return support;
  }

  // 返回的是bool
  Future<bool> supportEthernetControl() async {
    bool support =  await _netMethodChannel.invokeMethod('supportEthernetControl');
    return support;
  }

  // 启动观察网络连接状态
  void startObserverNetState() {
    _netMethodChannel.invokeMethod("listenerConnectState");
  }
  // 关闭观察网络连接状态
  void stopObserverNetState() {
    _netMethodChannel.invokeMethod("removeListenerConnectState");
  }

  // 启动扫描WiFi
  void scanNearbyWiFi() {
    _netMethodChannel.invokeMethod("scanNearbyWiFi");
  }

  // 停止扫描WiFi
  void stopScanNearbyWiFi() {
    _netMethodChannel.invokeMethod("stopScanNearbyWiFi");
  }

}
