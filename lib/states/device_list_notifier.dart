import 'package:flutter/cupertino.dart';
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

  DeviceListModel() {
    getDeviceList();
  }

  List<DeviceEntity> getCacheDeviceList() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      Log.i('设备列表数据', deviceListMeiju.length);
      return deviceListMeiju.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.name!;
        deviceObj.applianceCode = e.applianceCode!;
        deviceObj.type = e.type!;
        deviceObj.modelNumber = e.modelNumber!;
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.masterId!;
        deviceObj.onlineStatus = e.onlineStatus!;
        return deviceObj;
      }).toList();
    } else {
      //homlux添加本地485的设备
      Log.i("添加485设备");
      Homlux485DeviceListEntity? deviceList = HomluxGlobal.getHomlux485DeviceList;
      ///homlux添加本地485空调设备
      for (int i = 0; i < deviceList!.nameValuePairs!.airConditionList!.length; i++) {
        Log.i("添加485空调");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName = "空调${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
        device.deviceId="${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
        device.proType="0x21";
        device.deviceType=3017;
        device.roomName=System.roomInfo?.name;
        device.gatewayId=HomluxGlobal.gatewayApplianceCode;
        String? online=deviceList!.nameValuePairs!.airConditionList![i].onlineState;
        device.onLineStatus=int.parse(online!);
        deviceListHomlux.add(device);
      }
      ///homlux添加本地485新风设备
      for (int i = 0; i < deviceList!.nameValuePairs!.freshAirList!.length; i++) {
        Log.i("添加485新风");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName = "新风${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
        device.deviceId="${(deviceList!.nameValuePairs!.freshAirList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
        device.proType="0x21";
        device.deviceType=3018;
        device.roomName=System.roomInfo?.name;
        device.gatewayId=HomluxGlobal.gatewayApplianceCode;
        String? online=deviceList!.nameValuePairs!.freshAirList![i].onlineState;
        device.onLineStatus=int.parse(online!);
        deviceListHomlux.add(device);
      }
      ///homlux添加本地485地暖设备
      for (int i = 0; i < deviceList!.nameValuePairs!.floorHotList!.length; i++) {
        Log.i("添加485地暖");
        HomluxDeviceEntity device = HomluxDeviceEntity();
        device.deviceName = "地暖${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
        device.deviceId="${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
        device.proType="0x21";
        device.deviceType=3019;
        device.roomName=System.roomInfo?.name;
        device.gatewayId=HomluxGlobal.gatewayApplianceCode;
        String? online=deviceList!.nameValuePairs!.floorHotList![i].onlineState;
        device.onLineStatus=int.parse(online!);
        deviceListHomlux.add(device);
      }

      return deviceListHomlux.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.deviceName!;
        deviceObj.applianceCode = e.deviceId!;
        deviceObj.type = e.proType!;
        deviceObj.modelNumber = e.deviceType.toString();
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.gatewayId!;
        deviceObj.onlineStatus = e.onLineStatus.toString();
        return deviceObj;
      }).toList();
    }
  }

  Future<List<DeviceEntity>> getDeviceList() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> MeijuRes =
          await MeiJuDeviceApi.queryDeviceListByHomeId(
              MeiJuGlobal.token!.uid, familyInfo!.familyId);
      if (MeijuRes.isSuccess) {
        deviceListMeiju = MeijuRes.data!;
        // Log.i('设备列表数据', deviceListMeiju.length);
        return deviceListMeiju.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.name!;
          deviceObj.applianceCode = e.applianceCode!;
          deviceObj.type = e.type!;
          deviceObj.modelNumber = e.modelNumber!;
          deviceObj.roomName = e.roomName!;
          deviceObj.masterId = e.masterId!;
          deviceObj.onlineStatus = e.onlineStatus!;
          return deviceObj;
        }).toList();
      }
    } else {
      final familyInfo = System.familyInfo;
      HomluxResponseEntity<List<HomluxDeviceEntity>> HomluxRes = await HomluxDeviceApi.queryDeviceListByRoomId(familyInfo!.roomNum);
      if (HomluxRes.isSuccess) {
        deviceListHomlux = HomluxRes.data!;
        ///homlux添加本地485设备
        Homlux485DeviceListEntity? deviceList = HomluxGlobal.getHomlux485DeviceList;
        ///homlux添加本地485空调设备
        for (int i = 0; i < deviceList!.nameValuePairs!.airConditionList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName = "空调${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.deviceId="${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}";
          device.proType="0x21";
          device.deviceType=3017;
          device.roomName=System.roomInfo?.name;
          device.gatewayId=HomluxGlobal.gatewayApplianceCode;
          String? online=deviceList!.nameValuePairs!.airConditionList![i].onlineState;
          device.onLineStatus=int.parse(online!);
          deviceListHomlux.add(device);
        }
        ///homlux添加本地485新风设备
        for (int i = 0; i < deviceList!.nameValuePairs!.freshAirList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName = "新风${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.deviceId="${(deviceList!.nameValuePairs!.freshAirList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.freshAirList![i].inSideAddress)!}";
          device.proType="0x21";
          device.deviceType=3018;
          device.roomName=System.roomInfo?.name;
          device.gatewayId=HomluxGlobal.gatewayApplianceCode;
          String? online=deviceList!.nameValuePairs!.freshAirList![i].onlineState;
          device.onLineStatus=int.parse(online!);
          deviceListHomlux.add(device);
        }
        ///homlux添加本地485地暖设备
        for (int i = 0; i < deviceList!.nameValuePairs!.floorHotList!.length; i++) {
          HomluxDeviceEntity device = HomluxDeviceEntity();
          device.deviceName = "地暖${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.deviceId="${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}";
          device.proType="0x21";
          device.deviceType=3019;
          device.roomName=System.roomInfo?.name;
          device.gatewayId=HomluxGlobal.gatewayApplianceCode;
          String? online=deviceList!.nameValuePairs!.floorHotList![i].onlineState;
          device.onLineStatus=int.parse(online!);
          deviceListHomlux.add(device);
        }
        return deviceListHomlux.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.deviceName!;
          deviceObj.applianceCode = e.deviceId!;
          deviceObj.type = e.proType!;
          deviceObj.modelNumber = e.deviceType.toString();
          deviceObj.roomName = e.roomName!;
          deviceObj.masterId = e.gatewayId!;
          deviceObj.onlineStatus = e.onLineStatus.toString();
          return deviceObj;
        }).toList();
      }
    }
    return [];
  }
}
