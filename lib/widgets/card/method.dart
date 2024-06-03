import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

LinearGradient getBigCardColorBg(String key) {
  if (key == 'disabled') {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x33616A76),
        Color(0x33434852),
      ],
      stops: [0.06, 1.0],
      transform: GradientRotation(213 * (3.1415926 / 360.0)),
    );
  } else if (key == 'discriminative') {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.12)],
      stops: [0.06, 1.0],
      transform: GradientRotation(213 * (3.1415926 / 360.0)),
    );
  } else if (key == 'fault') {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x77AE4C5E),
        Color.fromRGBO(167, 78, 97, 0.32),
      ],
      stops: [0, 1],
      transform: GradientRotation(222 * (3.1415926 / 360.0)),
    );
  } else {
    return const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [
        Color(0xFF175179), // 原始第一色
        Color(0xFF245F83), // 新增过渡色
        Color(0xFF36678A), // 原始第二色
        Color(0xFF3F6D8E), // 新增过渡色
        Color(0xFF456F90), // 原始第三色
        Color(0xFF3D6985), // 新增过渡色
        Color(0xFF34567C), // 原始第四色
        Color(0xFF2F5176), // 新增过渡色
      ],
      stops: [0.0, 0.14, 0.28, 0.42, 0.59, 0.73, 0.87, 1.0],
    );
  }
}
