import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/plugins/0x16/api.dart';
import 'dart:convert';
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

  // 根据设备id获取设备的detail
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

  // 更新设备列表所有设备的detail
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

  // 重置设备detail
  void setProviderDeviceInfo(DeviceEntity device, {Function? callback}) {
    final index = _deviceListResource
        .indexWhere((element) => element.applianceCode == device.applianceCode);
    _deviceListResource[index] = device;
    notifyListeners();
    if (callback != null) callback();
  }

  // 虚拟设备生成器
  void productVistualDevice(DeviceEntity element, String vistualName,
      String vistualType, String statusIndex,
      {int? indexOfList}) {
    // 用json互转来深复制
    debugPrint('生产虚拟设备');
    DeviceEntity objCopy = DeviceEntity.fromJson(element.toJson());
    objCopy.type = vistualType;
    objCopy.name = vistualName;
    objCopy.detail = <String, dynamic>{
      "status": indexOfList != null
          ? element.detail![statusIndex]
          : element.detail![statusIndex][indexOfList],
    };
    deviceList.add(objCopy);
    logger.i("VistualDeviceListModelChange: $deviceList");
  }

  // 灯组查询
  Future<void> selectLightGroupList() async {
    // 获取家庭内灯组列表
    var res = await DeviceApi.getGroupList();
    var groupList = res.data["applianceGroupList"] as List<dynamic>;
    // 过滤成房间内的灯组列表
    var groupListInRoom = groupList.where((element) => element["roomId"].toString() == Global.profile.roomInfo?.roomId).toList();
    // 遍历
    for (int i = 1; i <= groupList.length; i ++) {
      var group = groupList[i - 1];
      // 查找该灯组的详情
      var detail = await DeviceApi.groupRelated('findLampGroupDetails', const JsonEncoder().convert({
        "houseId": Global.profile.homeInfo?.homegroupId,
        "groupId": group["groupId"],
        "modelId": "midea.light.003.001",
        "uid": Global.profile.user?.uid,
      }));
      debugPrint("灯组$group详情$detail");
      var vistualDeviceForGroup = DeviceEntity();
      vistualDeviceForGroup.applianceCode = group["groupId"].toString();
      vistualDeviceForGroup.type = 'lightGroup';
      vistualDeviceForGroup.name = group["name"];
      vistualDeviceForGroup.onlineStatus = '1';
      vistualDeviceForGroup.detail = {
        "id": group["id"],
        "groupId": group["groupId"],
        "applianceList": group["applianceList"],
        "detail": detail
      };
      deviceList.add(vistualDeviceForGroup);
    }
    logger.i("lightGroupListInRoom: $groupListInRoom");
  }
}
