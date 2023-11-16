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

class YubaDataEntity {
  String mode = 'close_all';
  String light_mode = 'close_all';
  String delay_enable = 'off';

  YubaDataEntity({
    required mode,
    required light_mode,
    required delay_enable,
  });

  YubaDataEntity.fromMeiJu(dynamic data, String sn8) {
    mode = data["mode"];
    light_mode = data["light_mode"];
    delay_enable = data["delay_enable"];
  }

  YubaDataEntity.fromHomlux(HomluxDeviceEntity data) {
    mode = 'close_all';
    light_mode = 'close_all';
    delay_enable = 'off';
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'light_mode': light_mode,
      'delay_enable': delay_enable,
    };
  }
}

class WIFIYubaDataAdapter extends DeviceCardDataAdapter<YubaDataEntity> {
  String deviceName = "智能浴霸";
  String sn8 = "";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  YubaDataEntity? data = YubaDataEntity(mode: 'close_all', light_mode: 'close_all', delay_enable: 'off');

  WIFIYubaDataAdapter(super.platform, this.sn8, this.applianceCode) {
    Log.i('获取到当前浴霸的sn8', this.sn8);
    type = AdapterType.wifiYuba;
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
      MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>> res = await MeiJuDeviceApi.queryDeviceListByHomeId(MeiJuGlobal.token!.uid, id);
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
    return {"mode": data!.mode, "light_mode": data!.light_mode, "delay_enable": data!.delay_enable};
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  bool getPowerStatus() {
    return data!.mode != 'close_all' || data!.light_mode != 'close_all';
  }

  @override
  String? getCharacteristic() {
    return "${data!.mode}";
  }

  @override
  Future<void> power(bool? onOff) async {
    // return controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    if (value == null) {
      return;
    }
    int limitVal = value < 1
        ? 1
        : value > 100
            ? 100
            : value;
    // return controlBrightness(limitVal, null);
  }

  @override
  Future<dynamic> slider1ToFaker(int? value) async {
    // return controlBrightnessFaker(value as num, null);
  }

  @override
  Future<dynamic> slider2To(int? value) async {
    // return controlColorTemperature(value as num, null);
  }

  @override
  Future<dynamic> slider2ToFaker(int? value) async {
    // return controlColorTemperatureFaker(value as num, null);
  }

  /// 防抖刷新
  void _throttledFetchData() {
    fetchData();
  }

  @override
  Future<void> tryOnce() async {
    // controlPower();
  }

