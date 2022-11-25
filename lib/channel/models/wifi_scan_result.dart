import 'package:json_annotation/json_annotation.dart';


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
  late String ssid;
  // 一般指AP的MAC地址
  late String bssid;
  // 认证方式（说明：这里采用自定义认证）open: 开放的方式  encryption: 需要传密钥方式
  late String auth;
  // WiFi信号强度等级 0 ~ 3
  late num level;

  factory WiFiScanResult.fromJson(Map<String,dynamic> json) => _$ScanResultFromJson(json);
  Map<String, dynamic> toJson() => _$ScanResultToJson(this);

  static List<WiFiScanResult>? scanResultListFromJsonArray(List<Map<String,dynamic>>? list) =>
      _$scanResultListFromJsonArray(list);

}

WiFiScanResult _$ScanResultFromJson(Map<dynamic, dynamic> json) => WiFiScanResult()
  ..ssid = json['ssid'] as String
  ..bssid = json['bssid'] as String
  ..auth = json['auth'] as String
  ..level = json['level'] as num;

Map<String, dynamic> _$ScanResultToJson(WiFiScanResult instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'bssid': instance.bssid,
      'auth': instance.auth,
      'level': instance.level,
    };

List<WiFiScanResult>? _$scanResultListFromJsonArray(List<Map<String, dynamic>>? list) {
  if(list == null || list.isEmpty) {
    return null;
  }

  final scanResultList = <WiFiScanResult>[];
  for (var json in list) {
    final item = _$ScanResultFromJson(json);
    scanResultList.add(item);
  }

  return scanResultList;

}


