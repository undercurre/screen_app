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

}

WiFiScanResult _$ScanResultFromJson(Map<dynamic, dynamic> json) => WiFiScanResult()
  ..ssid = json['ssid'] as String
  ..bssid = json['bssid'] as String
  ..auth = json['auth'] as String
  ..alreadyConnected = json['alreadyConnected'] as bool
  ..level = json['level'] as num;

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


