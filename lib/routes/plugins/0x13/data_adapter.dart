import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/homlux/api/homlux_device_api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/homlux/models/homlux_response_entity.dart';
import '../../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../../common/meiju/meiju_global.dart';
import '../../../common/meiju/models/meiju_device_info_entity.dart';
import '../../../common/system.dart';

class LightDataEntity {
  int brightness = 1; // 亮度
  int colorTemp = 0; // 色温
  bool power = false; //开关
  String screenModel = 'manual'; //模式
  int timeOff = 0; //延时关
  int maxColorTemp = 5700;
  int minColorTemp = 3000;

  LightDataEntity({
    required brightness,
    required colorTemp,
    required power,
    required screenModel,
    required timeOff,
  });

  LightDataEntity.fromMeiJu(dynamic data, String sn8) {
    if (sn8 == "79009833") {
      brightness = int.parse(data["brightValue"]) < 1 ? 1 : data["brightValue"];
      colorTemp = int.parse(data["color_temperature"]);
      power = data["power"];
      screenModel = data["screenModel"];
      timeOff = int.parse(data["timeOff"]);
    } else if (sn8 == "7909AC81") {
      brightness = int.parse(data["brightness"]);
      if (brightness < 100) {
        brightness--;
      }
      if (brightness < 0) {
        brightness = 1;
      }
      colorTemp = int.parse(data["color_temperature"]);
      power = data["power"] == 'on';
      screenModel = data["scene_light"] ?? 'manual';
      timeOff = int.parse(data["delay_light_off"]);
      maxColorTemp = int.parse(data["temperature_max"] ?? '5700');
      minColorTemp = int.parse(data["temperature_min"] ?? '3000');
    } else {
      brightness = ((int.parse(data["brightness"]) < 1 ? 1 : int.parse(data["brightness"])) / 255 * 100).toInt();
      colorTemp = (int.parse(data["color_temperature"]) / 255 * 100).toInt() ;
      power = data["power"] == 'on';
      screenModel = data["scene_light"] ?? 'manual';
      timeOff = int.parse(data["delay_light_off"]);
      maxColorTemp = int.parse(data["temperature_max"] ?? '5700');
      minColorTemp = int.parse(data["temperature_min"] ?? '3000');
    }
  }

  LightDataEntity.fromHomlux(HomluxDeviceEntity data) {
    brightness = data.mzgdPropertyDTOList?.light?.brightness ?? 0;
    colorTemp = data.mzgdPropertyDTOList?.light?.colorTemperature ?? 0;
    power = data.mzgdPropertyDTOList?.light?.wifiLightPower == "on"
        || data.mzgdPropertyDTOList?.light?.power == 1;
    screenModel = data.mzgdPropertyDTOList?.light?.wifiLightScene ?? "manual";
    timeOff = int.parse(data.mzgdPropertyDTOList?.light?.wifiLightDelayOff ?? "0");
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'colorTemp': colorTemp,
      'power': power,
      'timeOff': timeOff,
    };
  }
}

class WIFILightDataAdapter extends DeviceCardDataAdapter<LightDataEntity> {
  String deviceName = "Wifi智能灯";
  String sn8 = "";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  LightDataEntity? data = LightDataEntity(
      brightness: 0,
      colorTemp: 0,
      power: false,
      timeOff: 0,
      screenModel: 'manual');

  final BuildContext context;

  WIFILightDataAdapter(super.platform, this.context, this.sn8, this.applianceCode) {
    Log.i('获取到当前吸顶灯的sn8', this.sn8);
    type = AdapterType.wifiLight;
  }

  @override
  void init() {
    _startPushListen();
    getSN8();
  }

  Future<void> getSN8() async {
    if (platform.inMeiju() && sn8.isEmpty) {
      String id = System.familyInfo?.familyId ?? "";
      if (id.isEmpty) {
        return;
      }
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> res =
      await MeiJuDeviceApi.queryDeviceListByHomeId(
          MeiJuGlobal.token!.uid, id);
      if (res.isSuccess) {
        res.data?.forEach((element) {
          if (element.applianceCode == applianceCode) {
            sn8 = element.sn8;
            return;
          }
        });
      }
    }
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "power": data!.power,
      "brightness": data!.brightness == 0 ? 1 : data!.brightness,
      "colorTemp": data!.colorTemp,
      "maxColorTemp": data!.maxColorTemp,
      "minColorTemp": data!.minColorTemp
    };
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  bool getPowerStatus() {
    return data!.power;
  }

  @override
  String? getCharacteristic() {
    return "${data!.brightness == 0 ? 1 : data!.brightness}%";
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    return controlBrightness(value as num, null);
  }

  @override
  Future<dynamic> slider1ToFaker(int? value) async {
    return controlBrightnessFaker(value as num, null);
  }

  @override
  Future<dynamic> slider2To(int? value) async {
    return controlColorTemperature(value as num, null);
  }

  @override
  Future<dynamic> slider2ToFaker(int? value) async {
    return controlColorTemperatureFaker(value as num, null);
  }

  /// 防抖刷新
  void _throttledFetchData() {
    fetchData();
  }

  @override
  Future<void> tryOnce() async {
    controlPower();
  }

