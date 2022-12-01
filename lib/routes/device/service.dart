import 'package:screen_app/routes/device/config.dart';

import '../../models/device_home_list_entity.dart';

class DeviceService {
  bool supportDeviceFilter(DeviceHomeListHomeListRoomListApplianceList? deviceInfo) {
    return supportDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList().isEmpty;
  }

  DeviceOnList configFinder(DeviceHomeListHomeListRoomListApplianceList? deviceInfo) {
    var finderList = deviceConfig.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList();
    return finderList.isEmpty ? deviceConfig.where((element) => element.type == '0x13').toList()[0] : finderList[0];
  }
}