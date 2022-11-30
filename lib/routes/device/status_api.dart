import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/index.dart';

import '../../../common/api/api.dart';

class StatusApi {
  /// 0x13（物模型）
  static Future<MzResponseEntity> detailOf0x13(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('getAllStand', deviceId, {}, method: 'GET');

    return res;
  }
}