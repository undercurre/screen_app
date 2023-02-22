import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';

import '../../../states/device_change_notifier.dart';

class DeviceService {
  static bool isOnline(DeviceEntity deviceInfo) {
    return deviceInfo.onlineStatus == '1' && isSupport(deviceInfo);
  }

  static Future<Map<String, dynamic>> getDeviceDetail(
      DeviceEntity deviceInfo) async {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = await controller.getDeviceDetail(deviceInfo);
      return res;
    } else {
      return {};
    }
  }

  static Future<bool> setPower(DeviceEntity deviceInfo, bool onOff) async {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = await controller.setPower(deviceInfo, onOff);
      return res.code == 0;
    } else {
      return false;
    }
  }

  static bool isSupport(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.isSupport(deviceInfo);
      return res;
    } else {
      return false;
    }
  }

  static bool isPower(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.isPower(deviceInfo);
      return res;
    } else {
      return false;
    }
  }

  static String getAttr(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.getAttr(deviceInfo);
      return res;
    } else {
      return '';
    }
  }

  static String getAttrUnit(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.getAttrUnit(deviceInfo);
      return res;
    } else {
      return '';
    }
  }

  static String getOnIcon(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.getOnIcon(deviceInfo);
      return res;
    } else {
      return 'assets/imgs/device/phone_on.png';
    }
  }

  static String getOffIcon(DeviceEntity deviceInfo) {
    var controller = getController(deviceInfo);
    if (controller != null) {
      var res = controller.getOffIcon(deviceInfo);
      return res;
    } else {
      return 'assets/imgs/device/phone_off.png';
    }
  }

  static bool isVistual(DeviceEntity deviceInfo) {
    // 智慧屏线控器
    if (deviceInfo.type == '0x16' && (deviceInfo.sn8 == "MSGWZ010" || deviceInfo.sn8 == "MSGWZ013")) {
      return true;
    }
    // 面板
    if (deviceInfo.type == '0x21' &&
        zigbeeControllerList[deviceInfo.modelNumber] == '0x21_panel') {
      return true;
    }
    return false;
  }
}