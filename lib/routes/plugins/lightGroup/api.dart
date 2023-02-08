import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/mz_response_entity.dart';
import '../../../common/global.dart';

const uuid = Uuid();

class WrapLightGroup implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await LightGroupApi.getLightDetail(deviceInfo);
    return res.result["result"];
  }

  @override
  Future<MzResponseEntity<dynamic>> setPower(DeviceEntity deviceInfo, bool onOff) async {
    var res = MzResponseEntity();
    res.code = 0;
    res.result = await LightGroupApi.powerPDM(deviceInfo, onOff);
    return res;
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤modelNumber
    return deviceInfo.type == 'lightGroup';
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return deviceInfo.detail != null ? deviceInfo.detail!["detail"]["switchStatus"] == "1" : false;
  }

  @override
  String getAttr(DeviceEntity deviceInfo) {
    return deviceInfo.detail != null ? deviceInfo.detail!["detail"]["brightness"] : '';
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    return '%';
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/dengzu_icon_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    // todo: 改成凉霸图标
    return 'assets/imgs/device/dengzu_icon_on.png';
  }
}

class LightGroupApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getLightDetail(
      DeviceEntity deviceInfo) async {
    var res = await DeviceApi.groupRelated(
        'findLampGroupDetails',
        const JsonEncoder().convert({
          "houseId": Global.profile.homeInfo?.homegroupId,
          "groupId": deviceInfo.detail?["detail"]["groupId"],
          "modelId": "midea.light.003.001",
          "uid": Global.profile.user?.uid,
        }));
    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(DeviceEntity deviceInfo,bool power) async {
    var res = await DeviceApi.groupRelated(
        'lampGroupControl',
        const JsonEncoder().convert({
          "houseId": Global.profile.homeInfo?.homegroupId,
          "groupId": deviceInfo.detail?["detail"]["groupId"],
          "modelId": "midea.light.003.001",
          "lampAttribute": '0',
          "lampAttributeValue": power ? '1' : '0',
          "transientTime": '0',
          "uid": Global.profile.user?.uid,
        }));

    return res;
  }

  /// 亮度控制（物模型）
  static Future<MzResponseEntity> brightnessPDM(
      DeviceEntity deviceInfo, num value) async {
    var res = await DeviceApi.groupRelated(
        'lampGroupControl',
        const JsonEncoder().convert({
          "houseId": Global.profile.homeInfo?.homegroupId,
          "groupId": deviceInfo.detail?["detail"]["groupId"],
          "modelId": "midea.light.003.001",
          "lampAttribute": '1',
          "lampAttributeValue": value.toString(),
          "transientTime": '0',
          "uid": Global.profile.user?.uid,
        }));

    return res;
  }

  /// 色温控制（物模型）
  static Future<MzResponseEntity> colorTemperaturePDM(
      DeviceEntity deviceInfo, num value) async {
    var res = await DeviceApi.groupRelated(
        'lampGroupControl',
        const JsonEncoder().convert({
          "houseId": Global.profile.homeInfo?.homegroupId,
          "groupId": deviceInfo.detail?["detail"]["groupId"],
          "modelId": "midea.light.003.001",
          "lampAttribute": '2',
          "lampAttributeValue": value.toString(),
          "transientTime": '0',
          "uid": Global.profile.user?.uid,
        }));

    return res;
  }
}
