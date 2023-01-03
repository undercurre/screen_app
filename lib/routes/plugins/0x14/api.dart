import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/models/mz_response_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

class CurtainApi implements DeviceInterface {
  /// 查询设备状态
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0x14', deviceId);
    return res;
  }

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
    // TODO: implement getAttr
    throw UnimplementedError();
  }

  @override
  String getAttrUnit(DeviceEntity deviceInfo) {
    // TODO: implement getAttrUnit
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) {
    // TODO: implement getDeviceDetail
    throw UnimplementedError();
  }

  @override
  String getOffIcon(DeviceEntity deviceInfo) {
    // TODO: implement getOffIcon
    throw UnimplementedError();
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/chuanglian_icon_on.png';
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    // TODO: implement isPower
    throw UnimplementedError();
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    return true;
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) {
    // TODO: implement setPower
    throw UnimplementedError();
  }
}
