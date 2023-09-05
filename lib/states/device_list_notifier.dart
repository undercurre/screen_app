import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';

import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_485_device_list_entity.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/homlux/models/homlux_device_entity.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_device_api.dart';
import '../common/meiju/models/meiju_device_info_entity.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/system.dart';
import '../models/device_entity.dart';

class DeviceInfoListModel extends ChangeNotifier {
  List<MeiJuDeviceInfoEntity> deviceListMeiju = [];
  List<HomluxDeviceEntity> deviceListHomlux = [];
  List<DeviceEntity> MeijuGroup = [];

  DeviceListModel() {
    Log.i('deviceModel加载');
    getDeviceList();
  }

  List<DeviceEntity> getCacheDeviceList() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      List<DeviceEntity> tempList = deviceListMeiju.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.name!;
        deviceObj.applianceCode = e.applianceCode!;
        deviceObj.type = e.type!;
        deviceObj.modelNumber = e.modelNumber!;
        deviceObj.sn8 = e.sn8;
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.masterId!;
        deviceObj.onlineStatus = e.onlineStatus!;
        return deviceObj;
      }).toList();

      tempList.addAll(MeijuGroup);

      DeviceEntity vLocalPanel1 = DeviceEntity();
      vLocalPanel1.name = '灯1';
      vLocalPanel1.applianceCode = 'localPanel1';
      vLocalPanel1.type = 'localPanel1';
      vLocalPanel1.modelNumber = 'xx';
      vLocalPanel1.roomName = '本地';
      vLocalPanel1.masterId = uuid.v4();
      vLocalPanel1.onlineStatus = '1';
      tempList.add(vLocalPanel1);

      DeviceEntity vLocalPanel2 = DeviceEntity();
      vLocalPanel2.name = '灯2';
      vLocalPanel2.applianceCode = 'localPanel2';
      vLocalPanel2.type = 'localPanel2';
      vLocalPanel2.modelNumber = 'xx';
      vLocalPanel2.roomName = '本地';
      vLocalPanel2.masterId = uuid.v4();
      vLocalPanel2.onlineStatus = '1';
      tempList.add(vLocalPanel2);

      return tempList;
    } else {
      //homlux添加本地485的设备
      Log.i("添加485设备");
      Homlux485DeviceListEntity? deviceList =
          HomluxGlobal.getHomlux485DeviceList;

      ///homlux添加本地485空调设备
      for (int i = 0;
          i < deviceList!.nameValuePairs!.airConditionList!.length;
          i++) {
        Log.i("添加485空调");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName =
            "空调${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
        device.deviceId =
            "${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
        device.proType = "0x21";
        device.deviceType = 3017;
        device.roomName = System.roomInfo?.name;
        device.gatewayId = HomluxGlobal.gatewayApplianceCode;
        String? online =
            deviceList!.nameValuePairs!.airConditionList![i].onlineState;
        device.onLineStatus = int.parse(online!);
        deviceListHomlux.add(device);
      }

      ///homlux添加本地485新风设备
      for (int i = 0;
          i < deviceList!.nameValuePairs!.freshAirList!.length;
          i++) {
        Log.i("添加485新风");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName =
            "新风${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
        device.deviceId =
            "${(deviceList!.nameValuePairs!.freshAirList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
        device.proType = "0x21";
        device.deviceType = 3018;
        device.roomName = System.roomInfo?.name;
        device.gatewayId = HomluxGlobal.gatewayApplianceCode;
        String? online =
            deviceList!.nameValuePairs!.freshAirList![i].onlineState;
        device.onLineStatus = int.parse(online!);
        deviceListHomlux.add(device);
      }

      ///homlux添加本地485地暖设备
      for (int i = 0;
          i < deviceList!.nameValuePairs!.floorHotList!.length;
          i++) {
        Log.i("添加485地暖");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName =
            "地暖${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
        device.deviceId =
            "${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
        device.proType = "0x21";
        device.deviceType = 3019;
        device.roomName = System.roomInfo?.name;
        device.gatewayId = HomluxGlobal.gatewayApplianceCode;
        String? online =
            deviceList!.nameValuePairs!.floorHotList![i].onlineState;
        device.onLineStatus = int.parse(online!);
        deviceListHomlux.add(device);
      }

      List<DeviceEntity> tempList = deviceListHomlux.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.deviceName!;
        deviceObj.applianceCode = e.deviceId!;
        deviceObj.type = e.proType!;
        deviceObj.modelNumber = getModelNumber(e);
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.gatewayId ?? '';
        deviceObj.onlineStatus = e.onLineStatus.toString();
        return deviceObj;
      }).toList();

      DeviceEntity vLocalPanel1 = DeviceEntity();
      vLocalPanel1.name = '灯1';
      vLocalPanel1.applianceCode = 'localPanel1';
      vLocalPanel1.type = 'localPanel1';
      vLocalPanel1.modelNumber = 'xx';
      vLocalPanel1.roomName = '本地';
      vLocalPanel1.masterId = uuid.v4();
      vLocalPanel1.onlineStatus = '1';
      tempList.add(vLocalPanel1);

      DeviceEntity vLocalPanel2 = DeviceEntity();
      vLocalPanel2.name = '灯2';
      vLocalPanel2.applianceCode = 'localPanel2';
      vLocalPanel2.type = 'localPanel2';
      vLocalPanel2.modelNumber = 'xx';
      vLocalPanel2.roomName = '本地';
      vLocalPanel2.masterId = uuid.v4();
      vLocalPanel2.onlineStatus = '1';
      tempList.add(vLocalPanel2);

      return tempList;
    }
  }

  Future<List<DeviceEntity>> getDeviceList() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> MeijuRes =
          await MeiJuDeviceApi.queryDeviceListByHomeId(
              MeiJuGlobal.token!.uid, familyInfo!.familyId);

      MeiJuResponseEntity<Map<String, dynamic>> MeijuGroups =
          await MeiJuDeviceApi.getGroupList();
      if (MeijuRes.isSuccess && MeijuGroups.isSuccess) {
        deviceListMeiju = MeijuRes.data!;
        notifyListeners();

        List<DeviceEntity> tempList = deviceListMeiju.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.name!;
          deviceObj.applianceCode = e.applianceCode!;
          deviceObj.type = e.type!;
          deviceObj.modelNumber = e.modelNumber!;
          deviceObj.sn8 = e.sn8;
          deviceObj.roomName = e.roomName!;
          deviceObj.masterId = e.masterId!;
          deviceObj.onlineStatus = e.onlineStatus!;
          return deviceObj;
        }).toList();

        MeijuGroup = (MeijuGroups.data!["applianceGroupList"] as List<dynamic>)
            .map<DeviceEntity>((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e["name"];
          deviceObj.applianceCode = e["groupId"].toString();
          deviceObj.type = "0x21";
          deviceObj.modelNumber = "lightGroup";
          deviceObj.roomName = e["roomName"];
          deviceObj.masterId =
              e["applianceList"][0]["parentApplianceCode"].toString();
          deviceObj.onlineStatus = "1";
          return deviceObj;
        }).toList();

        tempList.addAll(MeijuGroup);

        DeviceEntity vLocalPanel1 = DeviceEntity();
        vLocalPanel1.name = '灯1';
        vLocalPanel1.applianceCode = 'localPanel1';
        vLocalPanel1.type = 'localPanel1';
        vLocalPanel1.modelNumber = 'xx';
        vLocalPanel1.roomName = '本地';
        vLocalPanel1.masterId = uuid.v4();
        vLocalPanel1.onlineStatus = '1';
        tempList.add(vLocalPanel1);

        DeviceEntity vLocalPanel2 = DeviceEntity();
        vLocalPanel2.name = '灯2';
        vLocalPanel2.applianceCode = 'localPanel2';
        vLocalPanel2.type = 'localPanel2';
        vLocalPanel2.modelNumber = 'xx';
        vLocalPanel2.roomName = '本地';
        vLocalPanel2.masterId = uuid.v4();
        vLocalPanel2.onlineStatus = '1';
        tempList.add(vLocalPanel2);

        Log.i('网表', tempList.map((e) => e.name).toList());

        return tempList;
      }
    } else {
      final familyInfo = System.familyInfo;
      HomluxResponseEntity<List<HomluxDeviceEntity>> HomluxRes =
          await HomluxDeviceApi.queryDeviceListByHomeId(familyInfo!.familyId);
      if (HomluxRes.isSuccess) {
        deviceListHomlux = HomluxRes.data!;
        notifyListeners();

        ///homlux添加本地485设备
        Homlux485DeviceListEntity? deviceList =
            HomluxGlobal.getHomlux485DeviceList;

        ///homlux添加本地485空调设备
        for (int i = 0;
            i < deviceList!.nameValuePairs!.airConditionList!.length;
            i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "空调${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3017;
          device.roomName = System.roomInfo?.name;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.airConditionList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }

        ///homlux添加本地485新风设备
        for (int i = 0;
            i < deviceList!.nameValuePairs!.freshAirList!.length;
            i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "新风${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.freshAirList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3018;
          device.roomName = System.roomInfo?.name;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.freshAirList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }

        ///homlux添加本地485地暖设备
        for (int i = 0;
            i < deviceList!.nameValuePairs!.floorHotList!.length;
            i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName =
              "地暖${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.deviceId =
              "${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.proType = "0x21";
          device.deviceType = 3019;
          device.roomName = System.roomInfo?.name;
          device.gatewayId = HomluxGlobal.gatewayApplianceCode;
          String? online =
              deviceList!.nameValuePairs!.floorHotList![i].onlineState;
          device.onLineStatus = int.parse(online!);
          deviceListHomlux.add(device);
        }

        List<DeviceEntity> tempList = deviceListHomlux.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.deviceName!;
          deviceObj.applianceCode = e.deviceId!;
          deviceObj.type = e.proType!;
          deviceObj.modelNumber = getModelNumber(e);
          deviceObj.roomName = e.roomName!;
          deviceObj.masterId = e.gatewayId ?? '';
          deviceObj.onlineStatus = e.onLineStatus.toString();
          return deviceObj;
        }).toList();

        DeviceEntity vLocalPanel1 = DeviceEntity();
        vLocalPanel1.name = '灯1';
        vLocalPanel1.applianceCode = 'localPanel1';
        vLocalPanel1.type = 'localPanel1';
        vLocalPanel1.modelNumber = 'xx';
        vLocalPanel1.roomName = '本地';
        vLocalPanel1.masterId = uuid.v4();
        vLocalPanel1.onlineStatus = '1';
        tempList.add(vLocalPanel1);

        DeviceEntity vLocalPanel2 = DeviceEntity();
        vLocalPanel2.name = '灯2';
        vLocalPanel2.applianceCode = 'localPanel2';
        vLocalPanel2.type = 'localPanel2';
        vLocalPanel2.modelNumber = 'xx';
        vLocalPanel2.roomName = '本地';
        vLocalPanel2.masterId = uuid.v4();
        vLocalPanel2.onlineStatus = '1';
        tempList.add(vLocalPanel2);

        return tempList;
      }
    }
    return [];
  }

  String getDeviceName({String? deviceId}) {
    if (deviceId != null) {
      if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
        List<MeiJuDeviceInfoEntity> curOne = deviceListMeiju
            .where((element) => element.applianceCode == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].name ?? '未知设备';
        } else {
          return '未知设备';
        }
      } else {
        List<HomluxDeviceEntity> curOne = deviceListHomlux
            .where((element) => element.deviceId == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].deviceName ?? '未知设备';
        } else {
          return '未知设备';
        }
      }
    } else {
      return '未知id';
    }
  }

  String getDeviceRoomName({String? deviceId}) {
    if (deviceId != null) {
      if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
        List<MeiJuDeviceInfoEntity> curOne = deviceListMeiju
            .where((element) => element.applianceCode == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].roomName ?? '未知区域';
        } else {
          return '未知区域';
        }
      } else {
        List<HomluxDeviceEntity> curOne = deviceListHomlux
            .where((element) => element.deviceId == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].roomName ?? '未知区域';
        } else {
          return '未知区域';
        }
      }
    } else {
      return '未知id';
    }
  }

  bool getOnlineStatus({String? deviceId}) {
    if (deviceId != null) {
      if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
        List<MeiJuDeviceInfoEntity> curOne = deviceListMeiju
            .where((element) => element.applianceCode == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].onlineStatus == '1';
        } else {
          return false;
        }
      } else {
        List<HomluxDeviceEntity> curOne = deviceListHomlux
            .where((element) => element.deviceId == deviceId).toList();
        if (curOne.isNotEmpty) {
          return curOne[0].onLineStatus == 1;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }
}

String getModelNumber(HomluxDeviceEntity e) {
  List<int> ac485List = [3017, 3018, 3019];
  if (e.proType == '0x21' && ac485List.contains(e.deviceType)) {
    return e.deviceType.toString();
  } else if (e.proType == '0x21') {
    return 'homlux${e.switchInfoDTOList?.length}';
  }

  if (e.proType == '0x13' && e.deviceType == 2) {
    return 'homluxZigbeeLight';
  }

  if (e.proType == '0x13' && e.deviceType == 4) {
    return 'homluxLightGroup';
  }

  return e.deviceType.toString();
}
