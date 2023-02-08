import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../common/api/api.dart';
import '../../../models/mz_response_entity.dart';

class WrapSmartControl implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await SmartControlApi.getGatewayDetail(deviceInfo.applianceCode);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    return await SmartControlApi.controlGatewaySwitchPDM(deviceInfo, onOff);
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤sn8
    if (deviceInfo.sn8 == 'MSGWZ010' || deviceInfo.sn8 == 'MSGWZ013') {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return deviceInfo.detail != null ? (deviceInfo.type == 'smartControl-1' ? deviceInfo.detail!["panelOne"] : deviceInfo.detail!["panelTwo"]) : false;
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

class SmartControlApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getGatewayDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16', 'gatewayGetStatus', deviceId, {
          "msgId": uuid.v4(),
          "deviceId": deviceId
    },
        method: 'PUT');
    return res;
  }

  /// 开关控制（物模型）
  static Future<MzResponseEntity> controlGatewaySwitchPDM(DeviceEntity deviceInfo, bool onOff) async {
    var detailRes = await getGatewayDetail(deviceInfo.applianceCode);
    var panelOne = deviceInfo.type == 'smartControl-1' ? onOff : detailRes.result["panelOne"];
    var panelTwo = deviceInfo.type == 'smartControl-1' ? detailRes.result["panelTwo"] : onOff;
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'gatewaySwitchControl',
        deviceInfo.applianceCode,
        {
          "panelOne": panelOne,
          "msgId": uuid.v4(),
          "deviceId": deviceInfo.applianceCode,
          "panelTwo": panelTwo
        },
        method: 'PUT');

    return res;
  }
}
