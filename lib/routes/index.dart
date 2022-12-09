import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x21_light/index.dart';
import 'package:screen_app/routes/room/index.dart';
import 'boot/index.dart';
import 'package:screen_app/routes/plugins/0x40/index.dart';
import 'package:screen_app/routes/setting/about_setting.dart';
import 'package:screen_app/routes/setting/ai_setting.dart';
import 'package:screen_app/routes/setting/display_setting.dart';
import 'package:screen_app/routes/setting/index.dart';
import 'package:screen_app/routes/setting/net_setting.dart';
import 'package:screen_app/routes/setting/sound_setting.dart';
import 'package:screen_app/routes/setting/standby_time_choice.dart';


import 'login/index.dart';
import 'home/index.dart';
import 'weather/index.dart';
import 'device/index.dart';
import 'scene/index.dart';
import 'sniffer/index.dart';
import 'sniffer/device_connect.dart';
import 'plugins/0x13/index.dart';
import 'plugins/0x14/index.dart';
import 'plugins/0x26/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const Boot(),
  "Login": (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "Room": (context) => const RoomPage(),
  "Weather": (context) => const WeatherPage(),
  "Device": (context) => const DevicePage(
        text: '',
      ),
  "Scene": (context) => const ScenePage(
        text: '',
      ),
  "0x13": (context) => const WifiLightPage(),
  "0x14": (context) => const CurtainPage(),
  "0x26": (context) => const BathroomMaster(),
  "0x40": (context) => const CoolMaster(),
  "0x21_light": (context) => const ZigbeeLightPage(),
  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),
  "StandbyTimeChoicePage": (context) => const StandbyTimeChoicePage(),
  "SnifferPage": (context) => const SnifferPage(),
  "DeviceConnectPage": (context) => const DeviceConnectPage(),
};
