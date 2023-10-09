import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/homlux/models/homlux_485_device_list_entity.dart';

import '../common/gateway_platform.dart';
import '../common/homlux/homlux_global.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_device_api.dart';
import '../common/meiju/meiju_global.dart';
import '../common/meiju/models/meiju_device_info_entity.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/models/endpoint.dart';
import '../common/models/node_info.dart';
import '../common/system.dart';
import '../models/device_entity.dart';
import '../routes/plugins/0x21/0x21_485_air/air_data_adapter.dart';
import '../routes/plugins/0x21/0x21_485_cac/cac_data_adapter.dart';
import '../routes/plugins/0x21/0x21_485_floor/floor_data_adapter.dart';
import 'models/local_485_device_state.dart';

class DeviceLocal485ControlChannel extends AbstractChannel {
  DeviceLocal485ControlChannel.fromName(super.channelName) : super.fromName();
  late final local485ChangeCallbacks = <void Function(Local485DeviceState)>[];

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    final method = call.method;
    final args = call.arguments;
    switch (method) {
      case "Local485DeviceUpdate":
        Log.i("Channel收到设备变化:$args");
        Local485DeviceState deviceState = Local485DeviceState.fromJson(args);
        transmitDataLocal485ChangeCallBack(deviceState);
        break;
      case "query485DeviceListByHomeId":
        query485DeviceListByHomeId();
        break;
    }
  }

  void transmitDataLocal485ChangeCallBack(Local485DeviceState state) {
    for (var callback in local485ChangeCallbacks) {
      callback.call(state);
    }
  }

  // 注册回调
  void registerLocal485CallBack(void Function(Local485DeviceState) action) {
    if (!local485ChangeCallbacks.contains(action)) {
      local485ChangeCallbacks.add(action);
    }
  }

  // 注销回调
  void unregisterLocal485CallBack(void Function(Local485DeviceState) action) {
    final position = local485ChangeCallbacks.indexOf(action);
    if (position != -1) {
      local485ChangeCallbacks.remove(action);
    }
  }

  void find485Device() async {
    String result = await methodChannel.invokeMethod("find485Device");
    Homlux485DeviceListEntity deviceList =
        Homlux485DeviceListEntity.fromJson(jsonDecode(result));
    HomluxGlobal.homlux485DeviceList = deviceList;
  }

  void get485DeviceStateByAddr(String addr){
    methodChannel.invokeMethod("get485DeviceStateByAddr", {"addr": addr});
  }

  void controlLocal485AirConditionPower(String power, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485AirConditionPower", {"power": power, "addr": addr});
  }

  void controlLocal485AirConditionTemper(String temper, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485AirConditionTemper", {"temper": temper, "addr": addr});
  }

  void controlLocal485AirConditionWindSpeed(
      String windSpeed, String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirConditionWindSpeed",
        {"windSpeed": windSpeed, "addr": addr});
  }

  void controlLocal485AirConditionModel(String model, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485AirConditionModel", {"model": model, "addr": addr});
  }

  void controlLocal485AirFreshPower(String power, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485AirFreshPower", {"power": power, "addr": addr});
  }

  void controlLocal485AirFreshWindSpeed(String windSpeed, String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirFreshWindSpeed",
        {"windSpeed": windSpeed, "addr": addr});
  }

  void controlLocal485FloorHeatPower(String power, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485FloorHeatPower", {"power": power, "addr": addr});
  }

  void controlLocal485FloorHeatTemper(String temper, String addr) async {
    methodChannel.invokeMethod(
        "ControlLocal485FloorHeatTemper", {"temper": temper, "addr": addr});
  }

  void send485DeviceList(List<String> list) async {
    methodChannel.invokeMethod("send485DeviceList", {"485DeviceList": list});
  }

  void query485DeviceListByHomeId() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      List<String> device485NodeId = [];
      final familyInfo = System.familyInfo;
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> MeijuRes =
          await MeiJuDeviceApi.queryDeviceListByHomeId(
              MeiJuGlobal.token!.uid, familyInfo!.familyId);
      MeiJuResponseEntity<Map<String, dynamic>> MeijuGroups =
          await MeiJuDeviceApi.getGroupList();
      if (MeijuRes.isSuccess && MeijuGroups.isSuccess) {
        List<MeiJuDeviceInfoEntity> deviceListMeiju = MeijuRes.data!;
        List<DeviceEntity> tempList = deviceListMeiju.map((e) {
          DeviceEntity deviceObj = DeviceEntity();
          deviceObj.name = e.name!;
          deviceObj.applianceCode = e.applianceCode!;
          deviceObj.type = e.type!;
          deviceObj.modelNumber = e.modelNumber!;
          deviceObj.sn8 = e.sn8;
          deviceObj.roomName = e.roomName!;
          deviceObj.roomId = e.roomId!;
          deviceObj.masterId = e.masterId!;
          deviceObj.onlineStatus = e.onlineStatus!;
          return deviceObj;
        }).toList();
        final stream = Stream.fromIterable(tempList);
        await for (DeviceEntity device in stream) {
          if (device.modelNumber == "3017") {
            await query485CACNodeId(device.applianceCode, device.masterId).then(
                (value) => {device485NodeId.add(value)});
          } else if (device.modelNumber == "3018") {
            await query485AirNodeId(device.applianceCode, device.masterId).then(
                (value) => {device485NodeId.add(value)});
          } else if (device.modelNumber == "3019") {
            await query485FloorNodeId(device.applianceCode, device.masterId).then(
                (value) => {device485NodeId.add(value)});
          }
        }
        Log.i('美居设备485的NodeID列表数量:${device485NodeId.length}');
        send485DeviceList(device485NodeId);
      }
    }
  }

  Future<String> query485CACNodeId(
      String applianceCode, String masterId) async {
    NodeInfo<Endpoint<CAC485Event>> nodeInfo =
        await MeiJuDeviceApi.getGatewayInfo<CAC485Event>(
            applianceCode, masterId, (json) => CAC485Event.fromJson(json));
    String nodeId = nodeInfo.nodeId;
    return nodeId;
  }

  Future<String> query485AirNodeId(
      String applianceCode, String masterId) async {
    NodeInfo<Endpoint<Air485Event>> nodeInfo =
        await MeiJuDeviceApi.getGatewayInfo<Air485Event>(
            applianceCode, masterId, (json) => Air485Event.fromJson(json));
    String nodeId = nodeInfo.nodeId;
    return nodeId;
  }

  Future<String> query485FloorNodeId(
      String applianceCode, String masterId) async {
    NodeInfo<Endpoint<Floor485Event>> nodeInfo =
        await MeiJuDeviceApi.getGatewayInfo<Floor485Event>(
            applianceCode, masterId, (json) => Floor485Event.fromJson(json));
    String nodeId = nodeInfo.nodeId;
    return nodeId;
  }
}
