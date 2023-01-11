import 'package:flutter/material.dart';
import 'dropdown/drop_down_page.dart';
import 'package:screen_app/routes/center_control/index.dart';
import 'package:screen_app/routes/develop/wifi_manager.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_curtain/index.dart';
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/routes/plugins/0xAC/index.dart';
import 'package:screen_app/routes/plugins/lightGroup/index.dart';
import 'develop/develop_helper.dart';
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
  "CenterControl": (context) => const CenterControlPage(text: ''),
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
  "developer": (context) => const DeveloperHelperPage(),
  "DropDownPage": (context) => const DropDownPage(),


  "0x13": (context) => const WifiLightPage(),
  "0x14": (context) => const CurtainPage(),
  "0x26": (context) => const BathroomMaster(),
  "0x40": (context) => const CoolMaster(),
  "0x21_light_colorful": (context) => const ZigbeeLightPage(),
  "0x21_light_noColor": (context) => const ZigbeeLightPage(),
  "0x21_curtain": (context) => const ZigbeeCurtainPage(),
  "0x21_curtain_panel_one": (context) => const ZigbeeCurtainPage(),
  "0x21_curtain_panel_two": (context) => const ZigbeeCurtainPage(),
  "lightGroup": (context) => const LightGroupPage(),
  "0xAC": (context) => const AirConditionPage()
};
