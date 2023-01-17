

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper.dart';

/// 系统设置的配置
class Setting {
  static final Setting _instant = Setting._fromInstant();
  Setting._fromInstant();
  static Setting instant() {
    return _instant;
  }
  /// 息屏时间段
  /// Pair.value1 为起始时间 Pair.value2 为结束时间
  late Pair<int , int> _screedDuration;
  late SharedPreferences _prefs;

  void init() async {
    _prefs = await SharedPreferences.getInstance();
    int screedStartTime = _prefs.getInt("setting_screed_start_time") ?? -1;
    int screedEndTime = _prefs.getInt("setting_screed_end_time") ?? -1;
    _screedDuration = Pair.of(screedStartTime, screedEndTime);

  }
  /// 设置息屏时间段
  void setScreedDuration(Pair<int, int> duration) async {
    if(duration.value2 < 0 || duration.value1 <0 || duration.value1 >= duration.value2) {
      throw Exception("请设置正确的时间区间");
    }
    _screedDuration = duration;
    _prefs.setInt("setting_screed_start_time", duration.value1);
    _prefs.setInt("setting_screed_end_time", duration.value2);
  }
  /// 获取息屏时间段
  Pair<int, int> getScreedDuration() {
    return _screedDuration;
  }
  /// 获取息屏时间段的文字描述
  String getScreedDurationDetail() {
    final result = _screedDuration;
    if(result.value1 == -1 || result.value2 == -1 || result.value1 >= result.value2 ) {
      return '暂未设置';
    }
    final format = NumberFormat('00', 'en_US');
    final startHour = format.format(result.value1 ~/ 60 % 24);
    final startMinute = format.format(result.value2 % 60);
    final endHour = format.format(result.value2 ~/ 60 % 24);
    final endMinute = format.format(result.value2 % 60);
    if(result.value2 ~/ 60 >= 24) {
      return "$startHour:$startMinute - 第二天 $endHour:$endMinute";
    } else {
      return "$startHour:$startMinute - $endHour:$endMinute";
    }
  }
  /// 获取息屏--开始时间
  /// Pair.value1为小时 Pair.value2为分钟
  Pair<int, int> getScreedDetailTime(int time) {
    if(time < 0 ) {
      return Pair.of(-1, -1);
    } else if(time == 0) {
      return Pair.of(0, 0);
    } else {
      final startHour = time ~/ 60;
      final startMinute = time % 60;
      return Pair.of(startHour, startMinute);
    }
  }

}