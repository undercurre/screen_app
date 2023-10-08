import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/gateway_platform.dart';
import '../../../../common/homlux/api/homlux_device_api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/homlux/models/homlux_response_entity.dart';
import '../../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';

class AirDataEntity {
  bool power = false; //开关
  String mode = "auto"; //模式
  int temperature = 0; //温度
  double smallTemperature = 0; //温度小数
  int wind = 102; // 风速

  AirDataEntity({
    required power,
    required mode,
    required temperature,
    required smallTemperature,
    required wind,
  });

  AirDataEntity.fromMeiJu(dynamic data) {
    power = data["power"] == "on";
    mode = data["mode"];
    temperature = data["temperature"];
    smallTemperature = double.parse(data["small_temperature"].toString());
    wind = data["wind_speed"];
  }

  Map<String, dynamic> toJson() {
    return {
      "power": power,
      "mode": mode,
      "temperature": temperature,
      "smallTemperature": smallTemperature,
      "wind": wind
    };
  }
}

class WIFIAirDataAdapter extends DeviceCardDataAdapter<AirDataEntity> {
  String deviceName = "Wifi空调";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  AirDataEntity? data = AirDataEntity(
    power: false,
    //开关
    mode: "auto",
    //模式
    temperature: 0,
    //温度
    smallTemperature: 0,
    //温度小数
    wind: 102,
  );

  final BuildContext context;

  WIFIAirDataAdapter(super.platform, this.context, this.applianceCode) {
    type = AdapterType.wifiAir;
  }

  @override
  void init() {
    fetchData();
    _startPushListen();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "power": data!.power,
      "mode": data!.mode,
      "temperature": data!.temperature,
      "smallTemperature": data!.smallTemperature,
      "wind": data!.wind
    };
  }

  @override
  bool getPowerStatus() {
    Log.i('获取开关状态', data!.power);
    return data!.power;
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  String? getCharacteristic() {
    return "${data!.temperature + data!.smallTemperature}℃";
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  @override
  Future<void> tryOnce() async {
    controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    return controlTemperature(value as num);
  }

  @override
  Future<dynamic> reduceTo(int? value) async {
    double target = data!.temperature + data!.smallTemperature - 0.5;
    return controlTemperature(target);
  }

  @override
  Future<dynamic> increaseTo(int? value) async {
    double target = data!.temperature + data!.smallTemperature + 0.5;
    return controlTemperature(target);
  }


  /// 防抖刷新
  void _throttledFetchData() {
    fetchData();
  }

  /// 查询状态
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;
      updateUI();
      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else if (platform.inHomlux()) {
      }
      if (_meijuData != null) {
        data = AirDataEntity.fromMeiJu(_meijuData!);
      } else if (_homluxData != null) {
      } else {
        dataState = DataState.ERROR;
        data = AirDataEntity(
          power: false,
          //开关
          mode: "auto",
          //模式
          temperature: 0,
          //温度
          smallTemperature: 0,
          //温度小数
          wind: 102,
        );
        updateUI();
        return;
      }
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      updateUI();
      Log.i(e.toString());
    }
  }

  Future<dynamic> fetchMeijuData() async {
    try {
      var nodeInfo =
          await MeiJuDeviceApi.getDeviceDetail('0x13', applianceCode);
      return nodeInfo.data;
    } catch (e) {
      Log.i('getNodeInfo Error', e);
      dataState = DataState.ERROR;
      updateUI();
      return null;
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    data!.power = !data!.power;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xAC',
          applianceCode: applianceCode,
          command: {"power": data!.power ? 'on' : 'off'});
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    } else if (platform.inHomlux()) {}
  }

  /// 控制风速
  Future<void> controlGear(num value) async {
    num realValue = (value - 1) * 20 == 0 ? 1 : (value - 1) * 20;
    int lastGear = data!.wind;
    data!.wind = realValue.toInt();
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xAC',
          applianceCode: applianceCode,
          command: {"wind_speed": data!.wind});
      if (res.isSuccess) {
      } else {
        data!.wind = lastGear;
      }
    } else if (platform.inHomlux()) {}
  }

  /// 控制温度
  Future<void> controlTemperature(num value) async {
    int lastTemp = data!.temperature;
    double lastStemp = data!.smallTemperature;
    data!.temperature = value.toInt();
    data!.smallTemperature = value.toDouble() - data!.temperature;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xAC',
          applianceCode: applianceCode,
          command: {
            "temperature": data!.temperature,
            "small_temperature": data!.smallTemperature
          });
      if (res.isSuccess) {
      } else {
        data!.temperature = lastTemp;
        data!.smallTemperature = lastStemp;
      }
    } else if (platform.inHomlux()) {}
  }

  /// 控制模式
  Future<void> controlMode(String mode) async {
    String lastMode = data!.mode;
    data!.mode = mode;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xAC',
          applianceCode: applianceCode,
          command: {"mode": mode});
      if (res.isSuccess) {
      } else {
        data!.mode = lastMode;
      }
    } else if (platform.inHomlux()) {}
  }

  void meijuPush(MeiJuWifiDevicePropertyChangeEvent args) {
    if (args.deviceId == applianceCode) {
      _throttledFetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent arg) {
    if (arg.deviceInfo.eventData?.deviceId == applianceCode) {
      _throttledFetchData();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
      Log.develop('$hashCode bind');
    } else {
      bus.typeOn<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
      Log.develop('$hashCode unbind');
    } else {
      bus.typeOff<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }
}
