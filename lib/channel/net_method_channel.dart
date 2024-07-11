import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/channel/models/net_state.dart';

import '../common/logcat_helper.dart';
import '../widgets/event_bus.dart';
import './models/wifi_scan_result.dart';

class NetMethodChannel extends AbstractChannel {

  // 构造器函数
  NetMethodChannel.fromName(super.channelName) : super.fromName();

  // 储存扫描附近wifi结果的回调
  late final _nearbyWiFiCallbacks = <void Function(List<WiFiScanResult>)>[];
  // 存储监听网络状态变化的回调
  late final _netChangeCallbacks = <void Function(NetState)>[];
  // 存储网络是否可用的回调
  late final _netAvailableCallbacks = <void Function(bool)>[];
  // *****当前的网络状态*********
  late NetState _currentNetState = NetState();
  // 获取当前设备网络状态
  NetState get currentNetState => _currentNetState;
  // 网络状态是否可用
  bool netAvailable = false;


  @override
  void initChannel() {
    super.initChannel();
    startObserverNetState();
    bus.on('net-available', (arg) {
      Log.file('[网络] 可用');
      if(netAvailable == false) {
        netAvailable = true;
        transmitDataToNetAvailableChangeCallBack(true);
      }
    });
    bus.on('net-unavailable', (arg) {
      Log.file('[网络] 不可用');
      if(netAvailable == true) {
        netAvailable = false;
        transmitDataToNetAvailableChangeCallBack(false);
      }
    });
  }

