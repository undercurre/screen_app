import 'package:flutter/material.dart';

class StandbyTimer {
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

  StandbyTimer({ required this.value, required this.key});
}

// 待机时间待选列表
List<StandbyTimer> timerList = [
  StandbyTimer(key: 0, value: 30),
  StandbyTimer(key: 1, value: 60),
  StandbyTimer(key: 2, value: 180),
  StandbyTimer(key: 3, value: 300),
  StandbyTimer(key: 4, value: -1),
];

class WeatherChangeNotifier extends ChangeNotifier {
  /// private state holder
  StandbyTimer _standbyTimer = timerList[2]; // 默认3分钟
  String _weatherCode = '00';

  /// public current state
  StandbyTimer get standbyTimer => _standbyTimer;
  String get weatherCode => _weatherCode;

  /// setters
  set weatherCode(String code) {
    _weatherCode = code;

    notifyListeners();
  }

  set setTimerByNum(int opt) {
    _standbyTimer = timerList[opt];

    notifyListeners();
  }
}
