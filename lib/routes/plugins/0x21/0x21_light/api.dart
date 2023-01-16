import 'dart:convert';

import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/mz_response_entity.dart';

const uuid = Uuid();

class WrapZigbeeLight implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await ZigbeeLightApi.getLightDetail(
        deviceInfo.applianceCode, deviceInfo.masterId);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    MzResponseEntity<String> gatewayInfo =
    await DeviceApi.getGatewayInfo(deviceInfo.applianceCode, deviceInfo.masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    return await ZigbeeLightApi.powerPDM(
        deviceInfo.masterId, onOff, infoMap['nodeid']);
  }

  @override
  bool isSupport (DeviceEntity deviceInfo) {
    // 过滤modelNumber
    return zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_colorful' || zigbeeControllerList[deviceInfo.modelNumber] == '0x21_light_noColor';
  }

  @override
  bool isPower (DeviceEntity deviceInfo) {

    return (deviceInfo.detail != null && deviceInfo.detail!.keys.toList().isNotEmpty) ? deviceInfo.detail!["lightPanelDeviceList"][0]["attribute"] == 1 : false;
  }

  @override
  String getAttr (DeviceEntity deviceInfo) {
    return (deviceInfo.detail != null && deviceInfo.detail!.keys.toList().isNotEmpty) ? deviceInfo.detail!["lightPanelDeviceList"][0]["brightness"].toString() : '0';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '%';
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/dengguang_icon_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/dengguang_icon_on.png';
  }
}

class ZigbeeLightApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getLightDetail(String deviceId,
      String masterId) async {
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(
        deviceId, masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    var res = await DeviceApi.sendPDMOrder('0x16', 'lightPanleGetStatus',
        deviceId,
        {"msgId": uuid.v4(), "deviceId": masterId, "nodeId": infoMap["nodeid"]},
        method: 'POST');
    return res;
  }

  /// 设置延时关灯（物模型）
  static Future<MzResponseEntity> delayPDM(String deviceId, bool onOff,
      String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'lightDelayControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceControlList": [
            {"endPoint": 1, "attribute": onOff ? 3 : 0}
          ],
          "deviceId": deviceId,
          "nodeId": nodeId
        },
        method: 'PUT');

    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff,
      String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'lightControl',
        deviceId,
        {
          "brightness": 0,
          "msgId": uuid.v4(),
          "power": onOff,
          "deviceId": deviceId,
          "nodeId": nodeId,
          "colorTemperature": 0
        },
        method: 'PUT');

    return res;
  }

  /// 调节亮度色温控制（物模型）
  static Future<MzResponseEntity> adjustPDM(String deviceId, num brightness,
      num colorTemperature, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'lightControl',
        deviceId,
        {
          "brightness": brightness,
          "msgId": uuid.v4(),
          "power": true,
          "deviceId": deviceId,
          "nodeId": nodeId,
          "colorTemperature": colorTemperature
        },
        method: 'PUT');

    return res;
  }
}