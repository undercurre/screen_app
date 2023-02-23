import 'dart:async';
import 'package:screen_app/common/setting.dart';
import 'package:flutter/material.dart';

import '../widgets/standby.dart';

class StandbyTimeOpt {
  int value = 30; // 值，秒为单位
  int key;

  String get title { // 显示文字
    if (value == -1) {
      return '永不';
    }
    else if (value < 60) {
      return '$value秒后';
    }
    return '${(value ~/ 60)}分钟后';
  }

  StandbyTimeOpt({ required this.value, required this.key});
}

// 待机时间待选列表
List<StandbyTimeOpt> timerList = [
  StandbyTimeOpt(key: 0, value: 30),
  StandbyTimeOpt(key: 1, value: 60),
  StandbyTimeOpt(key: 2, value: 180),
  StandbyTimeOpt(key: 3, value: 300),
  StandbyTimeOpt(key: 4, value: -1),
];

class StandbyChangeNotifier extends ChangeNotifier {
  /// private state holder
  StandbyTimeOpt _standbyTimeOpt = timerList[Setting.instant().standbyTimeOptNum]; // 默认3分钟
  String _weatherCode = '00'; // 天气代码

  /// public current state
  StandbyTimeOpt get standbyTimeOpt => _standbyTimeOpt;
  String get weatherCode => _weatherCode;
  bool standbyPageActive = false; // 待机页激活标志，以免重复打开待机页
  Timer? standbyTimer; // Timer实例，有且仅有一个实例，以免重复触发定时器

  /// setters
  set weatherCode(String code) {
    _weatherCode = code;

    notifyListeners();
  }

  set setTimerByNum(int opt) {
    _standbyTimeOpt = timerList[opt];
    Setting.instant().setStandbyTimeOptNum(opt);
    ShowStandby.startTimer();
    notifyListeners();
  }
}
