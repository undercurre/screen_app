import 'package:flutter/cupertino.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/channel/models/net_state.dart';

import '../../channel/net_method_channel.dart';

/// 说明：网络工具类
/// 需依赖原生提供的能力。且是对 [ NetMethodChannel ] 二次封装

/// 网络类型
/// ethernet 当前网络连接的类型为以太网类型
/// wifi 当前网络连接的类型为无线网络wifi
enum NetType { ethernet, wifi }

class MZNetState {
  final NetType type;
  MZNetState(this.type);
  get isWifi => type == NetType.wifi;
  get isEthernet => type == NetType.ethernet;
}

/// 任意组件用来监听网络连接情况
mixin WidgetNetState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    netMethodChannel.registerNetChangeCallBack(_netChange);
    // 主动查询一次网络
    if(NetUtils.getNetState() == null) {
      netMethodChannel.checkNetState();
    }
  }

  @override
  void dispose() {
    super.dispose();
    netMethodChannel.unregisterNetChangeCallBack(_netChange);
  }

  /// 对子类不可见
  void _netChange(NetState state) {
    debugPrint('_netChange: $state');
    netChange(NetUtils._parse(state));
  }

  /// 对子类可见，可重载该方法实现对应的业务逻辑处理
  void netChange(MZNetState? state);

  // 当前网络是否已连接
  bool isConnected() {
    return NetUtils.getNetState() != null;
  }
}

/// 用于判断当前网络是否连接成功
class NetUtils {
  /// 获取当前网络状态
  static MZNetState? getNetState() {
    return _parse(netMethodChannel.currentNetState);
  }

  /// wifi是否启动
  static Future<bool> wifiIsOpen() {
    return netMethodChannel.wifiIsOpen();
  }

  /// ethernet是否启动
  static Future<bool> ethernetIsOpen() {
    return netMethodChannel.ethernetIsOpen();
  }

  /// 查询当前已连接的wifi账号密码
  static Future<ConnectedWiFiRecord?> checkConnectedWiFiRecord() {
    return netMethodChannel.checkConnectedWiFiRecord();
  }

  /// 监听网络状态
  static void registerListenerNetState(void Function(NetState? state) method) {
    netMethodChannel.registerNetChangeCallBack(method);
  }

  static void unregisterListenerNetState(void Function(NetState? state) method) {
    netMethodChannel.unregisterNetChangeCallBack(method);
  }

  /// 获取原始的网络连接类型
  static NetState getRawNetState() => netMethodChannel.currentNetState;

  /// 解析当前连接状态
  static _parse(NetState state) {
    bool wifiConnected = state.wifiState == 2;
    bool ethernetConnected = state.ethernetState == 2;
    if (wifiConnected && ethernetConnected) {
      return MZNetState(NetType.ethernet);
    } else if (wifiConnected) {
      return MZNetState(NetType.wifi);
    } else if (ethernetConnected) {
      return MZNetState(NetType.ethernet);
    } else {
      return null; // 网络暂时未连接
    }
  }
}
