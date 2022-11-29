import 'package:screen_app/common/api/device_api.dart';
import '../../../models/mz_response_entity.dart';

/// 浴霸控制接口
class BathroomMasterApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('__fullQuery__', deviceId, {},
        method: 'GET');
    return res;
  }

  /// 查询设备状态（lua）
  static Future<MzResponseEntity> getDetailByLua(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0x26', deviceId);

    return res;
  }

  /// 物模型控制
  static Future<MzResponseEntity> wotControl(
      String deviceId, String command, Map data) async {
    var res =
        await DeviceApi.sendPDMOrder(command, deviceId, data, method: 'POST');
    return res;
  }
}
