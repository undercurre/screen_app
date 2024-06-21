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
import '../../../widgets/util/deviceEntityTypeInP4Handle.dart';

class LightFunDataEntity {
  int brightness = 1; // 亮度
  int colorTemp = 0; // 色温
  bool funPower = false; //风扇开关
  bool ledPower=false;
  String fanScene = ''; //自然风模式
  int maxColorTemp = 5700;
  int minColorTemp = 3000;
  int arroundDir=1;
  int fanSpeed=1;
  int onlineState = 0;

  LightFunDataEntity({
    required this.brightness,
    required this.colorTemp,
    required this.funPower,
    required this.fanScene,
    required this.onlineState,
    required this.ledPower,
    required this.fanSpeed,
    required this.arroundDir,


  });

  LightFunDataEntity.fromMeiJu(dynamic data, String sn8) {
    onlineState = 1;
    if (sn8.isNotEmpty&&sn8 == "79010863") {
      brightness = int.parse(data["brightness"]) < 1 ? 1 : int.parse(data["brightness"]);
      colorTemp = int.parse(data["color_temperature"]);
      funPower = data["fan_power"] == 'on';
      ledPower=data["led_power"] == 'on';
      fanScene = data["fan_scene"];
      maxColorTemp = int.parse(data["temperature_max"] ?? '5700');
      minColorTemp = int.parse(data["temperature_min"] ?? '3000');
      fanSpeed=int.parse(data["fan_speed"]);
      arroundDir=int.parse(data["arround_dir"]);
    } else  {
      brightness = 1;
      colorTemp = 0;
      funPower = data["fan_power"] == 'on';
      ledPower=data["led_power"] == 'on';
      fanScene = data["fan_scene"] ?? 'fanmanual';
      fanSpeed=int.parse(data["fan_speed"]);
      arroundDir=int.parse(data["arround_dir"]);
    }
  }

  LightFunDataEntity.fromHomlux(HomluxDeviceEntity data);

}

class WIFILightFunDataAdapter extends DeviceCardDataAdapter<LightFunDataEntity> {
  String deviceName = "Wifi风扇灯";
  String sn8 = "";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  LightFunDataEntity? data = LightFunDataEntity(
      brightness: 1,
      colorTemp: 1,
      funPower: false,
      fanScene: 'fanmanual',
      onlineState: 0,
      ledPower:false,
      fanSpeed: 1,
      arroundDir: 1,
  );

  @override
  bool fetchOnlineState(BuildContext context, String deviceId) {
    if(platform.inMeiju()) {
      return super.fetchOnlineState(context, deviceId);
    } else {
      return data?.onlineState == 1;
    }
  }


  WIFILightFunDataAdapter(super.platform, this.sn8, this.applianceCode) {
    Log.i('获取到当前吸顶灯的sn8', this.sn8);
    type = AdapterType.wifiLightFan;
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
      "power": data!.funPower,
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
    return data!.funPower;
  }

