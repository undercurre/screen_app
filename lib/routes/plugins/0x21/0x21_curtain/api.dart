import 'dart:convert';

import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/mz_response_entity.dart';

const uuid = Uuid();

class WrapZigbeeCurtain implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await ZigbeeCurtainApi.getCurtainDetail(deviceInfo);
    if (res.code == 0 && res.result != null) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(
        deviceInfo.applianceCode, deviceInfo.masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_one' ||
        zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_two') {
      var res = await ZigbeeCurtainApi.powerPDMTwin(
          deviceInfo.masterId, onOff, onOff, infoMap["nodeid"]);
      return res;
    } else {
      num percent = onOff ? 100 : 0;
      var dianjiRes = await ZigbeeCurtainApi.curtainPercentPDM(
          deviceInfo.masterId, percent, infoMap["nodeid"]);
      return dianjiRes;
    }
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤modelNumber
    return true;
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_one' ||
        zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_two') {
      return (deviceInfo.detail != null &&
              deviceInfo.detail!.keys.toList().isNotEmpty)
          ? deviceInfo.detail!["deviceControlList"][0]["attribute"] == 1
          : false;
    } else {
      return (deviceInfo.detail != null &&
              deviceInfo.detail!.keys.toList().isNotEmpty)
          ? deviceInfo.detail!["curtainDeviceList"][0]["attribute"] == 1
          : false;
    }
  }

  @override
  String getAttr(DeviceEntity deviceInfo) {
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_one' ||
        zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_two') {
      return '';
    } else {
      return (deviceInfo.detail != null &&
              deviceInfo.detail!.keys.toList().isNotEmpty)
          ? deviceInfo.detail!["curtainDeviceList"][0]["deviceFunctionLevel"] ==
                  240
              ? ''
              : deviceInfo.detail!["curtainDeviceList"][0]
                      ["deviceFunctionLevel"]
                  .toString()
          : '0';
    }
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_one' ||
        zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_two') {
      return '';
    } else {
      return '%';
    }
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
        '0x21_curtain_panel_one') {
      return 'assets/imgs/device/yilu_off.png';
    }
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
        '0x21_curtain_panel_two') {
      return 'assets/imgs/device/erlu-01-off.png';
    }
    if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_curtain') {
      return 'assets/imgs/device/chuanglian_icon_off.png';
    }
    return 'assets/imgs/device/chuanglian_icon_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
        '0x21_curtain_panel_one') {
      return 'assets/imgs/device/yilu_on.png';
    }
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
        '0x21_curtain_panel_two') {
      return 'assets/imgs/device/erlu-01-on.png';
    }
    if (zigbeeControllerList[deviceInfo.modelNumber] == '0x21_curtain') {
      return 'assets/imgs/device/chuanglian_icon_on.png';
    }
    return 'assets/imgs/device/chuanglian_icon_on.png';
  }
}

class ZigbeeCurtainApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getCurtainDetail(
      DeviceEntity deviceInfo) async {
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(
        deviceInfo.applianceCode, deviceInfo.masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    if (zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_one' ||
        zigbeeControllerList[deviceInfo.modelNumber] ==
            '0x21_curtain_panel_two') {
      var res = await DeviceApi.sendPDMOrder(
          '0x16',
          'subDeviceGetStatus',
          deviceInfo.masterId,
          {
            "msgId": uuid.v4(),
            "deviceId": deviceInfo.masterId,
            "nodeId": infoMap["nodeid"]
          },
          method: 'POST');
      return res;
    } else {
      var res = await DeviceApi.sendPDMOrder(
          '0x16',
          'curtainGetStatus',
          deviceInfo.masterId,
          {
            "msgId": uuid.v4(),
            "deviceId": deviceInfo.masterId,
            "nodeId": infoMap["nodeid"]
          },
          method: 'POST');
      return res;
    }
  }

  /// 设置延时关灯（物模型）
  static Future<MzResponseEntity> delayPDM(
      String deviceId, bool onOff, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'lightDelayControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceControlList": [
            {"endPoint": 0, "attribute": onOff ? 3 : 0}
          ],
          "deviceId": deviceId,
          "nodeId": nodeId
        },
        method: 'PUT');

    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(
      String deviceId, bool onOff, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'subDeviceControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": onOff ? 1 : 0},
            {"endPoint": 2, "attribute": onOff ? 1 : 0}
          ]
        },
        method: 'PUT');

    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDMTwin(
      String deviceId, bool onOff1, bool onOff2, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'subDeviceControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": onOff1 ? 1 : 0},
            {"endPoint": 2, "attribute": onOff2 ? 1 : 0}
          ]
        },
        method: 'PUT');

    return res;
  }

  /// 窗帘电机——打开
  static Future<MzResponseEntity> curtainOpenPDM(
      String deviceId, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'curtainOpenPerControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": 100}
          ]
        },
        method: 'PUT');

    return res;
  }

  /// 窗帘电机——关闭
  static Future<MzResponseEntity> curtainClosePDM(
      String deviceId, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'curtainOpenPerControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": 0}
          ]
        },
        method: 'PUT');

    return res;
  }

  /// 窗帘电机——暂停
  static Future<MzResponseEntity> curtainStopPDM(
      String deviceId, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'curtainOpenPerControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": 240}
          ]
        },
        method: 'PUT');

    return res;
  }

  /// 窗帘电机——百分比
  static Future<MzResponseEntity> curtainPercentPDM(
      String deviceId, num percent, String nodeId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'curtainOpenPerControl',
        deviceId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": percent}
          ]
        },
        method: 'PUT');

    return res;
  }
}
