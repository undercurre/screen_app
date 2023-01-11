import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/device/service.dart';

import '../../states/device_change_notifier.dart';

class CenterControlService {
  /// 窗帘
  static bool isCurtainPower(BuildContext context) {
    var totalPower = false;
    var curtainList = context.read<DeviceListModel>().curtainList;
    for (var i = 1; i <= curtainList.length; i++) {
      var deviceInfo = curtainList[i - 1];
      debugPrint('中控${deviceInfo.name}${DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)}');
      if (DeviceService.isPower(deviceInfo) && DeviceService.isOnline(deviceInfo)) {
        totalPower = true;
      }
    }
    debugPrint('窗帘中控结果$totalPower');
    return totalPower;
  }

  static Future<void> curtainControl(BuildContext context, bool onOff) async {
    var curtainList = context.read<DeviceListModel>().curtainList;
    for (var i = 1; i <= curtainList.length; i++) {
      var deviceInfo = curtainList[i - 1];
      var res = await DeviceService.setPower(deviceInfo, onOff);
      if (res) {
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
      }
    }
  }
// /// 灯光
// static bool isLightPower() {
//
// }
// /// 空调
// static bool isAirConditionPower() {
//
// }
// /// 场景
// static bool isScenePower() {
//
// }
}
