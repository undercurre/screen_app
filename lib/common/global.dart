import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:uuid/uuid.dart';

import 'api/index.dart';
import 'util.dart';
import '../models/index.dart';

/// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.grey,
];

/// 日志打印工具
var logger = Logger(
  printer: PrettyPrinter(printTime: true),
);

class Global {
  // 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  static var productCode = 'MSP-A101D-01';

  static late SharedPreferences _prefs;
  static Profile profile = Profile();

  static bool get isLogin => profile.user != null;

  static User? get user => profile.user;

  static set user(User? value) {
    debugPrint('setUser $user');
    profile.user = value;
  }

  /// 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    var profileJson = _prefs.getString("profile");

    logger.d('profileJson: $profileJson');
    if (profileJson != null) {
      try {
        profile = Profile.fromJson(jsonDecode(profileJson));
      } catch (e) {
        logger.w('profileJson-error: ${e.toString()}');
        _prefs.remove('profile');
        profile = Profile();
      }
    }

    // if (StrUtils.isNullOrEmpty(profile.deviceId)) {
    String? deviceId = await PlatformDeviceId.getDeviceId;
    // windows 下会获取到特殊字符，为了开发方便需要使用windows进行开发调试
    deviceId = deviceId?.replaceAll(' ', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');
    logger.i('deviceId: $deviceId');

    if (StrUtils.isNullOrEmpty(deviceId)) {
      const uuid = Uuid();
      deviceId = uuid.v4();
    }
    profile.deviceId = deviceId;
    // }

    saveProfile();

    //初始化网络请求相关配置
    Api.init();
  }

  /// 持久化Profile信息
  static saveProfile() {
    logger.i('saveProfile: ${profile.toJson()}');
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

  /// 退出登录
  static loginOut() {
    profile.user = null;
    profile.homeInfo = null;
    profile.roomInfo = null;
  }
}
