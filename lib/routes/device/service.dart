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
      if (!hasType) {
        if (deviceInfo!.type != '0x21') {
          bool hasSn8s = false;
          supportDeviceList
              .where((element) => element.type == deviceInfo.type)
              .toList()
              .forEach((element) {
            if (element.sn8s!.any((element) => element == deviceInfo.sn8)) {
              hasSn8s = true;
            }
          });
          return hasSn8s;
        } else {
          bool hasModelNum = false;
          supportDeviceList
              .where((element) => element.type == deviceInfo.type)
              .toList()
              .forEach((element) {
            if (element.sn8s != null && element.modelNum!
                .any((element) => element == deviceInfo.modelNumber)) {
              hasModelNum = true;
            }
          });
          debugPrint('hasModel${deviceInfo.toJson()}');
          return hasModelNum;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static DeviceOnList configFinder(DeviceEntity? deviceInfo) {
    late List<DeviceOnList> finderList;
    if (deviceInfo != null) {
      if (deviceInfo.type != '0x21') {
        var f = deviceConfig
            .where((element) => element.type == deviceInfo.type)
            .toList();
        debugPrint('寻找sn8:${deviceInfo.sn8}');
        late List<DeviceOnList> f8 = [];
        for (var element in f) {
          if (element.sn8s != null &&
              element.sn8s!.any((element) => element == deviceInfo.sn8)) {
            f8.add(element);
          }
        }
        if (f.isNotEmpty && f[0].sn8s == null && f8.isEmpty) {
          return f[0];
        } else if (f.isNotEmpty && f8.isNotEmpty) {
          return f8[0];
        } else {
          debugPrint('配置寻找器有毛病或者暂时没有这个品类的配置');
          return something;
        }
      } else {
        finderList = deviceConfig
            .where((element) =>
                element.type == deviceInfo.type &&
                element.modelNum!
                    .any((element) => element == deviceInfo.modelNumber))
            .toList();
      }
      return finderList.isNotEmpty ? finderList[0] : something;
    } else {
      return something;
    }
  }

  static bool hasStatus(DeviceEntity? deviceInfo) {
    return statusDeviceList
            .where((element) =>
                element.type == (deviceInfo != null ? deviceInfo.type : '0xxx'))
            .toList()
            .isNotEmpty &&
        isOnline(deviceInfo) &&
        supportDeviceFilter(deviceInfo);
  }

  static Future<Map<String, dynamic>> getDeviceDetail(
      String? apiCode, DeviceEntity deviceInfo) async {
    if (apiCode == null) return {};
    var servicer = serviceList[apiCode]!;
    var res = await servicer.getDeviceDetail(deviceInfo);
    return res;
  }

  static Future<bool> setPower(
      String? apiCode, DeviceEntity? deviceInfo, bool onOff) async {
    if (apiCode == null && deviceInfo == null) {
      return false;
    } else {
      var servicer = serviceList[apiCode]!;
      var res = await servicer.setPower(deviceInfo!, onOff);
      return res.code == 0;
    }
  }
}
