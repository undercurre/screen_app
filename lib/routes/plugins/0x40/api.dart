import 'package:screen_app/common/api/device_api.dart';
import '../../../models/mz_response_entity.dart';
import '../device_interface.dart';

/// 浴霸控制接口
class BaseApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('__fullQuery__', deviceId, {},
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
      'toggleSmelly',
      deviceId,
      {
        'smelly': value
      },
      method: 'POST',
    );
    return res;
  }

  /// 换气开关（物模型）
  static Future<MzResponseEntity> toggleVentilation(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      'toggleVentilation',
      deviceId,
      {
        'ventilation': value
      },
      method: 'POST',
    );
    return res;
  }


  /// 照明开关（物模型）
  static Future<MzResponseEntity> toggleLightMode(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      'toggleSmelly',
      deviceId,
      {
        'light': value
      },
      method: 'POST',
    );
    return res;
  }

  /// 照明开关（物模型）
  static Future<MzResponseEntity> toggleBlowing(
      String deviceId, bool value) async {
    var res = await DeviceApi.sendPDMOrder(
      'toggleBlowing',
      deviceId,
      {
        'blowing': value
      },
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风向（物模型）
  static Future<MzResponseEntity> setSwingAngle(
      String deviceId, int value) async {
    var res = await DeviceApi.sendPDMOrder(
      'setSwingAngle',
      deviceId,
      {
        'windAngle': value
      },
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速（物模型）
  static Future<MzResponseEntity> setWindSpeed(
      String deviceId, int value) async {
    var res = await DeviceApi.sendPDMOrder(
      'setWindSpeed',
      deviceId,
      {
        'windSpeed': value
      },
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速和开关（物模型）
  static Future<MzResponseEntity> setWindSpeedAndBlowing(
      String deviceId, int windSpeed, bool blowing) async {
    var res = await DeviceApi.sendPDMOrder(
      'setWindSpeed',
      deviceId,
      {
        'windSpeed': windSpeed,
        'blowing': blowing
      },
      method: 'POST',
    );
    return res;
  }

  /// 设置目标风速和开关（物模型）
  static Future<MzResponseEntity> setWindSpeedAndVentilation(
      String deviceId, int windSpeed, bool ventilation) async {
    var res = await DeviceApi.sendPDMOrder(
      'setWindSpeed',
      deviceId,
      {
        'windSpeed': windSpeed,
        'ventilation': ventilation
      },
      method: 'POST',
    );
    return res;
  }
}

/// 提供给DeviceList调用的接口实现
class DeviceListApiImpl implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    final res = await BaseApi.getDetailByLua(deviceId);
    if (res.success) {
      final data = res.result;
      if (data['mode'] != 'close_all' || data['light_mode'] != 'close_all') {
        data['power'] = true;
      } else {
        data['power'] = false;
      }
      return data;
    } else {
      throw Error();
    }
  }

  @override
  Future<MzResponseEntity> setPower(String deviceId, bool onOff) {
    if (onOff) {
      return BaseApi.luaControl(deviceId, {
        'mode': 'ventilation',
      });
    } else {
      return BaseApi.luaControl(deviceId, {
        'mode': '',
        'light_mode': ''
      });
    }
  }

}
