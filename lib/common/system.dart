import 'index.dart';

class System {
  static Future<void> refreshToken() async {
    await UserApi.autoLogin();

    // 获取美智token
    await UserApi.authToken();

    Global.saveProfile();
  }

  /// 退出登录
  static loginOut() {
    Global.profile.user = null;
    Global.profile.homeInfo = null;
    Global.profile.roomInfo = null;
    Global.saveProfile();
  }
}

