import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/index.dart';

import '../../../common/api/api.dart';

class PowerApi {
  /// 0x13（物模型）
  static Future<MzResponseEntity> power0x13(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder('switchLightWithTime', deviceId, { "dimTime": 0, "power": onOff }, method: 'POST');

    return res;
  }
}