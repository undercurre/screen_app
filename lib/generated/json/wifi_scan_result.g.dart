import 'package:screen_app/channel/models/wifi_scan_result.dart';
import 'package:screen_app/generated/json/base/json_convert_content.dart';

WiFiScanResult $WiFiScanResultFromJson(Map<String, dynamic> json) {
  final WiFiScanResult wiFiScanResult = WiFiScanResult();
  final String? ssid = jsonConvert.convert<String>(json['ssid']);
  if (ssid != null) {
    wiFiScanResult.ssid = ssid;
  }
  final String? bssid = jsonConvert.convert<String>(json['bssid']);
  if (bssid != null) {
    wiFiScanResult.bssid = bssid;
  }
  final String? auth = jsonConvert.convert<String>(json['auth']);
  if (auth != null) {
    wiFiScanResult.auth = auth;
  }
  final num? level = jsonConvert.convert<num>(json['level']);
  if (level != null) {
    wiFiScanResult.level = level;
  }
  final bool? alreadyConnected =
      jsonConvert.convert<bool>(json['alreadyConnected']);
  if (alreadyConnected != null) {
    wiFiScanResult.alreadyConnected = alreadyConnected;
  }
  return wiFiScanResult;
}

Map<String, dynamic> $WiFiScanResultToJson(WiFiScanResult entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['ssid'] = entity.ssid;
  data['bssid'] = entity.bssid;
  data['auth'] = entity.auth;
  data['level'] = entity.level;
  data['alreadyConnected'] = entity.alreadyConnected;
  return data;
}
