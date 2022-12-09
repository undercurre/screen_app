import 'package:flutter/foundation.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';
import '../routes/device/register_controller.dart';

class DeviceListModel extends ProfileChangeNotifier {
  List<DeviceEntity> _deviceListResource = Global.profile.roomInfo!.applianceList;

  List<DeviceEntity> get deviceList => _deviceListResource;

  set deviceList(List<DeviceEntity> newList) {
    _deviceListResource = newList;
    logger.i("DeviceListModelChange: $deviceList");
    notifyListeners();
  }

  Map<String, dynamic> getDeviceDetail(DeviceEntity deviceInfo) {
    var curDevice = _deviceListResource.where((element) => element.applianceCode == deviceInfo.applianceCode).toList();
    if (curDevice.isNotEmpty) {
      return curDevice[0].detail ?? {};
    } else {
      return {};
    }
  }
}
