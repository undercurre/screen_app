import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/states/profile_change_notifier.dart';

import '../common/api/user_api.dart';
import '../models/index.dart';
import '../routes/home/device/service.dart';

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
            (zigbeeControllerList[device.modelNumber] ==
                    '0x21_light_colorful' ||
                zigbeeControllerList[device.modelNumber] ==
                    '0x21_light_noColor')) ||
        device.type == 'lightGroup';
  }

  // 空调判断式
  bool airConditionFilter(DeviceEntity device) {
    return device.type == '0xAC';
  }

  // 隐藏判断式
  bool showFilter(DeviceEntity device) {
    return !DeviceService.isVistual(device);
  }

  // 虚拟判断式
  bool vistualFilter(DeviceEntity device) {
    return DeviceService.isVistual(device);
  }

  List<DeviceEntity> _deviceListResource =
      Global.profile.roomInfo?.applianceList ?? [];

  List<DeviceEntity> vistualProducts = [];

  List<DeviceEntity> get deviceList => _deviceListResource;
  
  List<String> get lightInGroupsList {
    List<String> lights = [];
    var lightGroupList = deviceList.where((element) => element.type == 'lightGroup').toList();
    for (var i = 0; i < lightGroupList.length; i ++) {
      var lightList = lightGroupList[i].detail!["applianceList"];
      for (var j = 0; j < lightList.length; j ++) {
        lights.add(lightList[j]["applianceCode"].toString());
      }
    }
    return lights;
  }

  List<DeviceEntity> get showList {
    var entityList = deviceList.where(showFilter).toList() + vistualProducts;
    List<DeviceEntity> sortList = [];
    List<DeviceEntity> supportList = entityList
        .where((element) => DeviceService.isSupport(element))
        .toList();
    List<DeviceEntity> nosupportList = entityList
        .where((element) => !DeviceService.isSupport(element))
        .toList();
    List<DeviceEntity> onlineList = supportList
        .where((element) => DeviceService.isOnline(element))
        .toList();
    List<DeviceEntity> outlineList = supportList
        .where((element) => !DeviceService.isOnline(element))
        .toList();
    onlineList.sort((a, b) {
      if (a.activeTime == '' ||
          b.activeTime == '' ||
          a.activeTime == null ||
          b.activeTime == null) {
        return 1;
      }
      if (DateTime.parse(a.activeTime)
          .compareTo(DateTime.parse(b.activeTime)) ==
          0) {
        return 1;
      }
      return DateTime.parse(a.activeTime)
          .compareTo(DateTime.parse(b.activeTime)) >
          0
          ? -1
          : 1;
    });
    sortList.addAll(onlineList);
    sortList.addAll(outlineList);
    sortList.addAll(nosupportList);
    return sortList;
  }

  List<DeviceEntity> get vistualList =>
      deviceList.where(vistualFilter).toList();

  List<DeviceEntity> get curtainList =>
      deviceList.where(curtainFilter).toList();

  List<DeviceEntity> get lightList => deviceList.where(lightFilter).toList();

  List<DeviceEntity> get airConditionList =>
      deviceList.where(airConditionFilter).toList();


  set deviceList(List<DeviceEntity> newList) {
    _deviceListResource = newList;
    logger.i("DeviceListChange: $deviceList");
    notifyListeners();
  }

  // 根据设备id获取设备的deviceInfo
  DeviceEntity getDeviceInfoById(String deviceId) {
    var curDeviceList = deviceList
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
    var curDeviceList = deviceList
        .where((element) =>
            element.applianceCode == deviceId && element.type == type)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      return curDevice;
    } else {
      return DeviceEntity();
    }
  }

  // 根据设备id获取设备的detail
  Map<String, dynamic> getDeviceDetailById(String deviceId) {
    var curDeviceList = deviceList
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
    // todo: 优化虚拟映射
    var curDeviceList = deviceList
        .where((element) =>
            element.applianceCode == deviceInfo.applianceCode)
        .toList();
    if (curDeviceList.isNotEmpty) {
      var curDevice = curDeviceList[0];
      var newDetail = await DeviceService.getDeviceDetail(deviceInfo);
      logger.i('请求来源：state详情');
      if (deviceInfo.type.contains('smartControl') || deviceInfo.type.contains('singlePanel')) {
        var filterList = vistualProducts
            .where((element) => element.applianceCode == deviceInfo.applianceCode && element.type == deviceInfo.type)
            .toList();
        if (filterList.isNotEmpty) {
          filterList[0].detail = newDetail;
        }
      }
      else {
        if (deviceInfo.type == 'lightGroup') {
          curDevice.detail!["detail"] = newDetail["group"];
        } else {
          curDevice.detail = newDetail;
        }
      }
      notifyListeners();
      if (callback != null) callback();
    }
  }

  // 重置设备detail
  void setProviderDeviceInfo(DeviceEntity device, {Function? callback}) {
    final index = deviceList
        .indexWhere((element) => element.applianceCode == device.applianceCode);
    deviceList[index] = device;
    notifyListeners();
    if (callback != null) callback();
  }

  // 虚拟设备生成器
  void productVistualDevice(DeviceEntity element, String vistualName,
      String vistualType) {
    // 用json互转来深复制
    DeviceEntity objCopy = DeviceEntity.fromJson(element.toJson());
    objCopy.type = vistualType;
    objCopy.name = vistualName;
    logger.i("生产虚拟设备: $objCopy");
    vistualProducts.add(objCopy);
    notifyListeners();
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
    logger.i('此时房间的信息', Global.profile.roomInfo);
    // 遍历
    for (int i = 1; i <= groupListInRoom.length; i++) {
      var group = groupListInRoom[i - 1];
      // 查找该灯组的详情
      var result = await DeviceApi.groupRelated(
          'findLampGroupDetails',
          const JsonEncoder().convert({
            "houseId": Global.profile.homeInfo?.homegroupId,
            "groupId": group["groupId"],
            "modelId": "midea.light.003.001",
            "uid": Global.profile.user?.uid,
          }));
      var detail = result.result["result"]["group"];
      if (detail == null) return;
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
        "detail": detail,
      };
      logger.i('生成灯组', vistualDeviceForGroup);
      deviceList.add(vistualDeviceForGroup);
      logger.i('生成灯组后', deviceList.where((element) => element.type == 'lightGroup'));
      notifyListeners();
    }
  }

  Future<void> updateAllDetail() async {
    final stopwatch = Stopwatch()..start();
    // 更新房间的信息
    await updateHomeData();
    logger.i('更新房间内所有设备状态优化后：更新房间信息', stopwatch.elapsedMilliseconds / 1000);
    // 查灯组
    await selectLightGroupList();
    logger.i('更新房间内所有设备状态优化后：查灯组', stopwatch.elapsedMilliseconds / 1000);
    // 更新设备detail
    // 放置虚拟设备
    await setVistualDevice();
    logger.i('更新房间内所有设备状态优化后：放置虚拟设备', stopwatch.elapsedMilliseconds / 1000);
    // for (int xx = 1; xx <= showList.length; xx++) {
    //   var deviceInfo = showList[xx - 1];
    //   // 查看品类控制器看是否支持该品类
    //   var hasController = getController(deviceInfo) != null;
    //   if (hasController &&
    //       DeviceService.isOnline(deviceInfo) &&
    //       DeviceService.isSupport(deviceInfo)) {
    //     // 调用provider拿detail存入状态管理里
    //     updateDeviceDetail(deviceInfo);
    //   }
    // }
    logger.i('更新房间内所有设备状态优化后：请求状态', stopwatch.elapsedMilliseconds / 1000);
  }

  Future<void> onlyFetchDetailForAll() async {
    for (int xx = 1; xx <= showList.length; xx++) {
      var deviceInfo = showList[xx - 1];
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          DeviceService.isSupport(deviceInfo)) {
        // 调用provider拿detail存入状态管理里
        await updateDeviceDetail(deviceInfo);
        logger.i('请求来源： onlyDetail详情');
      }
    }
  }

  Future<void> updateAllDetailWaited() async {
    final stopwatch = Stopwatch()..start();
    // 更新房间的信息
    await updateHomeData();
    logger.i('更新房间内所有设备状态优化后：更新房间信息', stopwatch.elapsedMilliseconds / 1000);
    // 查灯组
    await selectLightGroupList();
    logger.i('更新房间内所有设备状态优化后：查灯组', stopwatch.elapsedMilliseconds / 1000);
    // 更新设备detail
    List<Future<void>> futures = [];
    for (int xx = 1; xx <= showList.length; xx++) {
      var deviceInfo = showList[xx - 1];
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          DeviceService.isSupport(deviceInfo)) {
        // 调用provider拿detail存入状态管理里
        futures.add(updateDeviceDetail(deviceInfo));
        logger.i('请求来源：updateAllDetailWaited');
      }
    }
    await Future.wait(futures);
    logger.i('更新房间内所有设备状态优化后：请求状态', stopwatch.elapsedMilliseconds / 1000);
    // 放置虚拟设备
    await setVistualDevice();
    logger.i('更新房间内所有设备状态优化后：放置虚拟设备', stopwatch.elapsedMilliseconds / 1000);
  }

  Future<void> updateHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(
        homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      var homeInfo = res.data.homeList[0];
      var roomList = homeInfo.roomList ?? [];
      Global.profile.roomInfo = roomList
          .where((element) =>
              element.roomId == (Global.profile.roomInfo?.roomId ?? ''))
          .toList()[0];
      deviceList = roomList
          .where((element) =>
      element.roomId == (Global.profile.roomInfo?.roomId ?? ''))
          .toList()[0].applianceList;
    }
  }

  // 放置虚拟设备
  Future<void> setVistualDevice() async {
    // todo: 需要优化点
    logger.i('放置虚拟设备');
    vistualProducts = [];
    for (int xx = 1; xx <= vistualList.length; xx ++) {
      var deviceInfo = vistualList[xx - 1];
      logger.i('遍历虚拟设备', deviceInfo);
      // 智慧屏线控器
      if (deviceInfo.type == '0x16' && (deviceInfo.sn8 == "MSGWZ010" || deviceInfo.sn8 == "MSGWZ013")) {
        productVistualDevice(deviceInfo, '灯2', "smartControl-2");
        productVistualDevice(deviceInfo, '灯1', "smartControl-1");
      }
      // 面板
      if (deviceInfo.type == '0x21' && zigbeeControllerList[deviceInfo.modelNumber] == '0x21_panel') {
          MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(deviceInfo.applianceCode, deviceInfo.masterId);
          Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
          for (int lu = 1; lu <= infoMap["endlist"].length; lu ++) {
            // 水电面板识别
            var wtgList = ["81", "83", "1111", "1113", "1112", "1114"];
            var wtgNameList = ['水阀', '电阀', '气阀'];
            if (wtgList.contains(deviceInfo.modelNumber)) {
              productVistualDevice(deviceInfo, wtgNameList[lu - 1], "singlePanel-$lu");
            } else {
              productVistualDevice(
                  deviceInfo, infoMap["endlist"][lu - 1]["name"] ?? '按键$lu',
                  "singlePanel-$lu");
            }
          }
      }
    }
  }
}
