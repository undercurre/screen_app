import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/login/index.dart';
import '../widgets/util/nameFormatter.dart';

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


  static void  showClear(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return const ClearDialog();
      },
    );
  }

  /// 展示loading
  static void hideLoading() {
    EasyLoading.dismiss();
  }

  /// 轻提示弹窗
  static void toast({String content = '', int duration = 2000, EasyLoadingToastPosition? position}) {
    EasyLoading.showToast(
        NameFormatter.formLimitString(content, 25, 20, 0),
        duration: Duration(milliseconds: duration), toastPosition: position);
  }

}

class ClearDialog extends StatelessWidget {
  const ClearDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 412,
        height: 270,
        padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 30),
        decoration: const BoxDecoration(
          color: Color(0xFF494E59),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.center,
                    child:  const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoActivityIndicator(radius: 25),
                          Text(
                            '正在清除中...',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.72),
                              fontSize: 24,
                            ),
                          ),
                        ]))),
          ],
        ),
      ),
    );
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