import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'index.dart';

class System {
  /// 产品编码
  static const String PRODUCT = "D3ZZKP-Z";
  /// 设备Id 存储的key
  static const String DEVICE_ID = "device_id";

  static String? deviceId;

  static void init() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    /// 初始化设备ID
    System.deviceId = pre.getString(DEVICE_ID);
    if(StrUtils.isNullOrEmpty(System.deviceId)) {
      String deviceId = await PlatformDeviceId.getDeviceId ?? '';
      // windows 下会获取到特殊字符，为了开发方便需要使用windows进行开发调试
      deviceId = deviceId
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '');
      logger.i('deviceId: $deviceId');

      if (StrUtils.isNullOrEmpty(deviceId)) {
        const uuid = Uuid();
        deviceId = uuid.v4();
      }
      System.deviceId = deviceId;
      pre.setString(DEVICE_ID, deviceId);
    }

  }

  /// 退出登录
  @Deprecated("该方法已经过期，请不要再调用")
  static loginOut() {
    Global.profile.user = null;
    Global.profile.homeInfo = null;
    Global.profile.roomInfo = null;
    Global.saveProfile();
  }

}
