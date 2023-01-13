import 'dart:async';

import 'index.dart';

class System {
  static Timer? updateTokenTimer;

  static Future<void> refreshToken() async {
    await UserApi.autoLogin();

    // 获取美智token
    await UserApi.authToken();

    // 定时刷新token，续期
    updateTokenTimer = Timer(const Duration(hours: 3, minutes: 30), () {
      refreshToken();
    });

    Global.saveProfile();
  }

  /// 退出登录
  static loginOut() {
    Global.profile.user = null;
    Global.profile.homeInfo = null;
    Global.profile.roomInfo = null;
    Global.saveProfile();
    updateTokenTimer?.cancel();
  }
}
