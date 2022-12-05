import 'package:flutter/foundation.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_home_list_entity.dart';

import '../models/index.dart';

class DeviceListChangeNotifier extends ChangeNotifier {

  List<DeviceEntity> get deviceList => Global.profile.roomInfo!.applianceList;

  set deviceList(List<DeviceEntity> newList) {
    deviceList = newList;
    notifyListeners();
  }
}