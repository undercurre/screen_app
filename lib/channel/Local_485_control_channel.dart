import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_app/channel/asb_channel.dart';
import 'package:screen_app/common/homlux/models/homlux_485_device_list_entity.dart';
import 'package:screen_app/routes/sniffer/zigbee_icon_parse.dart';
import 'dart:developer';

import '../common/homlux/homlux_global.dart';
import '../common/logcat_helper.dart';
import 'models/manager_devic.dart';


class DeviceLocal485ControlChannel extends AbstractChannel {

  DeviceLocal485ControlChannel.fromName(super.channelName) : super.fromName();

  @override
  Future<dynamic> onMethodCallHandler(MethodCall call) async {
    super.onMethodCallHandler(call);
    final method = call.method;
    switch (method) {
      case "Local485AirConditionUpdate":
        break;
      case "Local485AirFreshUpdate":
        break;
      case "Local485FloorHeatUpdate":
        break;
    }
  }

  void find485Device() async {
    String result = await methodChannel.invokeMethod("find485Device");
    Homlux485DeviceListEntity deviceList= Homlux485DeviceListEntity.fromJson(jsonDecode(result));
    HomluxGlobal.homlux485DeviceList = deviceList;
  }

  void controlLocal485AirConditionPower(String power,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirConditionPower",{
      "power": power,
      "addr": addr
    });
  }

  void controlLocal485AirConditionTemper(String temper,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirConditionTemper",{
      "temper": temper,
      "addr": addr
    });
  }

  void controlLocal485AirConditionWindSpeed(String windSpeed,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirConditionWindSpeed",{
      "windSpeed": windSpeed,
      "addr": addr
    });
  }

  void controlLocal485AirConditionModel(String model,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirConditionModel",{
      "model": model,
      "addr": addr
    });
  }

  void controlLocal485AirFreshPower(String power,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirFreshPower",{
      "power": power,
      "addr": addr
    });
  }

  void controlLocal485AirFreshWindSpeed(String windSpeed,String addr) async {
    methodChannel.invokeMethod("ControlLocal485AirFreshWindSpeed",{
      "windSpeed": windSpeed,
      "addr": addr
    });
  }

  void controlLocal485FloorHeatPower(String power,String addr) async {
    methodChannel.invokeMethod("ControlLocal485FloorHeatPower",{
      "power": power,
      "addr": addr
    });
  }

  void controlLocal485FloorHeatTemper(String temper,String addr) async {
    methodChannel.invokeMethod("ControlLocal485FloorHeatTemper",{
      "temper": temper,
      "addr": addr
    });
  }

}
