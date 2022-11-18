import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/global.dart';

import 'api.dart';
import '../../models/index.dart';

class DeviceApi {
  /// 获取设备详情（lua）
  static Future<MzIotResult> getDeviceDetail(String type,String applianceCode) async {
    var res = await Api.requestMzIot<QrCode>(
        "/v1/category/midea/device/status/query",
        data: {
          "applianceCode": applianceCode,
          "categoryCode": type,
          "version": "1.0",
          "frontendType": "ANDRIOD",
          "systemSource": "SMART_SCREEN",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备lua控制
  static Future<MzIotResult> sendLuaOrder(String categoryCode, String applianceCode, Object command) async {
    var res = await Api.requestMzIot<QrCode>(
        "/v1/category/midea/device/wifiControl",
        data: {
          "deviceId": applianceCode,
          "userId": Global.user?.uid,
          "command": command,
          "categoryCode": categoryCode,
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDRIOD",
          "reqId": uuid.v4(),
          "version": "1.0",
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备物模型控制
  static Future<MzIotResult> sendPDMOrder(String uri, String applianceCode, Object command, {String? method = "PUT"}) async {
    var res = await Api.requestMzIot<QrCode>(
        "/v1/category/midea/device/control",
        data: {
          "systemSource": "SMART_SCREEN",
          "frontendType": "ANDRIOD",
          "reqId": uuid.v4(),
          "method": method,
          "command": command,
          "msgId": uuid.v4(),
          "uri": '/$uri/$applianceCode',
          "deviceId": applianceCode,
          "userId": Global.user?.uid,
          "timestamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now())
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }
}