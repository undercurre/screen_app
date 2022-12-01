import 'package:screen_app/routes/device/config.dart';

import '../../models/device_home_list_entity.dart';

class DeviceService {
  static bool supportDeviceFilter(DeviceHomeListHomeListRoomListApplianceList? deviceInfo) {
    return supportDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList().isEmpty;
  }

  static DeviceOnList configFinder(DeviceHomeListHomeListRoomListApplianceList? deviceInfo) {
    var finderList = deviceConfig.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList();
    return finderList.isEmpty ? deviceConfig.where((element) => element.type == '0x13').toList()[0] : finderList[0];
  }

  static bool hasStatus(DeviceHomeListHomeListRoomListApplianceList? deviceInfo) {
    return statusDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList().isNotEmpty;
  }

  static void getDeviceDetail(String deviceId) {

  }

  static Future<bool> setPower(String? apiCode, String? deviceId, bool onOff) async {
    if (apiCode == null && deviceId == null) {
      return false;
    } else {
      var servicer = serviceList[apiCode]!;
      var res = await servicer.setPower(deviceId!, onOff);
      return true;
    }
  }

  static bool isPower(){
    return false;
  }

  static num getAttr(){
    return 30;
  }
}