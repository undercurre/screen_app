import 'package:flutter/foundation.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';

class DeviceListModel extends ProfileChangeNotifier {

  List<DeviceEntity> get deviceList => Global.profile.roomInfo!.applianceList;

  set deviceList(List<DeviceEntity> newList) {
    Global.profile.roomInfo!.applianceList = newList;
    logger.i("DeviceListModelChange: $deviceList");
    notifyListeners();
  }
}