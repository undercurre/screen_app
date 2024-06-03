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


List<Color> getSceneBgColor(String key) {
  List<Color> defaultBg = [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.12)];

  List<Color> all_on = [
    Color(0xFF305D78), // 新增过渡色
    Color(0xFF33617F), // 原始第三色
    Color(0xFF496A83), // 新增过渡色
    Color(0xFF576E87), // 原始第二色
    Color(0xFF596D81), // 新增过渡色
    Color(0xFF5C747B), // 原始第一色
  ];

  List<Color> all_off = [
    Color(0xFF7C6A6C), // 原始第一色
    Color(0xFF736A76), // 新增过渡色
    Color(0xFF636A85), // 原始第二色
    Color(0xFF5C6888), // 新增过渡色
    Color(0xFF57638C), // 原始第三色
    Color(0xFF506288), // 新增过渡色
  ];

  List<Color> bright = [
    Color(0xFF80736E), // 新增过渡色
    Color(0xFF7B746A), // 原始第三色
    Color(0xFF717570), // 新增过渡色
    Color(0xFF657581), // 原始第二色
    Color(0xFF5E7287), // 新增过渡色
    Color(0xFF586F8A), // 原始第一色
  ];

  List<Color> mild = [
    Color(0xFF5F5892), // 原始第一色
    Color(0xFF54608F), // 新增过渡色
    Color(0xFF48678E), // 原始第二色
    Color(0xFF4D6E8A), // 新增过渡色
    Color(0xFF5C7885), // 原始第三色
    Color(0xFF587785), // 新增过渡色
  ];

  final Map<String, List<Color>> codeToColor = {
    'null': defaultBg,
    'default': all_off,
    '1': all_on,
    '2': all_off,
    '3': bright,
    '4': mild,
    '5': all_on,
    '6': all_off,
    '7': all_off,
    '8': bright,
    '9': all_off,
    '10': all_off,
    '11': all_on,
    '12': mild,
    '13': all_off,
    '14': all_off,
    '15': all_off,
    '16': all_off,
    '17': mild,
    '18': mild,
    '19': bright,
    '20': all_off,
    '21': all_on,
    '22': all_off,
    '23': all_off,
    '24': bright,
    '25': all_off,
    'all-on': all_on,
    'all-off': all_off,
    'bright': bright,
    'catering': all_on,
    'general': all_off,
    'go-home': all_on,
    'leave-hoom': all_off,
    'leisure': bright,
    'mild': mild,
    'movie': all_on,
    'night': mild,
    'read': bright,
    'icon-1': bright,
    'icon-2': all_on,
    'icon-3': mild,
    'icon-4': all_off,
    'icon-5': all_on,
    'icon-6': bright,
    'icon-7': all_off,
    'icon-8': mild,
    'icon-9': mild,
    'icon-10': all_off,
    'icon-11': bright,
    'icon-12': all_on,
    'icon-13': all_off,
    'icon-14': all_on,
    'icon-15': mild,
    'icon-16': bright,
  };

  return codeToColor[key] ?? defaultBg;
}

List<double> getSceneBgStop(String key) {
  List<double> defaultStop = [0.06, 1.0];
  List<double> all_on = [0.0, 0.22, 0.44, 0.66, 0.88, 1.0];
  List<double> all_off = [0.0, 0.26, 0.52, 0.68, 0.84, 1.0];
  List<double> bright = [0.0, 0.18, 0.36, 0.53, 0.71, 1.0];
  List<double> mild = [0.0, 0.19, 0.38, 0.57, 0.76, 1.0];

  final Map<String, List<double>> codeToStop = {
    'null': defaultStop,
    'default': all_off,
    '1': all_on,
    '2': all_off,
    '3': bright,
    '4': mild,
    '5': all_on,
    '6': all_off,
    '7': all_off,
    '8': bright,
    '9': all_off,
    '10': all_off,
    '11': all_on,
    '12': mild,
    '13': all_off,
    '14': all_off,
    '15': all_off,
    '16': all_off,
    '17': mild,
    '18': mild,
    '19': bright,
    '20': all_off,
    '21': all_on,
    '22': all_off,
    '23': all_off,
    '24': bright,
    '25': all_off,
    'all-on': all_on,
    'all-off': all_off,
    'bright': bright,
    'catering': all_on,
    'general': all_off,
    'go-home': all_on,
    'leave-hoom': all_off,
    'leisure': bright,
    'mild': mild,
    'movie': all_on,
    'night': mild,
    'read': bright,
    'icon-1': bright,
    'icon-2': all_on,
    'icon-3': mild,
    'icon-4': all_off,
    'icon-5': all_on,
    'icon-6': bright,
    'icon-7': all_off,
    'icon-8': mild,
    'icon-9': mild,
    'icon-10': all_off,
    'icon-11': bright,
    'icon-12': all_on,
    'icon-13': all_off,
    'icon-14': all_on,
    'icon-15': mild,
    'icon-16': bright,
  };

  return codeToStop[key] ?? defaultStop;
}