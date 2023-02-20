
import 'package:flutter/cupertino.dart';
import '../common/global.dart';

class GlobalRouteObserverNotifier with ChangeNotifier {
  final GlobalRouteObserver<PageRoute> _globalRouteObserver = globalRouteObserver;
  get routeObserver => _globalRouteObserver;
}