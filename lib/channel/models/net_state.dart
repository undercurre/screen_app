import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';


// const notConnectedWifi = 0x00;                  /// wifi未连接
// const connectingWifi = 0x01;                    /// wifi连接中
// const connectedWifi = 0x02;                     /// wifi已连接
// const availableWifi = 0x04;                     /// wifi可用
// const unavailableWifi = 0x03;                   /// wifi不可用
//
// const notConnectedEthernet = 0x0 << 4;              /// 以太网未连接
// const connectingEthernet = 0x1 << 4;                /// 以太网连接中
// const connectedEthernet = 0x2 << 4;                 /// 以太网已连接
// const availableEthernet = 0x4 << 4;                 /// 以太网可用
// const unavailableEthernet = 0x03 << 4;              /// 以太网不可用
// const flag = 0xF << 4;
//
//
// class V2NetState {
//   V2NetState();
//   /// 网络状态
//   int _state = 0;
//   /// 当前wifi连接信息
//   WiFiScanResult? wiFiScanResult;
//
//   factory V2NetState.fromJson(Map<dynamic, dynamic> map) {
//     V2NetState state = V2NetState();
//     /// 0未连接 1连接中 2已连接
//     state._state &= flag;
//     state._state |= map['wifiState'] ?? 0;
//     state._state &= ~flag;
//     state._state |= (map['ethernetState'] ?? 0) << 4;
//     state.wiFiScanResult = map['wifiInfo'] == null ? null : WiFiScanResult.fromJson(map['wifiInfo']);
//     return state;
//   }
//
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       'ethernetState': (_state & flag) >> 4,
//       'wifiState': (_state & ~flag),
//       'wifiInfo': wiFiScanResult?.toJson()
//     };
//   }
//   /// 网络是否可用
//   bool isNetAvailable() {
//     return _state & ~flag >= availableWifi || _state & flag >= availableEthernet;
//   }
//   /// 网络是否连接
//   bool isConnected() {
//     return isWiFiConnected() | isEthernetConnected();
//   }
//
//   bool isWiFiConnected([bool only = false]) {
//     if(only) {
//       return _state & ~flag == connectedWifi;
//     } else {
//       return _state & ~flag >= connectedWifi;
//     }
//   }
//
//   bool isEthernetConnected([bool only = false]) {
//     if(only) {
//       return _state & flag == connectedEthernet;
//     } else {
//       return _state & flag >= connectedEthernet;
//     }
//   }
//
//   void netAvailableChange(bool available) {
//     if(isWiFiConnected() && isEthernetConnected()) {
//       if(available) {
//         _state = (_state & flag) | availableWifi;
//         _state = (_state & ~flag) | availableEthernet;
//       } else {
//         _state = (_state & flag) | unavailableWifi;
//         _state = (_state & ~flag) | unavailableEthernet;
//       }
//     } else if(isWiFiConnected()) {
//       if(available) {
//         _state = (_state & flag) | availableWifi;
//       } else {
//         _state = (_state & flag) | unavailableWifi;
//       }
//     } else if(isEthernetConnected()) {
//       if(available) {
//         _state = (_state & ~flag) | availableEthernet;
//       } else {
//         _state = (_state & ~flag) | unavailableEthernet;
//       }
//     }
//   }
//
//   @override
//   String toString() {
//     return const JsonEncoder().convert(toJson());
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if(other is V2NetState) {
//       return other._state == _state && other.wiFiScanResult == wiFiScanResult;
//     }
//     return false;
//   }
//
//   @override
//   int get hashCode {
//     return Object.hash(_state, wiFiScanResult?.hashCode);
//   }
//
// }

@JsonSerializable()
class NetState {
  NetState();

  /// 0未连接 1连接中 2已连接
  int ethernetState = 0;
  /// 0 未连接 1连接中 2已连接
  int wifiState = 0;
  /// 当前连接的wifi信息
  WiFiScanResult? wiFiScanResult;

  factory NetState.fromJson(Map<dynamic, dynamic> map) => _$NetStateFromJson(map);

  Map<String, dynamic> toJson() => _$NetStateToJson(this);

  @override
  String toString() {
    return const JsonEncoder().convert(toJson());
  }

}

_$NetStateToJson(NetState instance) =>
    <String, dynamic>{
      'ethernetState': instance.ethernetState,
      'wifiState': instance.wifiState,
      'wifiInfo': instance.wiFiScanResult?.toJson()
    };

_$NetStateFromJson(Map<dynamic, dynamic> map) {
  NetState state = NetState();
  state.wifiState = map['wifiState'] ?? 0;
  state.ethernetState = map['ethernetState'] ?? 0;
  state.wiFiScanResult = map['wifiInfo'] == null ? null : WiFiScanResult.fromJson(map['wifiInfo']);
  return state;
}

/// 已经连接的wifi本地记录
class ConnectedWiFiRecord {
  late String ssid;
  late String bssid;
  late String password;
  late String encryptType;
  ConnectedWiFiRecord();

  factory ConnectedWiFiRecord.fromJson(Map<dynamic, dynamic> map) => ConnectedWiFiRecord()
  ..ssid = map['ssid']
  ..bssid = map['bssid']
  ..password = map['password']
  ..encryptType = map['encryptType'];
}

