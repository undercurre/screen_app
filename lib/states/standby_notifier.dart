import 'dart:async';
import 'package:screen_app/common/setting.dart';
import 'package:flutter/material.dart';

import '../common/api/weather_api.dart';
import '../common/global.dart';
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
  int lastUpdateWeatherTime = 0; // 最后刷新天气的时间
  String temperature = '--';

  /// public current state
  StandbyTimeOpt get standbyTimeOpt => _standbyTimeOpt;
  String get weatherCode => _weatherCode;
  bool standbyPageActive = false; // 待机页激活标志，以免重复打开待机页
  Timer? standbyTimer; // Timer实例，有且仅有一个实例，以免重复触发定时器
  Timer? weatherTimer; // 天气获取计时器

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

  Future<void> updateWeather(String cityId) async {
    /// 2023-2-16 增加时间间隔过滤
    /// 严格控制接口的刷新次数，此接口按次收费
    if (DateTime
        .now()
        .millisecondsSinceEpoch - lastUpdateWeatherTime < 4 * 60 * 60 * 1000) {
      return;
    }
    lastUpdateWeatherTime = DateTime
        .now()
        .millisecondsSinceEpoch;

    var weatherOfCityRes = await WeatherApi.getWeather(cityId: cityId);
    if (weatherOfCityRes.isSuccess) {
      var d = weatherOfCityRes.data;
      temperature = d.weather.grade;
      logger.i('全局天气获取');
      weatherCode = d.weather.weatherCode;
    }
  }

  void startWeatherTimer() {
    logger.i('开启全局天气定时器');
    String? areaid = Global.profile.homeInfo?.areaId;
    areaid ??= '101280801'; // 默认顺德区
    updateWeather(areaid!);
    weatherTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      updateWeather(areaid!);
    });
  }
}
