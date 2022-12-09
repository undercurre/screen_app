import 'package:flutter/foundation.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';
import '../routes/device/config.dart';

class DeviceListModel extends ProfileChangeNotifier {
  List<DeviceEntity> _deviceListResource = Global.profile.roomInfo!.applianceList;

  List<DeviceEntity> get deviceList => _deviceListResource;

  set deviceList(List<DeviceEntity> newList) {
    _deviceListResource = newList;
    logger.i("DeviceListModelChange: $deviceList");
    notifyListeners();
  }

  bool isPower(DeviceEntity? deviceInfo) {
    if (deviceInfo != null) {
      var config = DeviceService.configFinder(deviceInfo);
      var curDevice = _deviceListResource
          .where((element) => element.applianceCode == deviceInfo.applianceCode)
          .toList()[0];
      if (curDevice.detail != null) {
        return curDevice.detail![config.powerKey] == config.powerValue;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  num getAttr(DeviceEntity? deviceInfo) {
    if (deviceInfo != null) {
      var config = DeviceService.configFinder(deviceInfo);
      var curDevice = _deviceListResource
          .where((element) => element.applianceCode == deviceInfo.applianceCode)
          .toList()[0];
      late num attr;
      if (curDevice.detail != null &&
          curDevice.detail!
              .keys
              .toList()
              .isNotEmpty) {
        if (config.attrFormat != null) {
          attr = config.attrFormat!(curDevice.detail![config.attrName]);
        } else {
          attr = curDevice.detail![config.attrName];
        }
        return attr;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

}
