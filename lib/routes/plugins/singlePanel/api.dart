import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../common/api/api.dart';
import '../../../models/mz_response_entity.dart';

class WrapSinglePanel implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await SinglePanelApi.getDetail(
        deviceInfo.applianceCode, deviceInfo.masterId);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    return await SinglePanelApi.controlGatewaySwitchPDM(deviceInfo, onOff);
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    return true;
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    var panelIndex = int.parse(deviceInfo.type[deviceInfo.type.length - 1]) - 1;
    return deviceInfo.detail != null
        ? deviceInfo.detail!["deviceControlList"][panelIndex]["attribute"] == 1
        : false;
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
    if (deviceInfo.detail != null && deviceInfo.detail!.isNotEmpty) {
      var panelCount = deviceInfo.detail!["deviceControlList"].length ?? 1;
      if (panelCount == 1) return 'assets/imgs/device/yilu_off.png';
      var panelIndex = int.parse(deviceInfo.type[deviceInfo.type.length - 1]);
      var panelTypeList = ['yilu', 'erlu', 'sanlu', 'silu'];
      var panelType = panelTypeList[panelCount - 1];
      return 'assets/imgs/device/$panelType-0$panelIndex-off.png';
    } else {
      return 'assets/imgs/device/yilu-01-off.png';
    }
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    if (deviceInfo.detail != null && deviceInfo.detail!.isNotEmpty) {
      var panelCount = deviceInfo.detail!["deviceControlList"].length ?? 1;
      if (panelCount == 1) return 'assets/imgs/device/yilu_on.png';
      var panelIndex = int.parse(deviceInfo.type[deviceInfo.type.length - 1]);
      var panelTypeList = ['yilu', 'erlu', 'sanlu', 'silu'];
      var panelType = panelTypeList[panelCount - 1];
      return 'assets/imgs/device/$panelType-0$panelIndex-on.png';
    } else {
      return 'assets/imgs/device/yilu-01-on.png';
    }
  }
}

class SinglePanelApi {
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
  static Future<MzResponseEntity> controlGatewaySwitchPDM(
      DeviceEntity deviceInfo, bool onOff) async {
    var panelIndex = int.parse(deviceInfo.type[deviceInfo.type.length - 1]) - 1;
    var detailRes = await getDetail(deviceInfo.applianceCode, deviceInfo.masterId);
    var endList = detailRes.result["deviceControlList"];
    endList[panelIndex]["attribute"] = endList[panelIndex]["attribute"] == 1 ? 0 : 1;
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(
        deviceInfo.applianceCode, deviceInfo.masterId);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'controlPanelFour',
        deviceInfo.masterId,
        {
          "msgId": uuid.v4(),
          "deviceId": deviceInfo.masterId,
          "nodeId": infoMap["nodeid"],
          "deviceControlList": endList
        },
        method: 'PUT');

    return res;
  }
}
