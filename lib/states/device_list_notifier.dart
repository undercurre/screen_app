import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';

import '../common/gateway_platform.dart';
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
      return deviceListHomlux.map((e) {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = e.deviceName!;
        deviceObj.applianceCode = e.deviceId!;
        deviceObj.type = e.proType!;
        deviceObj.modelNumber = 'homlux${e.switchInfoDTOList?.length}';
        deviceObj.roomName = e.roomName!;
        deviceObj.masterId = e.gatewayId ?? '';
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
      HomluxResponseEntity<List<HomluxDeviceEntity>> HomluxRes =
          await HomluxDeviceApi.queryDeviceListByHomeId(familyInfo!.familyId);
      if (HomluxRes.isSuccess) {
        deviceListHomlux = HomluxRes.data!;
        return deviceListHomlux.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.deviceName!;
          deviceObj.applianceCode = e.deviceId!;
          deviceObj.type = e.proType!;
          deviceObj.modelNumber = 'homlux${e.switchInfoDTOList?.length}';
          deviceObj.roomName = e.roomName!;
          deviceObj.masterId = e.gatewayId ?? '';
          deviceObj.onlineStatus = e.onLineStatus.toString();
          return deviceObj;
        }).toList();
      }
    }
    return [];
  }
}
