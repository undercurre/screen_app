import 'package:screen_app/channel/models/net_state.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';
import 'package:screen_app/generated/json/base/json_convert_content.dart';

NetState $NetStateFromJson(Map<String, dynamic> json) {
  final NetState netState = NetState();
  final int? ethernetState = jsonConvert.convert<int>(json['ethernetState']);
  if (ethernetState != null) {
    netState.ethernetState = ethernetState;
  }
  final int? wifiState = jsonConvert.convert<int>(json['wifiState']);
  if (wifiState != null) {
    netState.wifiState = wifiState;
  }
  final WiFiScanResult? wiFiScanResult =
      jsonConvert.convert<WiFiScanResult>(json['wiFiScanResult']);
  if (wiFiScanResult != null) {
    netState.wiFiScanResult = wiFiScanResult;
  }
  return netState;
}

Map<String, dynamic> $NetStateToJson(NetState entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['ethernetState'] = entity.ethernetState;
  data['wifiState'] = entity.wifiState;
  data['wiFiScanResult'] = entity.wiFiScanResult?.toJson();
  return data;
}
