import 'package:dio/dio.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../common/api/api.dart';
import '../../../common/global.dart';
import '../../../models/mz_response_entity.dart';

class WrapWIFILight implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    if (deviceInfo.sn8 == '79009833') {
      var res =
          await WIFILightApi.getLightDetailByPDM(deviceInfo.applianceCode);
      if (res.code == 0) {
        return res.result;
      } else {
        return {};
      }
    } else {
      var res =
          await WIFILightApi.getDeviceDetailByLua(deviceInfo.applianceCode);
      if (res.code == 0) {
        return res.result;
      } else {
        return {};
      }
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    if (deviceInfo.sn8 == '79009833') {
      return await WIFILightApi.powerPDM(deviceInfo.applianceCode, onOff);
    } else {
      return await WIFILightApi.powerLua(deviceInfo.applianceCode, onOff);
    }
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤sn8
    return true;
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return deviceInfo.detail != null && deviceInfo.detail!.isNotEmpty
        ? (deviceInfo.detail!["power"] is bool
            ? deviceInfo.detail!["power"]
            : deviceInfo.detail!["power"] == 'on')
        : false;
  }

  @override
  String getAttr(DeviceEntity deviceInfo) {
    // logger.i('设备', deviceInfo.detail!);
    return deviceInfo.detail != null && deviceInfo.detail!.isNotEmpty
        ? (deviceInfo.detail!["brightValue"] != null
            ? (deviceInfo.detail!["brightValue"] * 100 / 255).toStringAsFixed(0)
            : (int.parse(deviceInfo.detail!["brightness"]) * 100 / 255)
                .toStringAsFixed(0))
        : '';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '%';
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/dengguang_icon_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/dengguang_icon_on.png';
  }
}

class WIFILightApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getLightDetailByPDM(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('0x13', 'getAllStand', deviceId, {},
        method: 'GET');
    return res;
  }

  /// 查询设备状态lua
  static Future<MzResponseEntity> getDeviceDetailByLua(
      String applianceCode) async {
    var res = await Api.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/status/query",
        data: {
          "applianceCode": applianceCode,
          "categoryCode": '0x13',
          "version": "1.0",
          "frontendType": "ANDROID",
          "systemSource": "SMART_SCREEN",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }

  /// 设备开关控制（lua）
  static Future<MzResponseEntity> powerLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x13', deviceId, {"power": onOff ? 'on' : 'off'});

    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x13', 'switchLightWithTime', deviceId, {"dimTime": 0, "power": onOff},
        method: 'POST');

    return res;
  }

  /// 设置延时关灯（物模型）
  static Future<MzResponseEntity> delayPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x13', 'setTimeOff', deviceId, {"timeOff": onOff ? 3 : 0},
        method: 'POST');

    return res;
  }

  /// 设置延时关灯 （lua）
  static Future<MzResponseEntity> delayLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x13', deviceId, {"delay_light_off": onOff ? 3 : 0});

    return res;
  }

  /// 模式控制（物模型）
  static Future<MzResponseEntity> modePDM(String deviceId, String mode) async {
    var res = await DeviceApi.sendPDMOrder('0x13', 'controlScreenModel',
        deviceId, {"dimTime": 0, "screenModel": mode},
        method: 'POST');

    return res;
  }

  /// 模式控制（lua）
  static Future<MzResponseEntity> modeLua(String deviceId, String mode) async {
    var res =
        await DeviceApi.sendLuaOrder('0x13', deviceId, {"scene_light": mode});

    return res;
  }

  /// 亮度控制（物模型）
  static Future<MzResponseEntity> brightnessPDM(
      String deviceId, num brightness) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x13',
        'controlBrightValue',
        deviceId,
        {
          "dimTime": 0,
          "brightValue": int.parse((brightness / 100 * 255).toStringAsFixed(0))
        },
        method: 'POST');

    return res;
  }

  /// 亮度控制（lua）
  static Future<MzResponseEntity> brightnessLua(
      String deviceId, num brightness) async {
    var res = await DeviceApi.sendLuaOrder('0x13', deviceId,
        {"brightness": int.parse((brightness / 100 * 255).toStringAsFixed(0))});

    return res;
  }

  /// 色温控制（物模型）
  static Future<MzResponseEntity> colorTemperaturePDM(
      String deviceId, num colorTemperature) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x13',
        'controlColorTemperatureValue',
        deviceId,
        {
          "dimTime": 0,
          "colorTemperatureValue":
              int.parse((colorTemperature / 100 * 255).toStringAsFixed(0))
        },
        method: 'POST');

    return res;
  }

  /// 色温控制（lua）
  static Future<MzResponseEntity> colorTemperatureLua(
      String deviceId, num colorTemperature) async {
    var res = await DeviceApi.sendLuaOrder('0x13', deviceId, {
      "color_temperature":
          int.parse((colorTemperature / 100 * 255).toStringAsFixed(0))
    });

    return res;
  }
}
