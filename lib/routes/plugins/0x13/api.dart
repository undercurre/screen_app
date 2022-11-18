import 'package:screen_app/common/api/device_api.dart';

import '../../../common/api/api.dart';

class WIFILightApi {
  /// 查询设备状态（物模型）
  static Future<MzIotResult> getLightDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('getAllStand', deviceId, {}, method: 'GET');

    return res;
  }
  /// 设备控制（lua）
  static Future<MzIotResult> powerLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder('0x13', deviceId, { "power": onOff ? 'on':'off' });

    return res;
  }
}