  /// 查询状态
  Future<void> fetchData() async {
    // try {
      dataState = DataState.LOADING;
      updateUI();
      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else if (platform.inHomlux()) {
        _homluxData = await fetchHomluxData();
      }
      if (_meijuData != null) {
        data = LightDataEntity.fromMeiJu(_meijuData!, sn8);
      } else if (_homluxData != null) {
        data = LightDataEntity.fromHomlux(_homluxData!);
      } else {
        dataState = DataState.ERROR;
        data = LightDataEntity(
            brightness: 0,
            colorTemp: 0,
            power: false,
            timeOff: 0,
            screenModel: 'manual');
        updateUI();
        return;
      }
      dataState = DataState.SUCCESS;
      updateUI();
    // } catch (e) {
    //   // Error occurred while fetching data
    //   dataState = DataState.ERROR;
    //   updateUI();
    //   Log.i(e.toString());
    // }
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

  Future<HomluxDeviceEntity> fetchHomluxData() async {
    HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes =
        await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
    HomluxDeviceEntity? nodeInfo = nodeInfoRes.result;
    if (nodeInfo != null) {
      return nodeInfo;
    } else {
      return HomluxDeviceEntity();
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    data!.power = !data!.power;
    updateUI();
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var command = {"power": data!.power ? 'on' : 'off'};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightOnOff(
          applianceCode, "3", data!.power ? 1 : 0);
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
        updateUI();
      }
    }
    updateUI();
  }

  /// 控制延时关
  Future<void> controlDelay() async {
    int lastTimeOff = data!.timeOff;
    if (!data!.power) return;
    if (data!.timeOff == 0) {
      data!.timeOff = 3;
    } else {
      data!.timeOff = 0;
    }
    updateUI();
    if (platform.inMeiju()) {
      var res;
      if (sn8 == '79009833') {
        var command = {"timeOff": data!.timeOff};
        res = await MeiJuDeviceApi.sendPDMControlOrder(
            categoryCode: '0x13',
            uri: 'setTimeOff',
            applianceCode: applianceCode,
            command: command);
      } else {
        var command = {"delay_light_off": data!.timeOff};
        res = await MeiJuDeviceApi.sendLuaOrder(
            categoryCode: '0x13',
            applianceCode: applianceCode,
            command: command);
      }
      if (res.isSuccess) {
      } else {
        data!.timeOff = lastTimeOff;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightDelayOff(
          applianceCode, "3", data!.timeOff);
      if (res.isSuccess) {
      } else {
        data!.timeOff = lastTimeOff;
      }
    }
  }

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    String lastModel = data!.screenModel;
    data!.screenModel = mode.key;
    updateUI();
    if (platform.inMeiju()) {
      var res;
      if (sn8 == '79009833') {
        var command = {"dimTime": 0, "screenModel": mode.key};
        res = await MeiJuDeviceApi.sendPDMControlOrder(
          categoryCode: '0x13',
          uri: 'controlScreenModel',
          applianceCode: applianceCode,
          command: command,
        );
      } else {
        var command = {"scene_light": mode.key};
        res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x13',
          applianceCode: applianceCode,
          command: command,
        );
      }
      if (res.isSuccess) {
      } else {
        data!.screenModel = lastModel;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightMode(
          applianceCode, "3", mode.key);

      if (res.isSuccess) {
      } else {
        data!.screenModel = lastModel;
      }
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    int lastBrightness = data!.brightness;
    data!.brightness = value.toInt();
    updateUI();

    if (platform.inMeiju()) {
      var res;
      if (sn8 == '79009833') {
        var command = {
          "dimTime": 0,
          "brightValue":
              int.parse((data!.brightness / 100 * 255).toStringAsFixed(0))
        };
        res = await MeiJuDeviceApi.sendPDMControlOrder(
          categoryCode: '0x13',
          uri: 'controlBrightValue',
          applianceCode: applianceCode,
          command: command,
        );
      } else if (sn8 == '79010914') {
        var command = {
          "brightness":
          int.parse((data!.brightness / 100 * 255).toStringAsFixed(0))
        };
        res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x13',
          applianceCode: applianceCode,
          command: command,
        );
      } else {
        var command = {
          "brightness": data!.brightness
        };
        res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x13',
          applianceCode: applianceCode,
          command: command,
        );
      }
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightBrightness(
          applianceCode, "3", value.toInt());
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
      }
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    int lastColorTemp = data!.colorTemp;
    data!.colorTemp = value.toInt();
    updateUI();
    if (platform.inMeiju()) {
      var res;
      if (sn8 == '79009833') {
        var command = {
          "dimTime": 0,
          "colorTemperatureValue": int.parse(
            (data!.colorTemp / 100 * 255).toStringAsFixed(0),
          )
        };
        res = await MeiJuDeviceApi.sendPDMControlOrder(
          categoryCode: '0x13',
          uri: 'controlColorTemperatureValue',
          applianceCode: applianceCode,
          command: command,
        );
      } else if (sn8 == '79010914') {
        var command = {
          "color_temperature":
          int.parse((data!.colorTemp / 100 * 255).toStringAsFixed(0))
        };
        res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x13',
          applianceCode: applianceCode,
          command: command,
        );
      } else {
        var command = {
          "color_temperature": data!.colorTemp
        };
        res = await MeiJuDeviceApi.sendLuaOrder(
            categoryCode: '0x13',
            applianceCode: applianceCode,
            command: command);
      }
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightColorTemp(
          applianceCode, "3", value.toInt());
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    }
  }

  Future<void> controlBrightnessFaker(num value, Color? activeColor) async {
    data!.brightness = value.toInt();
    updateUI();
  }

  Future<void> controlColorTemperatureFaker(num value, Color? activeColor) async {
    data!.colorTemp = value.toInt();
    updateUI();
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
