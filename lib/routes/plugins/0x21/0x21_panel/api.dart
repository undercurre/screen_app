import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/mz_response_entity.dart';

const uuid = Uuid();

class WrapPanel implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await PanelApi.getDetail(
        deviceInfo.applianceCode, deviceInfo.masterId);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    return await PanelApi.powerPDM(
        deviceInfo.masterId, onOff, deviceInfo.applianceCode);
  }

  @override
  bool isSupport (DeviceEntity deviceInfo) {
    // 过滤modelNumber
    return zigbeeControllerList[deviceInfo.modelNumber] == '0x21_panel';
  }

  @override
  bool isPower (DeviceEntity deviceInfo) {
    return false;
  }

  @override
  String getAttr (DeviceEntity deviceInfo) {
    return '';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '';
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

class PanelApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(
      String deviceId, String masterId) async {
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(deviceId, masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    var res = await DeviceApi.sendPDMOrder('0x16', 'subDeviceGetStatus',
        masterId, {"msgId": uuid.v4(), "deviceId": masterId, "nodeId": infoMap["nodeid"]},
        method: 'POST');
    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(
      String deviceId, bool onOff, String nodeId) async {
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
}