  @override
  String? getCharacteristic() {
    return getWindSpeed();
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    if (value == null) {
      return;
    }
    int limitVal = value < 1 ? 1 : value > 100 ? 100 : value;
    return controlBrightness(limitVal, null);
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

  @override
  /// 查询状态
  Future<void> fetchData() async {
      dataState = DataState.LOADING;
      updateUI();
      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else if (platform.inHomlux()) {
        _homluxData = await fetchHomluxData();
      }
      if (_meijuData != null) {
        data = LightFunDataEntity.fromMeiJu(_meijuData!, sn8);
      } else if (_homluxData != null) {
        data = LightFunDataEntity.fromHomlux(_homluxData!);
      } else {
        dataState = DataState.ERROR;
        data = LightFunDataEntity(
          brightness: data!.brightness,
          colorTemp: data!.colorTemp,
          funPower: data!.funPower,
          fanScene: data!.fanScene,
          onlineState: data!.onlineState,
          ledPower:data!.ledPower,
          fanSpeed: data!.fanSpeed,
          arroundDir: data!.arroundDir,);
        updateUI();
        return;
      }
      dataState = DataState.SUCCESS;
      updateUI();
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

  Future<HomluxDeviceEntity?> fetchHomluxData() async {
    HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes =
        await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
    HomluxDeviceEntity? nodeInfo = nodeInfoRes.result;
    if (nodeInfo != null) {
      return nodeInfo;
    } else {
      return null;
    }
  }

  /// 控制风扇开关
  Future<void> controlPower() async {
    bus.emit('operateDevice', applianceCode);
    data!.funPower = !data!.funPower;
    updateUI();
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var command = {"fan_power": data!.funPower ? 'on' : 'off'};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.funPower = !data!.funPower;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制灯开关
  Future<void> controlLedPower() async {
    bus.emit('operateDevice', applianceCode);
    data!.ledPower = !data!.ledPower;
    updateUI();
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var command = {"led_power": data!.ledPower ? 'on' : 'off'};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.ledPower = !data!.ledPower;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制风扇正反转
  Future<void> controlArroundDir() async {
    bus.emit('operateDevice', applianceCode);
    data!.arroundDir = data!.arroundDir==1?0:1;
    updateUI();
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var command = {"arround_dir": data!.arroundDir==1 ? '1' : '0'};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.arroundDir = data!.arroundDir==1?1:0;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制风扇模式
  Future<void> controlMode(String mode) async {
    bus.emit('operateDevice', applianceCode);
    String lastModel = data!.fanScene;
    data!.fanScene = mode;
    updateUI();
    if (platform.inMeiju()) {
      var command = {"fan_scene": mode};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {

      } else {
        data!.fanScene = lastModel;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制风速
  Future<void> controlWindSpeed(num speed) async {
    bus.emit('operateDevice', applianceCode);
    int lastSpeed = data!.fanSpeed;
    String lastfanScene=data!.fanScene;
    int fanSpeed=1;
    if(speed==1){
      fanSpeed=1;
    }else if(speed==2){
      fanSpeed=21;
    }else if(speed==3){
      fanSpeed=41;
    }else if(speed==4){
      fanSpeed=61;
    }else if(speed==5){
      fanSpeed=81;
    }else if(speed==6){
      fanSpeed=100;
    }
    data!.fanSpeed=fanSpeed;
    data!.fanScene = "fanmanual";
    updateUI();
    if (platform.inMeiju()) {
      var command = {"fan_speed": fanSpeed};
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.fanSpeed = lastSpeed;
        data!.fanScene=lastfanScene;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    bus.emit('operateDevice', applianceCode);
    int lastBrightness = data!.brightness;
    data!.brightness = value.toInt();
    updateUI();
    if (platform.inMeiju()) {
      var command = {
        "brightness": int.parse((data!.brightness).toStringAsFixed(0))
      };
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x13',
        applianceCode: applianceCode,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    bus.emit('operateDevice', applianceCode);
    int lastColorTemp = data!.colorTemp;
    data!.colorTemp = value.toInt();
    updateUI();
    if (platform.inMeiju()) {
      var command = {
        "color_temperature": data!.colorTemp
      };
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x13',
          applianceCode: applianceCode,
          command: command);
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
        updateUI();
      }
    } else if (platform.inHomlux()) {

    }
  }

  String getWindSpeed() {
    if (data!.fanSpeed == 1) {
      return "1档";
    } else if (data!.fanSpeed == 21) {
      return "2档";
    } else if (data!.fanSpeed == 41) {
      return "3档";
    } else if (data!.fanSpeed == 61) {
      return "4档";
    } else if (data!.fanSpeed == 81) {
      return "5档";
    } else if (data!.fanSpeed == 100) {
      return "6档";
    } else {
      return "1档";
    }
  }

  Future<void> controlBrightnessFaker(num value, Color? activeColor) async {
    bus.emit('operateDevice', applianceCode);
    data!.brightness = value.toInt();
    updateUI();
  }

  Future<void> controlColorTemperatureFaker(num value, Color? activeColor) async {
    bus.emit('operateDevice', applianceCode);
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
