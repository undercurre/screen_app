import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:screen_app/common/adapter/midea_data_adapter.dart';

import '../../widgets/event_bus.dart';
import '../gateway_platform.dart';
import '../logcat_helper.dart';
import '../meiju/api/meiju_device_api.dart';
import '../meiju/meiju_global.dart';
import '../meiju/push/event/meiju_push_event.dart';
import 'device_card_data_adapter.dart';

class RangeHoodDeviceDataAdapter extends DeviceCardDataAdapter<RangeHoodData> {
  final String applianceCode;
  final String masterId;
  String nodeId = '';
  String modelNumber = '';

  dynamic _meijuData = null;

  static RangeHoodDeviceDataAdapter create(
      String applianceCode, String masterId, String modelNumber) {
    return RangeHoodDeviceDataAdapter(
        applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }

  RangeHoodDeviceDataAdapter(this.applianceCode, this.masterId, this.modelNumber, super.platform) {
    data = RangeHoodData.defaultData();
  }

  @override
  void init() {
    super.init();
    _startPushListen();
  }

  RangeHoodData getData() {
    return data!;
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

  @override
  Future<void> fetchData() async {
    dataState = DataState.LOADING;
    if(platform.inMeiju()) {
      _meijuData = await fetchMeijuData();
    }

    if(_meijuData != null) {
      data = RangeHoodData.fromMeiJu(_meijuData);
      dataState = DataState.SUCCESS;
      Log.file("[油烟机] 请求成功" );
    } else {
      dataState = DataState.ERROR;
      data ??= RangeHoodData.defaultData();
      data?.online = false;
      Log.file("[油烟机] 请求失败" );
    }
    updateUI();
    return;
  }

  Future<dynamic> fetchMeijuData() async {
    try {
      var nodeInfo = await MeiJuDeviceApi.getDeviceDetail('0xB6', applianceCode);
      return nodeInfo.data;
    } catch(e) {
      Log.i('getNodeInfo Error', e);
      dataState = DataState.ERROR;
      updateUI();
      return null;
    }
  }

  @override
  Future<dynamic> power(bool? onOff) async {
    data?.onOff = onOff!;
    updateUI();
    if(platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrderByIOT({
        "applianceCode": applianceCode,
        "command": {
          "control": {
            "type": "b6",
            "b6_action": "control",
            "power": onOff! ? 'on' : 'off',
            "electronic_control_version": 2
          }
        },
        "uid": MeiJuGlobal.token?.iotUserId
      });
    }
  }

  @override
  bool? getPowerStatus() {
    return getData().onOff;
  }

  @override
  String? getDeviceId() {
    return applianceCode;
  }

  @override
  Future<dynamic> increaseTo(int? value) async {
      data?.currentSpeed = min(value!, getData().maxSpeed);
      updateUI();
      if(platform.inMeiju()) {
        var res = await MeiJuDeviceApi.sendLuaOrderByIOT({
          "applianceCode": applianceCode,
          "command": {
            "control": {
              "type": "b6",
              "b6_action": "control",
              "gear": value!,
              "electronic_control_version": 2
            }
          },
          "uid": MeiJuGlobal.token?.iotUserId
        });
      }
  }

  @override
  Future<dynamic> reduceTo(int? value) async {
      data?.currentSpeed = max(value!, getData().minSpeed);
      updateUI();
      if(platform.inMeiju()) {
        var res = await MeiJuDeviceApi.sendLuaOrderByIOT({
          "applianceCode": applianceCode,
          "command": {
            "control": {
              "type": "b6",
              "b6_action": "control",
              "gear": value!,
              "electronic_control_version": 2
            }
          },
          "uid": MeiJuGlobal.token?.iotUserId
        });
      }
  }

  Future<dynamic> slider1To(int? value) async {
    data?.currentSpeed = value!;
    updateUI();
    if(platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrderByIOT({
        "applianceCode": applianceCode,
        "command": {
          "control": {
            "type": "b6",
            "b6_action": "control",
            "gear": value!,
            "electronic_control_version": 2
          }
        },
        "uid": MeiJuGlobal.token?.iotUserId
      });
    }
  }

  Future<void> lightPower(bool power) async {
    data?.lightOnOff = power ? 1 : 0;
    updateUI();
    if(platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrderByIOT({
        "applianceCode": applianceCode,
        "command": {
          "control": {
            "type": "b6",
            "b6_action": "setting",
            "setting": "light",
            "light": power? "on" : "off",
            "electronic_control_version": 2
          }
        },
        "uid": MeiJuGlobal.token?.iotUserId
      });
    }
  }

  void meijuPush(MeiJuWifiDevicePropertyChangeEvent args) {
    if (args.deviceId == applianceCode) {
      fetchData();
    }
  }

  void _startPushListen() {
    if (platform.inMeiju()) {
      bus.typeOn<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (platform.inMeiju()) {
      bus.typeOff<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }
}

class RangeHoodData {
  late String name;

  // 当前风速挡位
  late int currentSpeed;

  late int minSpeed;

  late int maxSpeed;

  // 照明是否打开
  late int lightOnOff;

  // 烟机是否打开
  late bool onOff;

  // 是否在线
  late bool online;

  RangeHoodData(
      {required this.name,
      required this.currentSpeed,
      required this.minSpeed,
      required this.maxSpeed,
      required this.lightOnOff,
      required this.onOff,
      required this.online});

  RangeHoodData.defaultData() {
    this.name = "抽油烟机";
    this.currentSpeed = 3;
    this.minSpeed = 0;
    this.maxSpeed = 3;
    this.lightOnOff = 0;
    this.onOff = true;
    this.online = false;
  }

  RangeHoodData.fromMeiJu(meijuData) {
    Log.file('烟机数据更新 ${meijuData["light"]} 照明：${meijuData["light"] == "off" ? 0 : 1}');
    this.name = "抽油烟机";
    this.currentSpeed = meijuData["gear"];
    this.minSpeed = 0;
    this.maxSpeed = 4;
    this.lightOnOff = meijuData["light"] == "off" ? 0 : 1;
    this.onOff = meijuData["power"] == 'on';
    this.online = true;
  }

  RangeHoodData.fromHomlux() {
    this.name = "抽油烟机";
    this.currentSpeed = 1;
    this.minSpeed = 0;
    this.maxSpeed = 3;
    this.lightOnOff = 0;
    this.onOff = false;
    this.online = false;
  }
}
