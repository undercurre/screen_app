import 'package:flutter_easyloading/flutter_easyloading.dart';

class StrUtils {
  StrUtils._();

  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  /// string not null and empty
  static bool isNotNullAndEmpty(String? s) => s != null && s.trim().isNotEmpty;
}

class TipsUtils {
  TipsUtils._();

  /// 轻提示弹窗
  static void toast({String content = '', int duration = 2000}) {
    EasyLoading.showToast(content, duration: Duration(milliseconds: duration));
  }
}
