import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/device/custom.dart';
import 'package:screen_app/routes/plugins/0x13_fan/index.dart';
import 'package:screen_app/routes/plugins/0x17/index.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_485_air/index.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_485_cac/index.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_485_floor/index.dart';
import 'package:screen_app/routes/plugins/0xAC_floorHeating/index.dart';
import 'package:screen_app/routes/plugins/0xAC_newWind/index.dart';
import 'package:screen_app/routes/plugins/0xB6/index.dart';
import 'package:screen_app/routes/plugins/0xE2/index.dart';
import 'package:screen_app/routes/plugins/0xE3/index.dart';
import 'package:screen_app/routes/setting/account_setting.dart';
import 'package:screen_app/routes/setting/engineering_mode.dart';
import 'package:screen_app/routes/setting/homlux_ai_setting.dart';
import 'package:screen_app/routes/setting/migrate_old_version_homlux_data_page.dart';
import 'package:screen_app/routes/setting/migrate_old_version_meiju_data_page.dart';
import 'package:screen_app/routes/setting/night_mode.dart';
import 'package:screen_app/routes/setting/screen_saver/index.dart';
import 'package:screen_app/routes/setting/select_time_duration.dart';
import 'package:screen_app/routes/setting/standby_style_select.dart';
import 'package:screen_app/routes/setting/standyby_setting.dart';
import 'package:screen_app/widgets/business/area_selector.dart';

import 'boot/index.dart';
import 'develop/develop_helper.dart';
import 'dropdown/drop_down_page.dart';
import 'home/device/add_device.dart';
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
import 'setting/index.dart';
import 'sniffer/device_connect.dart';
import 'sniffer/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const Boot(),
  "Login": (context) => const LoginPage(),
  "Home": (context) => const Home(),
  "Custom": (context) => CustomPage(),
  "AddDevice": (context) => const AddDevicePage(),
  "SelectRoomPage": (context) => const SelectRoomPage(),
  "SelectAreaPage": (context) => const AreaSelector(),
  "ScreenSaver": (context) => const ScreenSaver(),
  "SpecialBlackBgSaverScreen": (context) => const SpecialBlackBgSaverScreen(),
  "SnifferPage": (context) => const SnifferPage(),
  "DeviceConnectPage": (context) => const DeviceConnectPage(),


  "SettingPage": (context) => const SettingPage(),
  "SoundSettingPage": (context) => const SoundSettingPage(),
  "AiSettingPage": (context) => const AiSettingPage(),
  "HomluxAiSettingPage": (context) => const HomluxAiSettingPage(),
  "DisplaySettingPage": (context) => const DisplaySettingPage(),
  "NetSettingPage": (context) => const NetSettingPage(),
  "AboutSettingPage": (context) => const AboutSettingPage(),
  "StandbyTimeChoicePage": (context) => const StandbyTimeChoicePage(),
  "developer": (context) => const DeveloperHelperPage(),
  "DropDownPage": (context) => const DropDownPage(),
  "SelectTimeDurationPage": (context) => const SelectTimeDurationPage(),
  "SelectStandbyStylePage": (contest) => const SelectStandbyStylePage(),
  "MigrationOldVersionMeiJuDataPage": (contest) => const MigrationOldVersionMeiJuDataPage(),
  "MigrationOldVersionHomLuxDataPage": (contest) => const MigrationOldVersionHomLuxDataPage(),
  "AccountSettingPage": (contest) => const AccountSettingPage(),
  "AdvancedSettingPage": (contest) => const AdvancedSettingPage(),
  "CurrentPlatformPage": (contest) => const CurrentPlatformPage(),
  "EngineeringModePage": (contest) => const EngineeringModePage(),
  "NightModePage": (contest) => const NightModePage(),
  "StandbySettingPage": (contest) => const StandbySettingPage(),


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
  "0x21_485CAC": (context) => const AirCondition485Page(),
  "0x21_485Air": (context) => const FreshAir485Page(),
  "0x21_485Floor": (context) => const FloorHeating485Page(),
  "0xE2": (context) => const ElectricWaterHeaterPage(),
  "0xE3": (context) => const GasWaterHeaterPage(),
  "0xAC": (context) => const AirConditionPage(),
  "0xAC_newWind": (context) => const NewWindPage(),
  "0xAC_floorHeating": (context) => const FloorHeatingPage(),
  "0x13_fun": (context) => const WifiLightFanPage()

};
