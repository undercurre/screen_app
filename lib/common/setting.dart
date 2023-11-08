

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../channel/index.dart';
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
  /// 夜间模式使能
  late bool _nightModeEnable;
  /// 是否屏保改为直接熄屏
  late bool _screenSaverReplaceToOff;

  late SharedPreferences _prefs;

  /// 待机时间选择序号
  late int standbyTimeOptNum;

  /// 屏保样式ID
  /// 0 ~ 8
  late int _screenSaverId;

  /// 待机时间持久化存储key
  final String _standbyTimeKey = 'standby_time_key';

  /// AI语音使能
  late bool _aiEnable;

  late bool _homluxAiEnable;

  /// AI自定义设备名使能
  late bool _aiCustomNameEnable;

  /// AI唯一唤醒使能
  late bool _aiOnlyOneWakeup;


  /// 屏幕亮度
  late int _screenBrightness;

  /// 音量
  late int _volume;

  /// 显示音量
  late int _showVolume;

  /// 工程模式使能
  late bool _engineeringModeEnable;

  /// 屏幕自动亮度使能
  late bool _screenAutoEnable;

  /// 靠近唤醒使能
  late bool _nearWakeupEnable;

  /// 默认音量 0～15
  final int _defaultVolume = 12;
  /// 默认亮度 0～255
  final int _defaultBrightness = 255;

  /// 是否允许登录页切换平台
  late bool _isAllowChangePlatform;

  /// 最后绑定的家庭名称
  late String _lastBindHomeName;
  /// 最后绑定的家庭Id
  late String _lastBindHomeId;
  /// 最后绑定的房间名称
  late String _lastBindRoomName;
  /// 最后绑定的房间id
  late String _lastBindRoomId;

  void init() async {
    _prefs = await SharedPreferences.getInstance();

    int? screedStartTime = _prefs.getInt("setting_screed_start_time") ?? (23 * 60);//23:00
    int? screedEndTime = _prefs.getInt("setting_screed_end_time") ?? (31 * 60);//第二天07:00

    _screedDuration = Pair.of(screedStartTime, screedEndTime);
    _nightModeEnable = _prefs.getBool('setting_night_mode_enable') ?? false;

    standbyTimeOptNum = _prefs.getInt(_standbyTimeKey) ?? 3; /// 默认选序号3的选项（从0开始）
    _screenSaverId = _prefs.getInt('setting_screen_saver_id') ?? 6; /// 默认的屏保样式为6

    _aiEnable = _prefs.getBool('setting_ai_enable') ?? true;
    _homluxAiEnable= _prefs.getBool('setting_homlux_ai_enable') ?? true;
    _aiCustomNameEnable = _prefs.getBool('setting_ai_custom_name_enable') ?? false;
    _aiOnlyOneWakeup = _prefs.getBool('setting_ai_only_one_wakeup') ?? false;

    _screenBrightness = _prefs.getInt('setting_screen_brightness') ?? _defaultBrightness;
    _volume = _prefs.getInt('setting_system_volume') ?? _defaultVolume;
    _showVolume= _prefs.getInt('setting_system_show_volume') ?? (_volume / 15 * 100).toInt();
    _engineeringModeEnable = _prefs.getBool('setting_engineering_mode') ?? false;
    _screenAutoEnable = _prefs.getBool('setting_screen_auto') ?? false;
    _nearWakeupEnable = _prefs.getBool('setting_near_wakeup') ?? false;
    _screenSaverReplaceToOff = _prefs.getBool('setting_screen_replace_off') ?? false;

    _lastBindHomeName = _prefs.getString("last_bind_home_name") ?? "";
    _lastBindHomeId = _prefs.getString("last_bind_home_id") ?? "";
    _lastBindRoomId = _prefs.getString("last_bind_room_id") ?? "";
    _lastBindRoomName = _prefs.getString("last_bind_room_name") ?? "";

    _isAllowChangePlatform = _prefs.getBool('allow_change_platform') ?? true;

    initDeviceDefaultConfig();
  }

  /// 设置设备默认音量和亮度
  void initDeviceDefaultConfig() {
    bool isSetBefore = _prefs.getBool('setting_volume_brightness_before') ?? false;
    if(!isSetBefore) {
      settingMethodChannel.setSystemVoice(_defaultVolume);
      settingMethodChannel.setSystemLight(_defaultBrightness);

      _volume = _defaultVolume;
      _prefs.setInt('setting_system_volume', _defaultVolume);

      _screenBrightness = _defaultBrightness;
      _prefs.setInt('setting_screen_brightness', _defaultBrightness);

      _prefs.setBool('setting_volume_brightness_before', true);
    }
  }

  /// 标识当前版本已经处理版本升级兼容
  bool checkVersionCompatibility(String version) {
     return _prefs.getBool(version) ?? false;
  }
  
  /// 设置当前版本已经兼容
  void saveVersionCompatibility(String version, [value = true]) {
    _prefs.setBool(version, value);
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
    if(duration.value2 >= 0 && duration.value1 >= 0 && duration.value1 >= duration.value2) {
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
    // if(result.value1 == -1 || result.value2 == -1 || result.value1 >= result.value2 ) {
    //   return '暂未设置';
    // }
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
    var end = duration.value2;
    if (end > 1440) {
      end = end - 1440;
    }
    debugPrint('start = $start end = $end index = $index');
    if (start < end) {
      return index >= start && index < end;
    } else if (start > end) {
      if (index >= start && index <= 1440) {
        return true;
      } else if (index >= 0 && index <= end) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 获取AI使能
  bool get aiEnable => _aiEnable;

  /// 设置AI使能
  set aiEnable(bool enable) {
    _prefs.setBool('setting_ai_enable', enable);
    _aiEnable = enable;
  }

  /// 获取AI使能
  bool get homluxAiEnable => _homluxAiEnable;

  /// 设置AI使能
  set homluxAiEnable(bool enable) {
    _prefs.setBool('setting_homlux_ai_enable', enable);
    _homluxAiEnable = enable;
  }

  /// 获取AI自定义设备名使能
  bool get aiCustomNameEnable => _aiCustomNameEnable;

  /// 设置AI自定义设备名使能
  set aiCustomNameEnable(bool enable) {
    _prefs.setBool('setting_ai_custom_name_enable', enable);
    _aiCustomNameEnable = enable;
  }

  /// 获取AI唯一唤醒使能
  bool get aiOnlyOneWakeup => _aiOnlyOneWakeup;

  /// 设置AI唯一唤醒使能
  set aiOnlyOneWakeup(bool enable) {
    _prefs.setBool('setting_ai_only_one_wakeup', enable);
    _aiOnlyOneWakeup = enable;
  }



  /// 获取屏幕亮度
  int get screenBrightness => _screenBrightness;

  /// 设置屏幕亮度
  set screenBrightness(int val) {
    _prefs.setInt('setting_screen_brightness', val);
    _screenBrightness = val;
  }

  /// 获取系统音量
  int get volume => _volume;

  /// 设置系统音量
  set volume(int val) {
    _prefs.setInt('setting_system_volume', val);
    _volume = val;
  }

  /// 获取系统显示音量
  int get showVolume => _showVolume;

  /// 设置系统显示音量
  set showVolume(int val) {
    _prefs.setInt('setting_system_volume', val);
    _showVolume = val;
  }

  /// 获取工程模式
  bool get engineeringModeEnable => _engineeringModeEnable;

  /// 设置工程模式
  set engineeringModeEnable(bool enable) {
    _prefs.setBool('setting_engineering_mode', enable);
    _engineeringModeEnable = enable;
  }

  /// 获取屏幕自动亮度使能
  bool get screenAutoEnable => _screenAutoEnable;

  /// 设置屏幕自动亮度使能
  set screenAutoEnable(bool val) {
    _prefs.setBool('setting_screen_auto', val);
    _screenAutoEnable = val;
  }

  /// 获取靠近唤醒使能
  bool get nearWakeupEnable => _nearWakeupEnable;

  /// 设置靠近唤醒使能
  set nearWakeupEnable(bool val) {
    _prefs.setBool('setting_near_wakeup', val);
    _nearWakeupEnable = val;
  }

  /// 获取夜间模式使能
  bool get nightModeEnable => _nightModeEnable;

  /// 设置夜间模式使能
  set nightModeEnable(bool val) {
    _prefs.setBool('setting_night_mode_enable', val);
    _nightModeEnable = val;
  }

  /// 获取是否屏保直接熄屏
  bool get screenSaverReplaceToOff => _screenSaverReplaceToOff;

  /// 设置是否屏保直接熄屏
  set screenSaverReplaceToOff(bool val) {
    _prefs.setBool('setting_screen_replace_off', val);
    _screenSaverReplaceToOff = val;
  }

  /// 获取最后绑定家庭名称
  String get lastBindHomeName => _lastBindHomeName;

  /// 设置最后绑定家庭名称
  set lastBindHomeName(String val) {
    _prefs.setString('last_bind_home_name', val);
    _lastBindHomeName = val;
  }

  /// 获取最后绑定家庭id
  String get lastBindHomeId => _lastBindHomeId;

  /// 设置最后绑定家庭id
  set lastBindHomeId(String val) {
    _prefs.setString('last_bind_home_id', val);
    _lastBindHomeId = val;
  }

  /// 获取最后绑定的房间id
  String get lastBindRoomId => _lastBindRoomId;
  /// 设置最后绑定的房间id
  set lastBindRoomId(String val) {
    _prefs.setString('last_bind_room_id', val);
    _lastBindRoomId = val;
  }
  /// 获取最后绑定的房间名称
  String get lastBindRoomName => _lastBindRoomName;
  /// 设置最后绑定的房间名称
  set lastBindRoomName(String val) {
    _prefs.setString('last_bind_room_name', val);
    _lastBindRoomName = val;
  }
  /// 获取是否允许登录页切换平台
  bool get isAllowChangePlatform => _isAllowChangePlatform;

  /// 设置是否允许登录页切换平台
  set isAllowChangePlatform(bool val) {
    _prefs.setBool('allow_change_platform', val);
    _isAllowChangePlatform = val;
  }

}