import 'package:json_annotation/json_annotation.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';

@JsonSerializable()
class NetState {
  NetState();

  int ethernetState = 0;
  int wifiState = 0;
  WiFiInfo? wifiInfo;

  factory NetState.fromJson(Map<String, dynamic> map) => _$NetStateFromJson(map);

  Map<String, dynamic> toJson() => _$NetStateToJson(this);
}

_$NetStateToJson(NetState instance) =>
    <String, dynamic>{
      'ethernetState': instance.ethernetState,
      'wifiState': instance.wifiState,
      'wifiInfo': instance.toJson()
    };

_$NetStateFromJson(Map<String, dynamic> map) {
  NetState state = NetState();
  state.wifiState = map['wifiState'] ?? 0;
  state.ethernetState = map['ethernetState'] ?? 0;
  state.wifiInfo = map['wifiInfo']== null ? null : WiFiInfo.fromJson(map['wifiInfo']);
  return state;
}



@JsonSerializable()
class WiFiInfo{

  WiFiInfo();

  String auth = "encryption";

  String bssid = 'unknown';

  num level = 0;

  String ssid = 'unknown';

  factory WiFiInfo.fromJson(Map<String, dynamic> map) => _$WiFiInfoFromJson(map);

  Map<String, dynamic> toJson() => _$WiFiInfoToJson(this);

}

Map<String, dynamic> _$WiFiInfoToJson(WiFiInfo instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'bssid': instance.bssid,
      'auth': instance.auth,
      'level': instance.level,
    };

WiFiInfo _$WiFiInfoFromJson(Map<dynamic, dynamic> json) => WiFiInfo()
  ..ssid = json['ssid'] ?? "unknown"
  ..bssid = json['bssid'] ?? "unknown"
  ..auth = json['auth'] ?? "encryption"
  ..level = json['level'] ?? 0;

