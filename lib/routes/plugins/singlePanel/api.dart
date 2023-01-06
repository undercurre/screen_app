import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
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
    return deviceInfo.detail != null
        ? deviceInfo.detail!["status"]["attribute"] == 1
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
    return 'assets/imgs/device/dengguang_icon_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/dengguang_icon_on.png';
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
    var curEnd = deviceInfo.detail!["status"]["endPoint"];
    var detailRes = await getDetail(deviceInfo.applianceCode, deviceInfo.masterId);
    var endList = detailRes.result["deviceControlList"];
    endList[curEnd - 1]["attribute"] = endList[curEnd - 1]["attribute"] == 1 ? 0 : 1;
    debugPrint("指令：$endList");
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'controlPanelFour',
        deviceInfo.applianceCode,
        {
          "msgId": "12345",
          "deviceId": "183618441839263",
          "nodeId": "60A423FFFE1D3199",
          "deviceControlList": endList
        },
        method: 'PUT');

    return res;
  }
}
