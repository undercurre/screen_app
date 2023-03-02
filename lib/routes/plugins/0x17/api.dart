import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

import '../../../models/mz_response_entity.dart';

class WrapLiangyi implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await WIFILiangyiApi.getLiangyiDetail(deviceInfo.applianceCode);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    var order = 'pause';
    if (onOff) {
      order = 'down';
    } else {
      order = 'up';
    }
    return await WIFILiangyiApi.updwonLua(deviceInfo.applianceCode, order);
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 过滤sn8
    if (deviceInfo.sn8 == '127PD03G') {
      return false;
    } else {
      return true;
    }
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return deviceInfo.detail != null && deviceInfo.detail != {}
        ? (deviceInfo.detail!["light"] != 'off' &&
            deviceInfo.detail!["updown"] != 'pause')
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
    return 'assets/imgs/device/clothes_hanger_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/clothes_hanger_on.png';
  }
}

class WIFILiangyiApi {
  /// 查询设备状态（Lua）
  static Future<MzResponseEntity> getLiangyiDetail(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0x17', deviceId);

    return res;
  }

  /// 照明控制（lua）
  static Future<MzResponseEntity> lightLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x17', deviceId, {"light": onOff ? 'on' : 'off'});

    return res;
  }

  /// 升降控制（lua）
  static Future<MzResponseEntity> updwonLua(String deviceId, String order) async {
    var res =
        await DeviceApi.sendLuaOrder('0x17', deviceId, {"updown": order});

    return res;
  }
}
