import 'package:flutter/material.dart';

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
  "Device": (context) => const DevicePage(),
  "Scene": (context) => const ScenePage(),
  "0x13": (context) => const WifiLightPage(),
};