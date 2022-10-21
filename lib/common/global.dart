import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
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

var logger = Logger(
  printer: PrettyPrinter(),
);

class Global {
  static var productCode = 'MSP-A101D-01';
  static late SharedPreferences _prefs;
  static Profile profile = Profile();

  /// 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  /// 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    var profileJson = _prefs.getString("profile");

    logger.d('isRelease: $isRelease');
    logger.d('profileJson: $profileJson');
    if (profileJson != null) {
      try {
        profile = Profile.fromJson(jsonDecode(profileJson));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      // 默认主题索引为0，代表蓝色
      profile = Profile()..theme = 0;
    }

    //初始化网络请求相关配置
    Api.init();
  }

  /// 持久化Profile信息
  static saveProfile() =>
      _prefs.setString("profile", jsonEncode(profile.toJson()));
}
