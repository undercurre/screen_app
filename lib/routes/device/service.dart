import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/device/config.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../common/global.dart';
import '../../models/device_home_list_entity.dart';

class DeviceService {
  static bool isOnline(DeviceEntity? deviceInfo) {
    return deviceInfo != null ? (deviceInfo!.onlineStatus == '1') : false;
  }

  static bool supportDeviceFilter(DeviceEntity? deviceInfo) {
    if (deviceInfo != null) {
      bool hasType = supportDeviceList
          .where((element) => element.type == deviceInfo.type)
          .toList()
          .isEmpty;
      if (hasType && deviceInfo!.type != '0x21') {
        bool hasSn8s = false;
        supportDeviceList
            .where((element) => element.type == deviceInfo.type)
            .toList().forEach((element) {
          if (element.sn8s!.any((element) => element == deviceInfo.sn8)) hasSn8s = true;
        });
        return hasType && hasSn8s;
      } else {
        bool hasModelNum = false;
        supportDeviceList
            .where((element) => element.type == deviceInfo.type)
            .toList().forEach((element) {
              if (element.modelNum!.any((element) => element == deviceInfo.modelNumber)) hasModelNum = true;
        });
        debugPrint('hasModel$hasModelNum');
        return hasType && hasModelNum;
      }
    } else {
      return false;
    }
  }

  static DeviceOnList configFinder(DeviceEntity? deviceInfo) {
    var finderList = deviceConfig.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0xxx')).toList();
    return finderList.isEmpty ? something : finderList[0];
  }

  static bool hasStatus(DeviceEntity? deviceInfo) {
    return statusDeviceList.where((element) => element.type == (deviceInfo != null ? deviceInfo.type : '0xxx')).toList().isNotEmpty && isOnline(deviceInfo);
  }

  static Future<Map<String, dynamic>> getDeviceDetail(String? apiCode, DeviceEntity deviceInfo) async {
    if (apiCode == null) return {};
    var servicer = serviceList[apiCode]!;
    var res = await servicer.getDeviceDetail(deviceInfo);
    return res;
  }

  static Future<bool> setPower(String? apiCode, DeviceEntity? deviceInfo, bool onOff) async {
    if (apiCode == null && deviceInfo == null) {
      return false;
    } else {
      var servicer = serviceList[apiCode]!;
      var res = await servicer.setPower(deviceInfo!, onOff);
      return res.code == 0;
    }
  }

  static bool isPower(DeviceEntity? deviceInfo){
    if (deviceInfo != null) {
      var config = configFinder(deviceInfo);
      var curDevice = Global.profile.roomInfo!.applianceList.where((element) =>
      element.applianceCode == deviceInfo.applianceCode)
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

  static num getAttr(DeviceEntity? deviceInfo){
    if (deviceInfo != null) {
      var config = configFinder(deviceInfo);
      var curDevice = Global.profile.roomInfo!.applianceList.where((element) =>
      element.applianceCode == deviceInfo.applianceCode)
          .toList()[0];
      late num attr;
      if(curDevice.detail != null && curDevice.detail!.keys.toList().isNotEmpty) {
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