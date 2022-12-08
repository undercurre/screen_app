import 'package:screen_app/common/api/device_api.dart';
import '../../../models/mz_response_entity.dart';
import '../device_interface.dart';
import './mode_list.dart';

/// 浴霸控制接口
class BaseApi {
  /// 查询设备状态（物模型）
  static Future<MzResponseEntity> getDetail(String deviceId) async {
    var res = await DeviceApi.sendPDMOrder(
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
    var res =
        await DeviceApi.sendPDMOrder(command, deviceId, data, method: 'POST');
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
  Future<Map<String, dynamic>> getDeviceDetail(String deviceId) async {
    final res = await BaseApi.getDetail(deviceId);
    if (!res.success) {
      throw Error();
    }
    var power = false;
    if (res.result['runMode'] != null) {
      for (var element in bathroomMasterMode) {
        if (res.result['runMode'][element.key] == true) {
          power = true;
        }
      }
    }
    if (res.result['lightMode'] != null) {
      if (res.result['lightMode']['mainLight'] == true ||
          res.result['lightMode']['nightLight'] == true) {
        power = true;
      }
    }
    res.result['power'] = power;
    return res.result;
  }

  @override
  Future<MzResponseEntity> setPower(
      String deviceId, bool onOff) {
    if (onOff) {
      // 设备列表点击开电源
      return BaseApi.luaControl(
        deviceId,
        {'mode': 'blowing'},
      );
    } else {
      // 全关
      return BaseApi.luaControl(
        deviceId,
        {'mode': 'close_all'},
      );
    }
  }
}
