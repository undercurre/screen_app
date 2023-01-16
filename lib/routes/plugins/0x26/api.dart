import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_entity.dart';

import '../../../models/mz_response_entity.dart';
import '../device_interface.dart';

/// 浴霸控制接口
class BaseApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder(
      '0x26',
      '__fullQuery__',
      deviceId,
      {},
      method: 'GET',
    );
    return res;
  }

  /// 查询设备状态（lua）
  static Future<MzResponseEntity> getDetailByLua(String deviceId) async {
    var res = await DeviceApi.getDeviceDetail('0x26', deviceId);
    return res;
  }

  /// 物模型控制
  static Future<MzResponseEntity> wotControl(
      String deviceId, String command, Map data) async {
    var res = await DeviceApi.sendPDMOrder('0x26', command, deviceId, data,
        method: 'POST');
    return res;
  }

  /// Lua控制
  static Future<MzResponseEntity> luaControl(String deviceId, Map data) async {
    var res = await DeviceApi.sendLuaOrder('0x26', deviceId, data);
    return res;
  }
}

/// 提供给DeviceList调用的接口实现
class DeviceListApiImpl implements DeviceInterface {
  @override
  Future<Map<String, dynamic>> getDeviceDetail(DeviceEntity deviceInfo) async {
    final res = await BaseApi.getDetailByLua(deviceInfo.applianceCode);
    if (res.success) {
      return res.result;
    } else {
      throw Error();
    }
  }

  @override
  Future<MzResponseEntity> setPower(DeviceEntity deviceInfo, bool onOff) {
    if (onOff) {
      // 设备列表点击开电源，打开
      return BaseApi.luaControl(
        deviceInfo.applianceCode,
        {'mode': 'ventilation'},
      );
    } else {
      // 全关
      return BaseApi.luaControl(
        deviceInfo.applianceCode,
        {'mode': 'close_all', 'light_mode': ''},
      );
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
    return 'assets/imgs/device/bath_heater_off.png';
  }

  @override
  String getOnIcon(DeviceEntity deviceInfo) {
    return 'assets/imgs/device/bath_heater_on.png';
  }

  @override
  bool isPower(DeviceEntity deviceInfo) {
    final data = deviceInfo.detail;
    if (data == null) {
      return false;
    }
    if (data['mode'] != 'close_all' || data['light_mode'] != 'close_all') {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool isSupport(DeviceEntity deviceInfo) {
    // 目前的所有凉霸都支持
    return true;
  }
}