  @override
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
      data = YubaDataEntity.fromMeiJu(_meijuData!, sn8);
    } else if (_homluxData != null) {
      data = YubaDataEntity.fromHomlux(_homluxData!);
    } else {
      dataState = DataState.ERROR;
      data = YubaDataEntity(mode: 'close_all', light_mode: 'close_all', delay_enable: 'off');
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
      var nodeInfo = await MeiJuDeviceApi.getDeviceDetail('0x26', applianceCode);
      return nodeInfo.data;
    } catch (e) {
      Log.i('getNodeInfo Error', e);
      dataState = DataState.ERROR;
      updateUI();
      return null;
    }
  }

  Future<HomluxDeviceEntity> fetchHomluxData() async {
    HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes = await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
    HomluxDeviceEntity? nodeInfo = nodeInfoRes.result;
    if (nodeInfo != null) {
      Log.i('浴霸数据', nodeInfo);
      return nodeInfo;
    } else {
      return HomluxDeviceEntity();
    }
  }

  /// 控制开关
  // Future<void> controlPower() async {
  //   // data!.power = !data!.power;
  //   updateUI();
  //   if (platform.inMeiju()) {
  //     /// todo: 可以优化类型限制
  //     // var command = {"power": data!.power ? 'on' : 'off'};
  //     var res = await MeiJuDeviceApi.sendLuaOrder(
  //       categoryCode: '0x26',
  //       applianceCode: applianceCode,
  //       command: {},
  //     );
  //     if (res.isSuccess) {
  //     } else {
  //       // data!.power = !data!.power;
  //     }
  //   } else if (platform.inHomlux()) {
  //     var res = await HomluxDeviceApi.controlWifiLightOnOff(applianceCode, "3", data!.power ? 1 : 0);
  //     if (res.isSuccess) {
  //     } else {
  //       // data!.power = !data!.power;
  //       updateUI();
  //     }
  //   }
  //   updateUI();
  // }

  /// 控制延时关
  // Future<void> controlDelay() async {
  //   int lastTimeOff = data!.timeOff;
  //   if (!data!.power) return;
  //   if (data!.timeOff == 0) {
  //     data!.timeOff = 3;
  //   } else {
  //     data!.timeOff = 0;
  //   }
  //   updateUI();
  //   if (platform.inMeiju()) {
  //     var res;
  //     if (sn8.isNotEmpty && sn8 == '79009833') {
  //       var command = {"timeOff": data!.timeOff};
  //       res = await MeiJuDeviceApi.sendPDMControlOrder(
  //           categoryCode: '0x26', uri: 'setTimeOff', applianceCode: applianceCode, command: command);
  //     } else {
  //       var command = {"delay_light_off": data!.timeOff};
  //       res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x26', applianceCode: applianceCode, command: command);
  //     }
  //     if (res.isSuccess) {
  //     } else {
  //       data!.timeOff = lastTimeOff;
  //     }
  //   } else if (platform.inHomlux()) {
  //     var res = await HomluxDeviceApi.controlWifiLightDelayOff(applianceCode, "3", data!.timeOff);
  //     if (res.isSuccess) {
  //     } else {
  //       data!.timeOff = lastTimeOff;
  //     }
  //   }
  // }

  /// 控制模式
  // Future<void> controlMode(Mode mode) async {
  //   String lastModel = data!.screenModel;
  //   data!.screenModel = mode.key;
  //   updateUI();
  //   if (platform.inMeiju()) {
  //     var res;
  //     if (sn8.isNotEmpty && sn8 == '79009833') {
  //       var command = {"dimTime": 0, "screenModel": mode.key};
  //       res = await MeiJuDeviceApi.sendPDMControlOrder(
  //         categoryCode: '0x26',
  //         uri: 'controlScreenModel',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     } else {
  //       var command = {"scene_light": mode.key};
  //       res = await MeiJuDeviceApi.sendLuaOrder(
  //         categoryCode: '0x26',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     }
  //     if (res.isSuccess) {
  //     } else {
  //       data!.screenModel = lastModel;
  //     }
  //   } else if (platform.inHomlux()) {
  //     var res = await HomluxDeviceApi.controlWifiLightMode(applianceCode, "3", mode.key);
  //
  //     if (res.isSuccess) {
  //     } else {
  //       data!.screenModel = lastModel;
  //     }
  //   }
  // }

  /// 控制亮度
  // Future<void> controlBrightness(num value, Color? activeColor) async {
  //   int lastBrightness = data!.brightness;
  //   data!.brightness = value.toInt();
  //   updateUI();
  //
  //   if (platform.inMeiju()) {
  //     var res;
  //     if (sn8.isNotEmpty && sn8 == '79009833') {
  //       var command = {"dimTime": 0, "brightValue": int.parse((data!.brightness / 100 * 255).toStringAsFixed(0))};
  //       res = await MeiJuDeviceApi.sendPDMControlOrder(
  //         categoryCode: '0x26',
  //         uri: 'controlBrightValue',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     } else if (sn8.isNotEmpty && sn8 == '79010914') {
  //       var command = {"brightness": int.parse((data!.brightness / 100 * 255).toStringAsFixed(0))};
  //       res = await MeiJuDeviceApi.sendLuaOrder(
  //         categoryCode: '0x26',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     } else {
  //       var command = {"brightness": data!.brightness};
  //       res = await MeiJuDeviceApi.sendLuaOrder(
  //         categoryCode: '0x26',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     }
  //     if (res.isSuccess) {
  //     } else {
  //       data!.brightness = lastBrightness;
  //     }
  //   } else if (platform.inHomlux()) {
  //     var res = await HomluxDeviceApi.controlWifiLightBrightness(applianceCode, "3", value.toInt());
  //     if (res.isSuccess) {
  //     } else {
  //       data!.brightness = lastBrightness;
  //     }
  //   }
  // }

  /// 控制色温
  // Future<void> controlColorTemperature(num value, Color? activeColor) async {
  //   int lastColorTemp = data!.colorTemp;
  //   data!.colorTemp = value.toInt();
  //   updateUI();
  //   if (platform.inMeiju()) {
  //     var res;
  //     if (sn8.isNotEmpty && sn8 == '79009833') {
  //       var command = {
  //         "dimTime": 0,
  //         "colorTemperatureValue": int.parse(
  //           (data!.colorTemp / 100 * 255).toStringAsFixed(0),
  //         )
  //       };
  //       res = await MeiJuDeviceApi.sendPDMControlOrder(
  //         categoryCode: '0x26',
  //         uri: 'controlColorTemperatureValue',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     } else if (sn8.isNotEmpty && sn8 == '79010914') {
  //       var command = {"color_temperature": int.parse((data!.colorTemp / 100 * 255).toStringAsFixed(0))};
  //       res = await MeiJuDeviceApi.sendLuaOrder(
  //         categoryCode: '0x26',
  //         applianceCode: applianceCode,
  //         command: command,
  //       );
  //     } else {
  //       var command = {"color_temperature": data!.colorTemp};
  //       res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x26', applianceCode: applianceCode, command: command);
  //     }
  //     if (res.isSuccess) {
  //     } else {
  //       data!.colorTemp = lastColorTemp;
  //     }
  //   } else if (platform.inHomlux()) {
  //     var res = await HomluxDeviceApi.controlWifiLightColorTemp(applianceCode, "3", value.toInt());
  //     if (res.isSuccess) {
  //     } else {
  //       data!.colorTemp = lastColorTemp;
  //     }
  //   }
  // }

  // Future<void> controlBrightnessFaker(num value, Color? activeColor) async {
  //   data!.brightness = value.toInt();
  //   updateUI();
  // }
  //
  // Future<void> controlColorTemperatureFaker(num value, Color? activeColor) async {
  //   data!.colorTemp = value.toInt();
  //   updateUI();
  // }
  //
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
