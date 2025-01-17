import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:screen_app/widgets/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/index.dart';
import 'api/index.dart';
import 'logcat_helper.dart';
import 'utils.dart';

/// 日志打印工具
@Deprecated('废弃API请使用Log.xx方法')
var logger = const ProxyLogger();

@Deprecated("废弃API请使用System")
class Global {
  // 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  static var productCode = 'D3ZZKP-Z';
  static var sn8 = 'MSGWZ010';

  static late SharedPreferences _prefs;
  static ProfileEntity profile = ProfileEntity();

  static bool get isLogin => profile.user != null;

  static UserEntity? get user => profile.user;

  static set user(UserEntity? value) {
    debugPrint('setUser $value');
    profile.user = value;
  }

  /// 初始化全局信息，会在APP启动时执行
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    var profileJson = _prefs.getString("profile");

    logger.d('profileJson: $profileJson');
    if (profileJson != null) {
      try {
        profile = ProfileEntity.fromJson(jsonDecode(profileJson));
      } catch (e) {
        logger.w('profileJson-error: ${e.toString()}');
        _prefs.remove('profile');
        profile = ProfileEntity();
      }
    }

    if (StrUtils.isNullOrEmpty(profile.deviceId)) {
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
      profile.deviceId = deviceId;
    }

    saveProfile();

    initLoading();
    //初始化网络请求相关配置
    Api.init();
  }

  /// 持久化Profile信息
  static saveProfile() {
    logger.i('saveProfile: ${profile.toJson()}');
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

  /// 初始化全局loading配置
  static initLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 40.0
      ..progressColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..backgroundColor = const Color.fromRGBO(87, 87, 87, 1)
      ..indicatorColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..textColor = const Color.fromRGBO(255, 255, 255, 0.85)
      ..fontSize = 22
      ..contentPadding = const EdgeInsets.fromLTRB(32, 20, 32, 20)
      ..userInteractions = true
      ..dismissOnTap = false;

    EasyLoading.addStatusCallback((status) {
      debugPrint('EasyLoading Status $status');
    });
  }

  ///全局亮度
  static num lightValue = 204;

  ///全局音量
  static num soundValue = 10;

  ///全局自动亮度
  static bool autoLight = false;

  ///全局靠近唤醒
  static bool nearWakeup = true;
}

/// 全局路由监听
class GlobalRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    String log = '[路由跳转]: to:${route.settings.name}, from:${previousRoute?.settings.name}';
    Log.file(log);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    runZonedGuarded(() {
      // debugPrint(
      //     'didPop: ${route.settings.name}, from:${previousRoute?.settings.name}');
      // if (previousRoute?.settings.name == 'Home') {
      //   DeviceListModel().updateAllDetail();
      // }
      const blacklist = [null, 'SnifferPage'];
      if (previousRoute?.settings.name == 'Home' &&
          !blacklist.contains(route.settings.name)) {
        bus.emit("backHome");
      }
    }, (error, stack) {

    });
  }

}

final GlobalRouteObserver<PageRoute> globalRouteObserver =
    GlobalRouteObserver<PageRoute>();
