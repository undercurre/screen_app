import 'package:screen_app/common/api/device_api.dart';
import '../../../models/mz_response_entity.dart';

/// 浴霸控制接口
class BathroomMasterApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('getAllStand', deviceId, {},
        method: 'GET');
    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        'switchLightWithTime', deviceId, {"dimTime": 0, "power": onOff},
        method: 'POST');
    return res;
  }
}
