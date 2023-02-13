import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x17/index.dart';
import 'package:screen_app/routes/setting/screen_saver/index.dart';
import 'package:screen_app/routes/setting/select_time_duration.dart';
import 'package:screen_app/routes/setting/standby_style_select.dart';

import 'boot/index.dart';
import 'develop/develop_helper.dart';
import 'dropdown/drop_down_page.dart';
import 'home/index.dart';
import 'login/index.dart';
import 'plugins/0x13/index.dart';
import 'plugins/0x14/index.dart';
import 'plugins/0x21/0x21_curtain/index.dart';
import 'plugins/0x21/0x21_light/index.dart';
import 'plugins/0x26/index.dart';
import 'plugins/0x40/index.dart';
import 'plugins/0xAC/index.dart';
import 'plugins/lightGroup/index.dart';
import 'select_room/index.dart';
import 'select_scene/index.dart';
import 'setting/index.dart';
import 'sniffer/device_connect.dart';
import 'sniffer/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const Boot(),
  "Login": (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "SelectRoomPage": (context) => const SelectRoomPage(),
  "SelectScenePage": (context) => const SelectScenePage(),
  "ScreenSaver": (context) => const ScreenSaver(),
  "SnifferPage": (context) => const SnifferPage(),
  "DeviceConnectPage": (context) => const DeviceConnectPage(),


  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),
  "StandbyTimeChoicePage": (context) => const StandbyTimeChoicePage(),
  "developer": (context) => const DeveloperHelperPage(),
  "DropDownPage": (context) => const DropDownPage(),
  "SelectTimeDurationPage": (context) => const SelectTimeDurationPage(),
  "SelectStandbyStylePage": (contest) => const SelectStandbyStylePage(),


  "0x13": (context) => const WifiLightPage(),
  "0x14": (context) => const WifiCurtainPage(),
  "0x17": (context) => const WifiLiangyiPage(),
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
