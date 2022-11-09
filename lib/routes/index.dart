import 'package:flutter/material.dart';
import 'package:screen_app/routes/setting/about_setting.dart';
import 'package:screen_app/routes/setting/ai_setting.dart';
import 'package:screen_app/routes/setting/display_setting.dart';
import 'package:screen_app/routes/setting/index.dart';
import 'package:screen_app/routes/setting/net_setting.dart';
import 'package:screen_app/routes/setting/sound_setting.dart';

import 'login/index.dart';
import 'home/index.dart';
import 'weather/index.dart';
import 'device/index.dart';
import 'scene/index.dart';
import 'plugins/0x13/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "Weather": (context) => const WeatherPage(),
  "Device": (context) => const DevicePage(text: '',),
  "Scene": (context) => const ScenePage(text: '',),
  "0x13": (context) => const WifiLightPage(),
  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),

};