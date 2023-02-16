import 'package:json_annotation/json_annotation.dart';
import 'package:screen_app/common/utils.dart';


////// 例子
//{
//   "ssid": "Midea-xx-x",
//   "bssid": "123-123-123-123",
//   "auth": "open",
//   "level": 3
// }

@JsonSerializable()
class WiFiScanResult {
  WiFiScanResult();

  // 一般指AP的名称
  String ssid = "unknown";
  // 一般指AP的MAC地址
  String bssid = 'unknown';
  // 认证方式（说明：这里采用自定义认证）open: 开放的方式  encryption: 需要传密钥方式
  String auth = 'encryption';
  // WiFi信号强度等级 0 ~ 3
  num level = 0;
  // 是否尝试连接过
  bool alreadyConnected = false;

  factory WiFiScanResult.fromJson(Map<String,dynamic> json) => _$ScanResultFromJson(json);
  Map<String, dynamic> toJson() => _$ScanResultToJson(this);

  static List<WiFiScanResult>? scanResultListFromJsonArray(List<dynamic>? list) =>
      _$scanResultListFromJsonArray(list);

  @override
  bool operator ==(Object other) {
    if(other.runtimeType != runtimeType) return false;
    return other is WiFiScanResult && other.ssid == ssid && other.bssid == bssid;
  }

  @override
  int get hashCode => Object.hash(ssid, bssid);


}

WiFiScanResult _$ScanResultFromJson(Map<dynamic, dynamic> json) => WiFiScanResult()
  ..ssid = json['ssid'] ?? "unknown"
  ..bssid = json['bssid'] ?? "unknown"
  ..auth = json['auth'] ?? 'encryption'
  ..alreadyConnected = json['alreadyConnected'] ?? false
  ..level = json['level'] ?? 0;

Map<String, dynamic> _$ScanResultToJson(WiFiScanResult instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'bssid': instance.bssid,
      'auth': instance.auth,
      'alreadyConnected': instance.alreadyConnected,
      'level': instance.level,
    };

List<WiFiScanResult>? _$scanResultListFromJsonArray(List<dynamic>? list) {
  if(list == null || list.isEmpty) {
    return null;
  }

  final scanResultList = <WiFiScanResult>[];
  for (var json in list) {
    if(json is Map) {
      final item = _$ScanResultFromJson(json);
      if(StrUtils.isNotNullAndEmpty(item.ssid)) {
        scanResultList.add(item);
      }
    } else {
      throw Exception("请确保类型为Map");
    }
  }

  return scanResultList;

}


