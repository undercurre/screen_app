import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/plugins/0x16/api.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';
import '../routes/device/service.dart';

class DeviceListModel extends ProfileChangeNotifier {
  List<DeviceEntity> _deviceListResource =
      Global.profile.roomInfo!.applianceList;

  List<DeviceEntity> get deviceList => _deviceListResource;

  set deviceList(List<DeviceEntity> newList) {
    _deviceListResource = newList;
    logger.i("DeviceListModelChange: $deviceList");
    notifyListeners();
  }

  Map<String, dynamic> getDeviceDetail(String deviceId) {
    var curDeviceList = _deviceListResource
        .where((element) => element.applianceCode == deviceId)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      return {
        "deviceId": deviceId,
        "deviceName": curDevice.name,
        "detail": curDevice.detail ?? {}
      };
    } else {
      return {};
    }
  }

  Future<void> updateDeviceDetail(DeviceEntity deviceInfo,
      {Function? callback}) async {
    // todo: 优化数据更新diff
    var curDeviceList = _deviceListResource
        .where((element) => element.applianceCode == deviceInfo.applianceCode)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      var newDetail = await DeviceService.getDeviceDetail(deviceInfo);
      curDevice.detail = newDetail;
      logger.i(
          "DeviceListModelChange: ${_deviceListResource.where((element) => element.applianceCode == deviceInfo.applianceCode).toList()[0].detail}");
      notifyListeners();
      if (callback != null) callback();
    }
  }

  void setProviderDeviceInfo(DeviceEntity device, {Function? callback}) {
    final index = _deviceListResource
        .indexWhere((element) => element.applianceCode == device.applianceCode);
    _deviceListResource[index] = device;
    notifyListeners();
    if (callback != null) callback();
  }

  void productVistualDevice(DeviceEntity element, String vistualName, String vistualType ,String statusIndex) {
    // 用json互转来深复制
    debugPrint('生产虚拟设备');
    // 避免重复生产
    if (deviceList.where((device) => element.sn8 == device.sn8).toList().length == 1) {
      DeviceEntity objCopy = DeviceEntity.fromJson(element.toJson());
      objCopy.type = vistualType;
      objCopy.name = vistualName;
      objCopy.detail = <String, dynamic>{
        "status": element.detail![statusIndex],
      };
      deviceList.add(objCopy);
      logger.i("VistualDeviceListModelChange: $deviceList");
    }
  }
}

