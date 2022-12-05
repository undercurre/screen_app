import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../models/mz_response_entity.dart';

class WrapWIFILight implements DeviceInterface{
  @override
  Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    var res = await WIFILightApi.getLightDetail(deviceId);
    return res;
  }

  @override
  Future<MzResponseEntity> setPower(String deviceId, bool onOff) async {
    return await WIFILightApi.powerPDM(deviceId, onOff);
  }
}

class WIFILightApi {
  /// 查询设备状态（物模型）
  static Future<Map<String, dynamic>> getLightDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('getAllStand', deviceId, {},
        method: 'GET');
    if (res.result != null) {
      return res.result;
    } else {
      return {};
    }
  }

  /// 设备控制（lua）
  static Future<MzResponseEntity> powerLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x13', deviceId, {"power": onOff ? 'on' : 'off'});

    return res;
  }

  /// 设置延时关灯（物模型）
  static Future<MzResponseEntity> delayPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        'setTimeOff', deviceId, {"timeOff": onOff ? 3 : 0},
        method: 'POST');

    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        'switchLightWithTime', deviceId, {"dimTime": 0, "power": onOff},
        method: 'POST');

    return res;
  }

  /// 模式控制（物模型）
  static Future<MzResponseEntity> modePDM(String deviceId, String mode) async {
    var res = await DeviceApi.sendPDMOrder(
        'controlScreenModel', deviceId, {"dimTime": 0, "screenModel": mode},
        method: 'POST');

    return res;
  }

  /// 亮度控制（物模型）
  static Future<MzResponseEntity> brightnessPDM(
      String deviceId, num brightness) async {
    var res = await DeviceApi.sendPDMOrder('controlBrightValue', deviceId,
        {"dimTime": 0, "brightValue": brightness},
        method: 'POST');

    return res;
  }

  /// 色温控制（物模型）
  static Future<MzResponseEntity> colorTemperaturePDM(
      String deviceId, num colorTemperature) async {
    var res = await DeviceApi.sendPDMOrder('controlColorTemperatureValue',
        deviceId, {"dimTime": 0, "colorTemperatureValue": colorTemperature},
        method: 'POST');

    return res;
  }
}
