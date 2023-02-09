import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../common/api/api.dart';
import '../../../models/mz_response_entity.dart';

class WrapGateway implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await GatewayApi.getGatewayDetail(deviceInfo.applianceCode);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    return await GatewayApi.controlGatewaySwitchPDM(deviceInfo.applianceCode, onOff);
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤sn8
    return false;
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return false;
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

class GatewayApi {
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
  static Future<MzResponseEntity> controlGatewaySwitchPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x16',
        'gatewaySwitchControl',
        deviceId,
        {
          "panelOne": true,
          "msgId": uuid.v4(),
          "deviceId": deviceId,
          "panelTwo": true
        },
        method: 'PUT');

    return res;
  }
}