  // 接收原生请求
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    // debugPrint('Method= ${call.method} arguments= ${call.arguments}');
    final method = call.method;
    final args = call.arguments;
    switch (method) {
      case "replyNearbyWiFi":
        List<WiFiScanResult>? wifis = WiFiScanResult.scanResultListFromJsonArray(args);
        transmitDataToNearbyWiFiCallBack(wifis);
        break;
      case "replyConnectChange":
        Log.develop("[网络] 接收到replyConnectChange");
        // Log.develop("[网络] 接收到replyConnectChange ${jsonEncode(args)} ${jsonEncode(currentNetState.toJson())}");
        NetState netState = NetState.fromJson(args);
        if(currentNetState.ethernetState == netState.ethernetState
            && currentNetState.wifiState == netState.wifiState
            && currentNetState.wiFiScanResult == netState.wiFiScanResult) {
          Log.develop('[网络] 网络状态无变化');
        } else {
          Log.develop('[网络] 通知网络发生更改');
          _currentNetState = netState;
          transmitDataToNetChangeCallBack(netState);
        }
        break;
      default:
        throw Exception("没有支持的方法");
    }
  }

  void transmitDataToNetAvailableChangeCallBack(bool available) {
    for(var callback in _netAvailableCallbacks) {
      try {
        callback.call(available);
      } catch (e) {
        Log.e("Caught exception $e");
      }
    }
  }


  void transmitDataToNetChangeCallBack(NetState state) {
    for (var callback in _netChangeCallbacks) {
      try {
        callback.call(state);
      } catch (e) {
        Log.e("Caught exception $e");
      }
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

  // 查询当前的网络状态。结果以上面回调的形式返回
  void checkNetState() async {
    methodChannel.invokeMethod('checkNetState');
  }

  /// 注销回调
  /// [action] action为空，则会清空所有的监听方法
  void unregisterScanWiFiCallBack(
      void Function(List<WiFiScanResult> list)? action) {
    if(action == null) {
      _nearbyWiFiCallbacks.clear();
    } else {
      final position = _nearbyWiFiCallbacks.indexOf(action);
      if (position != -1) {
        _nearbyWiFiCallbacks.remove(action);
      }
    }
  }

  // 注册回调
  void registerNetAvailableChangeCallBack(void Function(bool available) action) {
    if (!_netAvailableCallbacks.contains(action)) {
      _netAvailableCallbacks.add(action);
      action.call(netAvailable);
    }
  }

  /// 注销回调
  /// [action] action为空，则会清空所有的监听方法
  void unregisterNetAvailableChangeCallBack(void Function(bool available)? action) {
    if(action == null) {
      _netAvailableCallbacks.clear();
    } else {
      final position = _netAvailableCallbacks.indexOf(action);
      if (position != -1) {
        _netAvailableCallbacks.remove(action);
      }
    }
  }

  // 注册回调
  void registerNetChangeCallBack(void Function(NetState state) action) {
    if (!_netChangeCallbacks.contains(action)) {
      _netChangeCallbacks.add(action);
      action.call(currentNetState);
    }
  }

  /// 注销回调
  /// [action] action为空，则会清空所有的监听方法
  void unregisterNetChangeCallBack(void Function(NetState state)? action) {
    if(action == null) {
      _netChangeCallbacks.clear();
    } else {
      final position = _netChangeCallbacks.indexOf(action);
      if (position != -1) {
        _netChangeCallbacks.remove(action);
      }
    }
  }

  Future<bool> connectedWiFi(String ssid, String? pwd, bool changePwd) async {
    try {
     bool connected = await methodChannel.invokeMethod('connectWiFi',
         {'ssid': ssid,
           if(pwd != null) 'pwd': pwd,
           'changePwd': changePwd
         });
     return connected;
    } on PlatformException {
      return false;
    }
  }

  /// 查询当前连接的wifi本地记录
  Future<ConnectedWiFiRecord?> checkConnectedWiFiRecord() async {
    try {
      final result = await methodChannel.invokeMethod('checkConnectWiFiInfo');
      return ConnectedWiFiRecord.fromJson(result);
    } on PlatformException catch(e) {
      debugPrint(e.message);
    }
    return null;
  }

  // 忘记掉已经连接的WiFi
  Future<bool> forgetWiFi(String ssid, String bssid) async {
    bool result = await methodChannel.invokeMethod('forgetWiFi', {'ssid': ssid, 'bssid': bssid});
    return result;
  }

  /// wifi是否打开
  Future<bool> wifiIsOpen() async {
    var result = await supportWiFiControl();
    if(!result) return false;
    result = await methodChannel.invokeMethod('wifiIsOpen');
    return result;
  }

  /// 有线以太网是否打开
  Future<bool> ethernetIsOpen() async {
    var result = await supportEthernetControl();
    if(!result) return false;
    result = await methodChannel.invokeMethod('ethernetIsOpen');
    return result;
  }

  Future<bool> enableEthernet(bool enable) async {
    bool result =  await methodChannel.invokeMethod('enableEthernet', {'enable': enable});
    return result;
  }

  Future<bool> enableWiFi(bool enable) async {
    Log.develop("[网络] enable = $enable");
    bool result =  await methodChannel.invokeMethod('enableWiFi', {'enable': enable});
    return result;
  }

  // 返回的结果bool
  Future<bool> supportWiFiControl() async {
    bool support =  await  methodChannel.invokeMethod('supportWiFiControl');
    return support;
  }

  // 返回的是bool
  Future<bool> supportEthernetControl() async {
    bool support =  await methodChannel.invokeMethod('supportEthernetControl');
    return support;
  }

  // 启动观察网络连接状态
  void startObserverNetState() {
    methodChannel.invokeMethod("listenerConnectState");
  }
  // 关闭观察网络连接状态
  void stopObserverNetState() {
    methodChannel.invokeMethod("removeListenerConnectState");
  }

  // 启动扫描WiFi
  void startScanNearbyWiFi() {
    methodChannel.invokeMethod("scanNearbyWiFi");
  }

  // 停止扫描WiFi
  void stopScanNearbyWiFi() {
    methodChannel.invokeMethod("stopScanNearbyWiFi");
  }
  // 清除所有的wifi记录
  void removeAllWiFiRecord() {
    methodChannel.invokeMethod('removeAllWiFiRecord');
  }

}
