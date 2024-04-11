import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../common/global.dart';
import '../../../models/mz_response_entity.dart';

class WrapElectricWaterHeater implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await ElectricWaterHeaterApi.getAirConditionDetail(deviceInfo.applianceCode);
    if (res.code == 0) {
      return res.result ?? {};
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    return await ElectricWaterHeaterApi.powerLua(deviceInfo.applianceCode, onOff);
  }

  @override
  bool isSupport (DeviceEntity deviceInfo) {
    // 过滤sn8
    return true;
  }

  @override
  bool isPower (DeviceEntity? deviceInfo) {
    return deviceInfo?.detail != null ? deviceInfo?.detail!["power"] == 'on': false;
  }

  @override
  String getAttr (DeviceEntity deviceInfo) {
    return deviceInfo.detail != null ? (deviceInfo.detail!["temperature"]).toString() : '';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '℃';
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/air_conditioner_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/air_conditioner_on.png';
  }
}

class ElectricWaterHeaterApi {
  /// 查询设备状态（lua）
  static Future<MzResponseEntity> getAirConditionDetail(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0xAC', deviceId);
    return res;
  }

  /// 开关控制（lua）
  static Future<MzResponseEntity> powerLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0xAC', deviceId, {"power": onOff ? 'on' : 'off'});

    return res;
  }

  /// 调节风速（lua）
  static Future<MzResponseEntity> gearLua(String deviceId, num windSpeed) async {
    var res = await DeviceApi.sendLuaOrder(
        '0xAC', deviceId, {"wind_speed": windSpeed});

    return res;
  }

  /// 调节温度（lua）
  static Future<MzResponseEntity> temperatureLua(String deviceId, num temperature, num smallTemp) async {
    var res = await DeviceApi.sendLuaOrder(
        '0xAC', deviceId, {"temperature": temperature, "small_temperature": smallTemp});

    return res;
  }

  static Future<MzResponseEntity> temperatureLuaZheng(String deviceId, num temperature) async {
    var res = await DeviceApi.sendLuaOrder(
        '0xAC', deviceId, {"temperature": temperature});

    return res;
  }

  /// 调节模式（lua）
  static Future<MzResponseEntity> modeLua(String deviceId, String mode) async {
    var res = await DeviceApi.sendLuaOrder(
        '0xAC', deviceId, {"mode": mode});

    return res;
  }
}
