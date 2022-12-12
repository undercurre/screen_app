import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/models/mz_response_entity.dart';
import 'package:screen_app/routes/plugins/device_interface.dart';

class CurtainApi implements DeviceInterface {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getLightDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder('0x14', 'getAllStand', deviceId, {},
        method: 'GET');

    return res;
  }

  /// 设备控制（lua）
  static Future<MzResponseEntity> powerLua(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendLuaOrder(
        '0x13', deviceId, {"power": onOff ? 'on' : 'off'});

    return res;
  }


  /// 开关控制（物模型）
  static Future<MzResponseEntity> powerPDM(String deviceId, bool onOff) async {
    var res = await DeviceApi.sendPDMOrder(
        '0x14', 'switchLightWithTime', deviceId, {"dimTime": 0, "power": onOff},
        method: 'POST');

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
