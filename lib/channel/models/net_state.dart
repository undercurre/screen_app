import 'package:json_annotation/json_annotation.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';

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

