import 'package:flutter/material.dart';
import 'room/index.dart';
import 'boot/index.dart';
import 'setting/about_setting.dart';
import 'setting/ai_setting.dart';
import 'setting/display_setting.dart';
import 'setting/index.dart';
import 'setting/net_setting.dart';
import 'setting/sound_setting.dart';
import 'setting/standby_time_choice.dart';

import 'login/index.dart';
import 'home/index.dart';
import 'weather/index.dart';
import 'device/index.dart';
import 'scene/index.dart';
import 'sniffer/index.dart';
import 'sniffer/device_connect.dart';
import 'sniffer/self_discovery.dart';

import 'plugins/0x13/index.dart';
import 'plugins/0x14/index.dart';
import 'plugins/0x26/index.dart';
import 'plugins/0x40/index.dart';
import 'plugins/0x21/0x21_light/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const Boot(),
  "Login": (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "Room": (context) => const RoomPage(),
  "Weather": (context) => const WeatherPage(),
  "Device": (context) => const DevicePage(text: ''),
  "Scene": (context) => const ScenePage(text: ''),
  // "CenterControl": (context) => const CenterControl(text: ''),
  "SnifferPage": (context) => const SnifferPage(),
  "DeviceConnectPage": (context) => const DeviceConnectPage(),
  "SelfDiscoveryPage": (context) => const SelfDiscoveryPage(),

  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),
  "StandbyTimeChoicePage": (context) => const StandbyTimeChoicePage(),

  "0x13": (context) => const WifiLightPage(),
  "0x14": (context) => const CurtainPage(),
  "0x26": (context) => const BathroomMaster(),
  "0x40": (context) => const CoolMaster(),
  "0x21_light": (context) => const ZigbeeLightPage(),
};
