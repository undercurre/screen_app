import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../channel/index.dart';
import '../../../common/api/api.dart';
import '../../../models/mz_response_entity.dart';

class WrapSmartControl implements DeviceInterface {
  static bool localRelay1 = false;
  static bool localRelay2 = false;

  WrapSmartControl() {
    gatewayChannel.relay2IsOpen()
        .then((value) => localRelay2 = value);
    gatewayChannel.relay1IsOpen()
        .then((value) => localRelay1 = value);
  }


  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    if(deviceInfo.applianceCode == Global.profile.applianceCode) {
      return {
        'code': 123
      };
    } else {
      var res = await SmartControlApi.getGatewayDetail(deviceInfo.applianceCode);
      if (res.code == 0 && res.httpJson?["result"] != null) {
        return res.result;
      } else {
        return {};
      }
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    logger.i('刷新加载是否本地智慧屏??', deviceInfo.applianceCode == Global.profile.applianceCode);
    if (deviceInfo.applianceCode != Global.profile.applianceCode) {
      logger.i('当前设备code', deviceInfo.applianceCode);
      logger.i('全局设备code', Global.profile.applianceCode);
    }
    if(deviceInfo.applianceCode == Global.profile.applianceCode) {
      if(deviceInfo.type == 'smartControl-1') {

        gatewayChannel.controlRelay1Open(!localRelay1);
        localRelay1 = !localRelay1;
        return MzResponseEntity()
            ..code = 0
            ..msg = '';
      } else {
        gatewayChannel.controlRelay2Open(!localRelay2);
        localRelay2 = !localRelay2;
        return MzResponseEntity()
          ..code = 0
          ..msg = '';
      }
    } else {
      return await SmartControlApi.controlGatewaySwitchPDM(deviceInfo, onOff);
    }
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
    logger.i('刷新加载1', localRelay1);
    logger.i('刷新加载2', localRelay2);
    logger.i('刷新加载是否本地智慧屏???', deviceInfo.applianceCode == Global.profile.applianceCode);
    if (deviceInfo.applianceCode != Global.profile.applianceCode) {
      logger.i('当前设备code', deviceInfo.applianceCode);
      logger.i('全局设备code', Global.profile.applianceCode);
    }
    if(deviceInfo.applianceCode == Global.profile.applianceCode) {
      if(deviceInfo.type == 'smartControl-1') {
        return localRelay1;
      } else {
        return localRelay2;
      }
    } else {
      return deviceInfo.detail != null && deviceInfo.detail!.isNotEmpty ? (deviceInfo.type == 'smartControl-1' ? deviceInfo.detail!["panelOne"] : deviceInfo.detail!["panelTwo"]) : false;
    }
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
    logger.i('智慧屏当前状态', detailRes.result);
    var panelOne = deviceInfo.type == 'smartControl-1' ? onOff : detailRes.result["panelOne"];
    var panelTwo = deviceInfo.type == 'smartControl-1' ? detailRes.result["panelTwo"] : onOff;
    logger.i('智慧屏线控器操作', [panelOne, panelTwo]);
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
