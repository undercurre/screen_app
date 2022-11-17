import 'package:dio/dio.dart';
import 'package:screen_app/common/global.dart';

import 'api.dart';
import '../../models/index.dart';

class DeviceApi {
  /// 获取设备详情
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
}