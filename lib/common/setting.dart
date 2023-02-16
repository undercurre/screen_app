

import 'package:flutter/cupertino.dart';
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

  /// 待机时间选择序号
  late int standbyTimeOptNum;

  /// 屏保样式ID
  /// 0 ~ 8
  late int _screenSaverId;

  /// 待机时间持久化存储key
  final String _standbyTimeKey = 'standby_time_key';

  void init() async {
    _prefs = await SharedPreferences.getInstance();
    int screedStartTime = _prefs.getInt("setting_screed_start_time") ?? -1;
    int screedEndTime = _prefs.getInt("setting_screed_end_time") ?? -1;
    _screedDuration = Pair.of(screedStartTime, screedEndTime);

    standbyTimeOptNum = _prefs.getInt(_standbyTimeKey) ?? 2; /// 默认选序号2的选项（从0开始）
    _screenSaverId = _prefs.getInt('setting_screen_saver_id') ?? 0; ///默认的屏保样式为0
  }

  /// 保存屏保的序号id
  void saveScreenSaverId(int id) {
    if(id < 0 || id > 8) throw Exception("请设置正确范围的屏保Id值");
    _prefs.setInt('setting_screen_saver_id', id);
    _screenSaverId = id;
  }

  /// 获取屏保的序号
  int get screenSaverId => _screenSaverId;

  /// 保存屏保的序号
  set screenSaverId(int id) {
    if(id < 0 || id > 9) throw Exception("请设置正确范围的屏保Id值");
    _prefs.setInt('setting_screen_saver_id', id);
    _screenSaverId = id;
  }

  /// 设置息屏时间段
  Future<bool> setScreedDuration(Pair<int, int> duration) async {
    if(duration.value2 < 0 || duration.value1 <0 || duration.value1 >= duration.value2) {
      throw Exception("请设置正确的时间区间");
    }
    _screedDuration = duration;
    _prefs.setInt("setting_screed_start_time", duration.value1);
    _prefs.setInt("setting_screed_end_time", duration.value2);
    return true;
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
    final startMinute = format.format(result.value1 % 60);
    final endHour = format.format(result.value2 ~/ 60 % 24);
    final endMinute = format.format(result.value2 % 60);
    if(result.value2 ~/ 60 >= 24) {
      return "$startHour:$startMinute - 第二天 $endHour:$endMinute";
    } else {
      return "$startHour:$startMinute - $endHour:$endMinute";
    }
  }
  /// 解析息屏时间
  /// 参数：[time] 具体的时间
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

  /// 设置待机时间选择序号
  void setStandbyTimeOptNum(int opt) {
    _prefs.setInt(_standbyTimeKey, opt);
  }

  /// 当前是否在息屏时间段
  bool isStandByDuration() {
    Pair<int, int> duration = getScreedDuration();
    if(duration.value2 < 0 || duration.value1 < 0) return false;
    final now = DateTime.now();
    final index = now.hour * 60 + now.minute;
    final start = duration.value1;
    final end = duration.value2;
    debugPrint('start = $start end = $end index = $index');
    return index >= start && index < end;
  }
}