import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/models/mz_response_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

class CurtainApi implements DeviceInterface {
  /// 设备控制（lua）
  static Future<MzResponseEntity> changePosition(String deviceId, num position, String dir) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x14', deviceId, {"curtain_position": position, 'curtain_direction': dir});
    return res;
  }

  static Future<MzResponseEntity> setMode(String deviceId, String modeKey, String dir) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x14', deviceId, {"curtain_status": modeKey, 'curtain_direction': dir});
    return res;
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
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    var res = await DeviceApi.getDeviceDetail('0x14', deviceInfo.applianceCode);
    if (res.code == 0) {
      return res.result;
    } else {
      return {};
    }
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    return '';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/chuanglian_icon_on.png';
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    return true;
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    return true;
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x14', deviceInfo.applianceCode, {"curtain_status": onOff ? 'open' : 'close', 'curtain_direction': 'positive'});
    return res;
  }
}
