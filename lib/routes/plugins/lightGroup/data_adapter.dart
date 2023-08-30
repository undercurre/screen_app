import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:screen_app/common/homlux/models/homlux_group_entity.dart';

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
import '../../../../common/models/node_info.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../../common/api/device_api.dart';
import '../../../common/meiju/meiju_global.dart';
import 'api.dart';
import '../../../../common/models/endpoint.dart';

class GroupDataEntity {
  int brightness = 1; // 亮度
  int colorTemp = 0; // 色温
  bool power = false; //开关

  GroupDataEntity({
    required brightness,
    required colorTemp,
    required power,
  });

  GroupDataEntity.fromMeiJu(dynamic data) {
    brightness = int.parse(data["brightness"]);
    colorTemp = int.parse(data["colorTemperature"]);
    power = data["switchStatus"] == '1';
  }

  GroupDataEntity.fromHomlux(HomluxGroupEntity data) {
    brightness = data!.controlAction?[0].brightness as int;
    colorTemp = data!.controlAction?[0].colorTemperature as int;
    power = data!.controlAction?[0].power == 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'colorTemp': colorTemp,
      'power': power,
    };
  }
}

class LightGroupDataAdapter extends DeviceCardDataAdapter<GroupDataEntity> {
  String deviceName = "灯光分组";
  String masterId = "";
  String applianceCode = "";
  String modelNumber = "";
  String nodeId = '';

  bool _isFetching = false;
  Timer? _debounceTimer;

  dynamic _meijuData = null;
  HomluxGroupEntity? _homluxData = null;

  GroupDataEntity? data =
      GroupDataEntity(brightness: 0, colorTemp: 0, power: false);

  final BuildContext context;

  Timer? delayTimer;

  LightGroupDataAdapter(
      super.platform, this.context, this.masterId, this.applianceCode) {
    type = AdapterType.lightGroup;
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
      "brightness": data!.brightness,
      "colorTemp": data!.colorTemp
    };
  }

  @override
  bool getPowerStatus() {
    Log.i('获取开关状态', data!.power);
    return data!.power;
  }

  @override
  String? getCharacteristic() {
    Log.i('获取特征状态', data!.brightness);
    return "${data!.brightness}%";
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
  Future<dynamic> slider2To(int? value) async {
    return controlColorTemperature(value as num, null);
  }

  /// 防抖刷新
  void _throttledFetchData() async {
    if (!_isFetching) {
      _isFetching = true;

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      _debounceTimer = Timer(Duration(milliseconds: 500), () async {
        Log.i('触发更新');
        await fetchData();
        _isFetching = false;
      });
    }
  }

  /// 查询状态
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;
      updateUI();
      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else if (platform.inHomlux()) {
        _homluxData = await fetchHomluxData();
      }
      if (_meijuData != null) {
        data = GroupDataEntity.fromMeiJu(_meijuData!);
      } else if (_homluxData != null) {
        data = GroupDataEntity.fromHomlux(_homluxData!);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = GroupDataEntity(brightness: 0, colorTemp: 0, power: false);
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
      var res = await DeviceApi.groupRelated(
          'findLampGroupDetails',
          const JsonEncoder().convert({
            "houseId": MeiJuGlobal.homeInfo?.homegroupId,
            "groupId": applianceCode,
            "modelId": "midea.light.003.001",
            "uid": MeiJuGlobal.token?.uid,
          }));
      return res.result["result"]["group"];
    } catch (e) {
      Log.i('getNodeInfo Error', e);
      dataState = DataState.ERROR;
      updateUI();
      return null;
    }
  }

  Future<HomluxGroupEntity> fetchHomluxData() async {
    HomluxResponseEntity<HomluxGroupEntity> nodeInfoRes =
        await HomluxDeviceApi.queryGroupByGroupId(applianceCode);
    HomluxGroupEntity? nodeInfo = nodeInfoRes.result;
    if (nodeInfo != null) {
      return nodeInfo;
    } else {
      return HomluxGroupEntity();
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    data!.power = !data!.power;
    updateUI();
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var res = await DeviceApi.groupRelated(
        'lampGroupControl',
        const JsonEncoder().convert({
          "houseId": MeiJuGlobal.homeInfo?.homegroupId,
          "groupId": applianceCode,
          "modelId": "midea.light.003.001",
          "lampAttribute": '0',
          "lampAttributeValue": data!.power ? '1' : '0',
          "transientTime": '0',
          "uid": MeiJuGlobal.token?.uid,
        }),
      );
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightOnOff(
          applianceCode, data!.power ? 1 : 0);
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    }
    updateUI();
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    int lastBrightness = data!.brightness;
    data!.brightness = value.toInt();
    updateUI();

    if (platform.inMeiju()) {
      var res = await DeviceApi.groupRelated(
        'lampGroupControl',
        const JsonEncoder().convert({
          "houseId": MeiJuGlobal.homeInfo?.homegroupId,
          "groupId": applianceCode,
          "modelId": "midea.light.003.001",
          "lampAttribute": '1',
          "lampAttributeValue": value.toString(),
          "transientTime": '0',
          "uid": MeiJuGlobal.token?.uid,
        }),
      );
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightBrightness(applianceCode, value.toInt());
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
      var res = await DeviceApi.groupRelated(
          'lampGroupControl',
          const JsonEncoder().convert({
            "houseId": MeiJuGlobal.homeInfo?.homegroupId,
            "groupId": applianceCode,
            "modelId": "midea.light.003.001",
            "lampAttribute": '2',
            "lampAttributeValue": value.toString(),
            "transientTime": '0',
            "uid": MeiJuGlobal.token?.uid,
          }));

      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightColorTemp(applianceCode, value.toInt());
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    }
  }

  void statusChangePushHomlux(HomluxDevicePropertyChangeEvent event) {
    if (event.deviceInfo.eventData?.deviceId == masterId) {
      fetchData();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>((arg) {
        if (arg.deviceInfo.eventData?.deviceId == applianceCode) {
          _throttledFetchData();
        }
      });
    } else {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>((args) {
        if (args.nodeId == nodeId) {
          _throttledFetchData();
        }
      });
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff(statusChangePushHomlux);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }
}

class ZigbeeLightEvent extends Event {
  String OnOff = '0';
  String DelayClose = '0';
  String Level = '0';
  String ColorTemp = '0';
  int duration = 3;

  ZigbeeLightEvent(
      {required this.OnOff,
      required this.DelayClose,
      required this.Level,
      required this.ColorTemp,
      required this.duration});

  factory ZigbeeLightEvent.fromJson(Map<String, dynamic> json) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return ZigbeeLightEvent(
        OnOff: json['OnOff'] as String,
        DelayClose: json['DelayClose'] as String,
        Level: json['Level'] as String,
        ColorTemp: json['ColorTemp'] as String,
        duration: json['duration'] as int, // 可能不存在的键
      );
    } else {
      return ZigbeeLightEvent(
        OnOff: json['OnOff'] as String,
        DelayClose: json['DelayClose'] as String,
        Level: json['Level'] as String,
        ColorTemp: json['ColorTemp'] as String,
        duration: json['duration'] as int, // 可能不存在的键
      );
    }
  }

  Map<String, dynamic> toJson() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return {
        'OnOff': OnOff,
        'DelayClose': DelayClose,
        'Level': Level,
        'ColorTemp': ColorTemp,
        'duration': duration
      };
    } else {
      return {
        'OnOff': OnOff,
        'DelayClose': DelayClose,
        'Level': Level,
        'ColorTemp': ColorTemp,
        'duration': duration
      };
    }
  }
}
