import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
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

class LiangyiDataEntity {
  String updown = 'pause';
  String light = 'off';
  String laundry = 'off';
  String location_status = 'normal';
  int custom_height = 0;

  LiangyiDataEntity({
    required updown,
    required light,
    required laundry,
    required location_status,
    required custom_height
  });

  LiangyiDataEntity.fromMeiJu(dynamic data, String sn8) {
    updown = data["updown"];
    light = data["light"];
    laundry = data["laundry"];
    location_status = data["location_status"];
    custom_height = data["custom_height"];
  }

  LiangyiDataEntity.fromHomlux(HomluxDeviceEntity data) {
    updown = data.mzgdPropertyDTOList?.clothesDryingRack?.updown ?? 'pause';
    light = data.mzgdPropertyDTOList?.clothesDryingRack?.light ?? 'off';
    laundry = data.mzgdPropertyDTOList?.clothesDryingRack?.laundry ?? 'off';
    location_status = data.mzgdPropertyDTOList?.clothesDryingRack?.locationStatus ?? 'normal';
    custom_height = data.mzgdPropertyDTOList?.clothesDryingRack?.customHeight ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'updown': updown,
      'light': light,
      'laundry': laundry,
      'location_status': location_status
    };
  }
}

class WIFILiangyiDataAdapter extends DeviceCardDataAdapter<LiangyiDataEntity> {
  String deviceName = "智能晾衣架";
  String sn8 = "";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  LiangyiDataEntity? data = LiangyiDataEntity(updown: 'pause', light: 'off', laundry: 'off', location_status: 'normal', custom_height: 0);

  WIFILiangyiDataAdapter(super.platform, this.sn8, this.applianceCode) {
    Log.i('获取到当前晾衣架的sn8', this.sn8);
    type = AdapterType.wifiLiangyi;
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
    return {"updown": data!.updown, "light": data!.light, "laundry": data!.laundry};
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  bool getPowerStatus() {
    return false;
  }

  @override
  String? getCharacteristic() {
    return "${data!.updown}";
  }

  @override
  Future<void> power(bool? onOff) async {

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
    /// 1是一键晾衣
    if (index == 1) {
      controlLaundry();
    } else if (index == 2) {
      /// 2是照明
      controlLightMode();
    } else {
      /// 3-5是升停降
      Map<int, String> modes = {3: 'up', 4: 'pause', 5: 'down'};
      if (modes[index] != null) controlUpdown(modes[index]!);
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
      data = LiangyiDataEntity.fromMeiJu(_meijuData!, sn8);
    } else if (_homluxData != null) {
      data = LiangyiDataEntity.fromHomlux(_homluxData!);
    } else {
      dataState = DataState.ERROR;
      data = LiangyiDataEntity(updown: 'pause', light: 'off', laundry: 'off', location_status: 'normal', custom_height: 0);
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
      var nodeInfo = await MeiJuDeviceApi.getDeviceDetail('0x17', applianceCode);
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
      Log.i('晾衣架数据', nodeInfo);
      return nodeInfo;
    } else {
      return HomluxDeviceEntity();
    }
  }

  /// 控制升降
  Future<void> controlUpdown(String target) async {
    bus.emit('operateDevice', applianceCode);
    if (data!.location_status == 'upper_limit' && target == 'up') {
      TipsUtils.toast(content: '已达到最高点');
      return;
    }
    if (data!.location_status == 'lower_limit' && target == 'down') {
      TipsUtils.toast(content: '已达到最低点');
      return;
    }
    String lastModel = data!.updown;
    data!.updown = target;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x17', applianceCode: applianceCode, command: {
        'updown': data!.updown
      });
      if (res.isSuccess) {
      } else {
        data!.light = lastModel;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res = await HomluxDeviceApi.controlWifiLiangyiUpdown(applianceCode, target);
      if (res.isSuccess) {
      } else {
        data!.light = lastModel;
      }
    }
  }

  /// 控制一键晾衣
  Future<void> controlLaundry() async {
    bus.emit('operateDevice', applianceCode);
    if (data!.custom_height == 0) {
      TipsUtils.toast(content: '请先设置好一键晾衣高度');
      return;
    }
    String lastLaundryModel = data!.laundry;
    data!.laundry = data!.laundry != 'on' ? 'on' : 'off';
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x17', applianceCode: applianceCode, command: {
        'laundry': data!.laundry
      });
      if (res.isSuccess) {
      } else {
        data!.laundry = lastLaundryModel;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res = await HomluxDeviceApi.controlWifiLiangyiLaundry(applianceCode, data!.laundry);
      if (res.isSuccess) {
      } else {
        data!.laundry = lastLaundryModel;
      }
    }
  }

  /// 控制灯光
  Future<void> controlLightMode() async {
    bus.emit('operateDevice', applianceCode);
    String lastLightModel = data!.light;
    data!.light = data!.light != 'on' ? 'on' : 'off';
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(categoryCode: '0x17', applianceCode: applianceCode, command: {
        'light': data!.light
      });
      if (res.isSuccess) {
      } else {
        data!.light = lastLightModel;
      }
    } else if (platform.inHomlux()) {
      HomluxResponseEntity<dynamic> res = await HomluxDeviceApi.controlWifiLiangyiLight(applianceCode, data!.light);
      if (res.isSuccess) {
      } else {
        data!.light = lastLightModel;
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
