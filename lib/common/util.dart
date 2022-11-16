import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class StrUtils {
  StrUtils._();

  /// string is null or empty
  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  /// string not null and empty
  static bool isNotNullAndEmpty(String? s) => s != null && s.trim().isNotEmpty;
}

class TipsUtils {
  TipsUtils._();

  static void toast({required BuildContext context, String title = '', String content = ''}) {
    MotionToast(
      primaryColor:  Colors.black,
      width:  200,
      height:  80,
      title: Text(
        title,
      ),
      description: Text(
        content,
      ),
      position:  MotionToastPosition.top,
      animationType:  AnimationType.fromTop,
      layoutOrientation: ToastOrientation.rtl,
      dismissable: false,
      icon: Icons.sunny,
    ).show(context);
  }
}