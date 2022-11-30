import 'package:flutter/foundation.dart';
import 'package:screen_app/models/device_home_list_entity.dart';

import '../models/index.dart';

class DeviceListChangeNotifier extends ChangeNotifier {
  List<DeviceHomeListHomeListRoomListApplianceList> _deviceList = [];

  DeviceListChangeNotifier(this._deviceList);

  List<DeviceHomeListHomeListRoomListApplianceList> get deviceList => _deviceList;

  void getList(List<DeviceHomeListHomeListRoomListApplianceList> newList) {
    _deviceList = newList;
    notifyListeners();
  }
}