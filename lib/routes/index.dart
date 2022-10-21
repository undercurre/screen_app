import 'package:flutter/material.dart';

import 'login/index.dart';
import 'home/index.dart';

var routes = <String, WidgetBuilder>{
  '/': (context) => const LoginPage(),
  "Home": (context) => const Home(),
};