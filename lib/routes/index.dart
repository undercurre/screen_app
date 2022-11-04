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

var routes = <String, WidgetBuilder>{
  '/': (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "Weather": (context) => const WeatherPage(),
  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),

};