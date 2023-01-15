import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/plugins/0x16/api.dart';
import 'package:screen_app/routes/plugins/0x26/mode_list.dart';
import 'dart:convert';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../models/index.dart';
import '../routes/device/service.dart';

class DeviceListModel extends ProfileChangeNotifier {
  // 窗帘判断式
  bool curtainFilter(DeviceEntity device) {
    return device.type == '0x14' ||
        (device.type == '0x21' &&
            (zigbeeControllerList[device.modelNumber] == '0x21_curtain' ||
                zigbeeControllerList[device.modelNumber] ==
                    '0x21_curtain_panel_one' ||
                zigbeeControllerList[device.modelNumber] ==
                    '0x21_curtain_panel_two'));
  }

  // 灯光判断式
  bool lightFilter(DeviceEntity device) {
    return device.type == '0x13' ||
        (device.type == '0x21' &&
            (zigbeeControllerList[device.modelNumber] == '0x21_light_colorful' ||
                zigbeeControllerList[device.modelNumber] ==
                    '0x21_light_noColor'));
  }

  // 空调判断式
  bool airConditionFilter(DeviceEntity device) {
    return device.type == '0xAC';
  }


  List<DeviceEntity> _deviceListResource =
      Global.profile.roomInfo!.applianceList;

  List<DeviceEntity> get deviceList => _deviceListResource;

  List<DeviceEntity> get curtainList => _deviceListResource.where(curtainFilter).toList();

  List<DeviceEntity> get lightList => _deviceListResource.where(lightFilter).toList();

  List<DeviceEntity> get airConditionList => _deviceListResource.where(airConditionFilter).toList();

  set deviceList(List<DeviceEntity> newList) {
    _deviceListResource = newList;
    logger.i("DeviceListModelChange: $deviceList");
    notifyListeners();
  }

  // 根据设备id获取设备的deviceInfo
  DeviceEntity getDeviceInfoById(String deviceId) {
    var curDeviceList = _deviceListResource
        .where((element) => element.applianceCode == deviceId)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      return curDevice;
    } else {
      return DeviceEntity();
    }
  }

  // 根据设备id获取设备的deviceInfo
  DeviceEntity getDeviceInfoByIdAndType(String deviceId, String type) {
    var curDeviceList = _deviceListResource
        .where((element) => element.applianceCode == deviceId && element.type == type)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      return curDevice;
    } else {
      return DeviceEntity();
    }
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
        "sn8": curDevice.sn8,
        "modelNumber": curDevice.modelNumber,
        "deviceName": curDevice.name,
        "masterId": curDevice.masterId,
        "detail": curDevice.detail ?? {}
      };
    } else {
      return {};
    }
  }

  // 更新设备列表某一个设备的detail
  Future<void> updateDeviceDetail(DeviceEntity deviceInfo,
      {Function? callback}) async {
    // todo: 优化数据更新diff
    var curDeviceList = _deviceListResource
        .where((element) => element.applianceCode == deviceInfo.applianceCode && element.type == deviceInfo.type)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      var newDetail = await DeviceService.getDeviceDetail(deviceInfo);
      if (deviceInfo.type == 'lightGroup') {
        curDevice.detail!["detail"] = newDetail;
      } else if (deviceInfo.type == 'smartControl-1' || deviceInfo.type == 'smartControl-2') {
        curDevice.detail!['status'] = deviceInfo.type == 'smartControl-1' ? newDetail['panelOne'] : newDetail['panelTwo'];
        debugPrint('智慧屏$newDetail');
      } else if (deviceInfo.type == 'singlePanel-1' || deviceInfo.type == 'singlePanel-2' || deviceInfo.type == 'singlePanel-3' || deviceInfo.type == 'singlePanel-4') {
        debugPrint('面板${curDevice.detail!['status']["endPoint"]}');
        var panelIndex = curDevice.detail!['status']["endPoint"] - 1;
        debugPrint('面板${newDetail["deviceControlList"]}');
        curDevice.detail!['status'] = newDetail["deviceControlList"][panelIndex];
      } else {
        curDevice.detail = newDetail;
      }
      logger.i(
          "源数据: ${_deviceListResource.where((element) => element.applianceCode == deviceInfo.applianceCode).toList()[0].detail}");
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
      "status": indexOfList == null
          ? element.detail![statusIndex]
          : element.detail![statusIndex][indexOfList],
    };
    deviceList.add(objCopy);
    notifyListeners();
    logger.i("VistualDeviceListModelChange: $deviceList");
  }

  // 灯组查询
  Future<void> selectLightGroupList() async {
    // 获取家庭内灯组列表
    var res = await DeviceApi.getGroupList();
    var groupList = res.data["applianceGroupList"] as List<dynamic>;
    // 过滤成房间内的灯组列表
    var groupListInRoom = groupList
        .where((element) =>
            element["roomId"].toString() == Global.profile.roomInfo?.roomId)
        .toList();
    // 遍历
    for (int i = 1; i <= groupList.length; i++) {
      var group = groupList[i - 1];
      // 查找该灯组的详情
      var result = await DeviceApi.groupRelated(
          'findLampGroupDetails',
          const JsonEncoder().convert({
            "houseId": Global.profile.homeInfo?.homegroupId,
            "groupId": group["groupId"],
            "modelId": "midea.light.003.001",
            "uid": Global.profile.user?.uid,
          }));
      var detail = result.result["result"];
      debugPrint("灯组$group详情$detail");
      var vistualDeviceForGroup = DeviceEntity();
      vistualDeviceForGroup.applianceCode = group["groupId"].toString();
      vistualDeviceForGroup.modelNumber = '';
      vistualDeviceForGroup.sn = '';
      vistualDeviceForGroup.masterId = '';
      vistualDeviceForGroup.attrs = '';
      vistualDeviceForGroup.ability = {};
      vistualDeviceForGroup.activeStatus = '';
      vistualDeviceForGroup.isSupportFetchStatus = '';
      vistualDeviceForGroup.isOtherEquipment = '';
      vistualDeviceForGroup.hotspotName = '';
      vistualDeviceForGroup.btToken = '';
      vistualDeviceForGroup.bindType = 0;
      vistualDeviceForGroup.activeTime = '';
      vistualDeviceForGroup.type = 'lightGroup';
      vistualDeviceForGroup.name = group["name"];
      vistualDeviceForGroup.onlineStatus = '1';
      vistualDeviceForGroup.detail = {
        "id": group["id"],
        "groupId": group["groupId"],
        "applianceList": group["applianceList"],
        "detail": detail
      };
      _deviceListResource.add(vistualDeviceForGroup);
      notifyListeners();
      logger.i("vistualDeviceForGroup: $vistualDeviceForGroup");
    }
    logger.i("lightGroupListInRoom: $groupListInRoom");
    logger.i("deviceList: $deviceList");
  }
}
