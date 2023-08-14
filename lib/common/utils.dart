import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StrUtils {
  StrUtils._();

  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  /// string not null and empty
  static bool isNotNullAndEmpty(String? s) => s != null && s.trim().isNotEmpty;
}

class TipsUtils {
  TipsUtils._();

  /// 展示loading
  static void showLoading([String? text]) {
    EasyLoading.show(status: text ?? 'Loading');
  }

  /// 展示loading
  static void hideLoading() {
    EasyLoading.dismiss();
  }

  /// 轻提示弹窗
  static void toast({String content = '', int duration = 2000, EasyLoadingToastPosition? position}) {
    EasyLoading.showToast(content, duration: Duration(milliseconds: duration), toastPosition: position);
  }
}

class LocalStorage {
  LocalStorage._();
  /// Flutter版localStorage
  // 存储数据
  static Future<void> setItem(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  // 读取数据
  static Future<String?> getItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // 删除数据
  static Future<bool> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  // 清除所有数据
  static Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

}