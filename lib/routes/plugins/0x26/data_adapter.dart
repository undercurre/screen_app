import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:screen_app/widgets/util/mode.dart';

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
  String heating_temp = '50';
  List<String> huchi = ['bath', 'blowing', 'heating', 'drying'];
  String gongcun = 'ventilation';

  YubaDataEntity({
    required mode,
    required light_mode,
    required delay_enable,
  });

  YubaDataEntity.fromMeiJu(dynamic data, String sn8) {
    mode = data["mode"];
    light_mode = data["light_mode"];
    delay_enable = data["delay_enable"];
    heating_temp = data["heating_temperature"] ?? '42';
  }

  YubaDataEntity.fromHomlux(HomluxDeviceEntity data) {
    mode = data.mzgdPropertyDTOList?.bathHeat?.mode ?? 'close_all';
    light_mode = data.mzgdPropertyDTOList?.bathHeat?.lightMode ?? 'close_all';
    delay_enable = data.mzgdPropertyDTOList?.bathHeat?.delayEnable ?? 'off';
    heating_temp = data.mzgdPropertyDTOList?.bathHeat?.heatingTemperature ?? '42';
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
    var lastMode = data!.mode;
    data!.mode = 'close_all';
    updateUI();
    var modeRes;
    if (platform.inMeiju()) {
      modeRes = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x26', applianceCode: applianceCode, command: {'mode_close': 'close_all'});
    } else {
      modeRes = await HomluxDeviceApi.controlWifiYubaModeOff(applianceCode, "3", 'close_all');
    }
    if (modeRes.isSuccess) {} else {
      data!.mode = lastMode;
    }
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
  Future<void> modeControl(int index) async {
    /// 1-3都是enable_mode指令
    if (index >= 1 && index <= 3) {
      Map<int, String> modes = {1: 'heating', 2: 'blowing', 3: 'ventilation'};
      if (modes[index] != null) controlMode(modes[index]!);
    } else {
      /// 4是main_light指令
      controlLightMode('main_light');
    }
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
      return nodeInfo;
    } else {
      return HomluxDeviceEntity();
    }
  }

  /// 控制延时关
  Future<void> controlDelay() async {
    String lastDelay = data!.delay_enable;
    data!.delay_enable = lastDelay == 'on' ? 'off' : 'on';
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x26', applianceCode: applianceCode, command: {'delay_enable': 'on', 'delay_time': '50'});
      if (res.isSuccess) {} else {
        data!.delay_enable = lastDelay;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res = await HomluxDeviceApi.controlWifiYubaDelay(applianceCode, "3", data!.delay_enable, "50");

      if (res.isSuccess) {} else {
        data!.delay_enable = lastDelay;
      }
    }
  }

  /// 控制模式
  Future<void> controlMode(String mode) async {
    bus.emit('operateDevice', applianceCode);
    String lastModel = data!.mode;
    if (data!.mode.contains(mode)) {
      data!.mode = data!.mode.replaceAll('$mode,', '');
      data!.mode = data!.mode.replaceAll(mode, '');
      if (data!.mode.isEmpty) {
        data!.mode = 'close_all';
      }
    } else {
      if (data!.mode == 'close_all') {
        data!.mode = mode;
      } else {
        data!.mode += ',$mode';
        List<String> lastHuChiList = ModeFilter.removeString(lastModel.split(',').map((e) => e.trim()).toList(), data!.gongcun);
        Log.i(lastHuChiList, data!.huchi.contains(lastHuChiList[0]) && data!.huchi.contains(mode));
        if (data!.huchi.contains(lastHuChiList[0]) && data!.huchi.contains(mode)) {
          data!.mode = data!.mode.replaceAll('${lastHuChiList[0]},', '');
          data!.mode = data!.mode.replaceAll(lastHuChiList[0], '');
        }
      }
    }
    Log.i('模式操控', data!.mode);
    updateUI();
    if (platform.inMeiju()) {
      var res;
      if (lastModel.contains(mode)) {
        res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x26', applianceCode: applianceCode, command: {
          'mode_close': mode,
        });
      } else {
        res = await MeiJuDeviceApi.sendLuaOrder(
            categoryCode: '0x26', applianceCode: applianceCode, command: {'mode_enable': mode, 'heating_temperature': "55"});
      }
      if (res.isSuccess) {} else {
        data!.mode = lastModel;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res;
      if (lastModel.contains(mode)) {
        res = await HomluxDeviceApi.controlWifiYubaModeOff(applianceCode, "3", mode);
      } else {
        res = await HomluxDeviceApi.controlWifiYubaModeOn(applianceCode, "3", mode, "55");

        if (res.isSuccess) {} else {
          data!.mode = lastModel;
        }
      }
    }
  }

  /// 控制灯光
  Future<void> controlLightMode(String mode) async {
    bus.emit('operateDevice', applianceCode);
    String lastLightModel = data!.light_mode;
    if (lastLightModel == mode) {
      data!.light_mode = 'close_all';
    } else {
      data!.light_mode = mode;
    }
    updateUI();
    if (platform.inMeiju()) {
      var res =
      await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x26', applianceCode: applianceCode, command: {'light_mode': data!.light_mode});
      if (res.isSuccess) {} else {
        data!.light_mode = lastLightModel;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res = await HomluxDeviceApi.controlWifiYubaLightMode(applianceCode, "3", data!.light_mode);
      if (res.isSuccess) {} else {
        data!.light_mode = lastLightModel;
      }
    }
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