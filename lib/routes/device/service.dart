import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/device/config.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../common/global.dart';
import '../../models/device_home_list_entity.dart';

class DeviceService {
  static bool supportDeviceFilter(DeviceEntity? deviceInfo) {
    return supportDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList().isEmpty;
  }

  static DeviceOnList configFinder(DeviceEntity? deviceInfo) {
    var finderList = deviceConfig.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList();
    return finderList.isEmpty ? deviceConfig.where((element) => element.type == '0x13').toList()[0] : finderList[0];
  }

  static bool hasStatus(DeviceEntity? deviceInfo) {
    return statusDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0x13')).toList().isNotEmpty;
  }

  static Future<Map<String, dynamic>> getDeviceDetail(String? apiCode, String deviceId) async {
    if (apiCode == null) return {};
    var servicer = serviceList[apiCode]!;
    var res = await servicer.getDeviceDetail(deviceId);
    return res;
  }

  static Future<bool> setPower(String? apiCode, String? deviceId, bool onOff) async {
    if (apiCode == null && deviceId == null) {
      return false;
    } else {
      var servicer = serviceList[apiCode]!;
      var res = await servicer.setPower(deviceId!, onOff);
      return res.code == 0;
    }
  }

  static bool isPower(DeviceEntity? deviceInfo){
    if (deviceInfo != null) {
      var config = configFinder(deviceInfo);
      var curDevice = Global.profile.roomInfo!.applianceList.where((element) =>
      element.applianceCode == deviceInfo.applianceCode)
          .toList()[0];
      return curDevice.detail[config.powerKey] == config.powerValue;
    } else {
      return false;
    }
  }

  static num getAttr(DeviceEntity? deviceInfo){
    if (deviceInfo != null) {
      var config = configFinder(deviceInfo);
      var curDevice = Global.profile.roomInfo!.applianceList.where((element) =>
      element.applianceCode == deviceInfo.applianceCode)
          .toList()[0];
      late num attr;
      if (config.attrFormat != null) {
        attr = config.attrFormat!(curDevice.detail[config.attrName]);
      } else {
        attr = curDevice.detail[config.attrName];
      }
      return attr;
    } else {
      return 0;
    }
  }
}