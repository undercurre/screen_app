import 'package:screen_app/common/api/device_api.dart';
import '../../../models/device_entity.dart';
import '../../../models/mz_response_entity.dart';
import '../device_interface.dart';

/// 浴霸控制接口
class BaseApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x40', '__fullQuery__', deviceId, {},
        method: 'GET');
    return res;
  }

  /// 查询设备状态（lua）
  static Future<MzResponseEntity> getDetailByLua(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0x40', deviceId);
    return res;
  }

  /// Lua控制
  static Future<MzResponseEntity> luaControl(String deviceId, Map data) async {
    var res = await DeviceApi.sendLuaOrder('0x40', deviceId, data);
    return res;
  }

  /// 异味感应（物模型）
  static Future<MzResponseEntity> toggleSmelly(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'toggleSmelly',
      deviceId,
      {'smelly': value},
      method: 'POST',
    );
    return res;
  }

  /// 换气开关（物模型）
  static Future<MzResponseEntity> toggleVentilation(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'toggleVentilation',
      deviceId,
      {'ventilation': value},
      method: 'POST',
    );
    return res;
  }

  /// 照明开关（物模型）
  static Future<MzResponseEntity> toggleLightMode(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'toggleSmelly',
      deviceId,
      {'light': value},
      method: 'POST',
    );
    return res;
  }

  /// 照明开关（物模型）
  static Future<MzResponseEntity> toggleBlowing(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'toggleBlowing',
      deviceId,
      {'blowing': value},
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风向（物模型）
  static Future<MzResponseEntity> setSwingAngle(
      String deviceId, int value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'setSwingAngle',
      deviceId,
      {'windAngle': value},
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速（物模型）
  static Future<MzResponseEntity> setWindSpeed(
      String deviceId, int value) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'setWindSpeed',
      deviceId,
      {'windSpeed': value},
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速和开关（物模型）
  static Future<MzResponseEntity> setWindSpeedAndBlowing(
      String deviceId, int windSpeed, bool blowing) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'setWindSpeed',
      deviceId,
      {'windSpeed': windSpeed, 'blowing': blowing},
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速和开关（物模型）
  static Future<MzResponseEntity> setWindSpeedAndVentilation(
      String deviceId, int windSpeed, bool ventilation) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x40',
      'setWindSpeed',
      deviceId,
      {'windSpeed': windSpeed, 'ventilation': ventilation},
      method: 'POST',
    );
    return res;
  }
}

/// 提供给DeviceList调用的接口实现
class DeviceListApiImpl implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    final res = await BaseApi.getDetailByLua(deviceInfo.applianceCode);
    if (res.success) {
      // final data = res.result;
      // if (data['mode'] != 'close_all' || data['light_mode'] != 'close_all') {
      //   data['power'] = true;
      // } else {
      //   data['power'] = false;
      // }
      return res.result;
    } else {
      throw Error();
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) {
    if (onOff) {
      return BaseApi.luaControl(deviceInfo.applianceCode, {
        'mode': 'ventilation',
      });
    } else {
      return BaseApi.luaControl(deviceInfo.applianceCode, {
        'mode': '',
        'light_mode': ''
      });
    }
  }

  @override
  String getAttr(DeviceEntity deviceInfo) {
    return '';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '';
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/bath_heater_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/bath_heater_on.png';
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    final data = deviceInfo.detail;
    if (data == null) {
      return false;
    }
    if (data['mode'] != 'close_all' || data['light_mode'] != 'close_all') {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 目前的所有凉霸都支持
    return true;
  }

}
