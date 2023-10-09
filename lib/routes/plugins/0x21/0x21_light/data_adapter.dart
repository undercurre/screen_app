import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/device_list_notifier.dart';

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
import '../../../../common/utils.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import 'api.dart';
import 'mode_list.dart';
import '../../../../common/models/endpoint.dart';

class DeviceDataEntity {
  int brightness = 1; // 亮度
  int? colorTemp = 0; // 色温
  bool power = false; //开关
  int delayClose = 0; //延时关
  int? maxColorTemp = 6500;
  int? minColorTemp = 2700;

  DeviceDataEntity({
    required brightness,
    colorTemp,
    required power,
    required delayClose,
  });

  DeviceDataEntity.fromMeiJu(NodeInfo<Endpoint<ZigbeeLightEvent>> data) {
    brightness = int.parse(data.endList[0].event.Level ?? '1');
    colorTemp = int.parse(data.endList[0].event.ColorTemp ?? '0');
    power = data.endList[0].event.OnOff == '1' || data.endList[0].event.OnOff == 1;
    delayClose = int.parse(data.endList[0].event.DelayClose);
  }

  DeviceDataEntity.fromHomlux(HomluxDeviceEntity data) {
    brightness = data.mzgdPropertyDTOList?.light?.brightness as int;
    colorTemp = data.mzgdPropertyDTOList?.light?.colorTemperature as int;
    power = data.mzgdPropertyDTOList!.light?.power == 1;
    delayClose = 0;
    maxColorTemp = data.mzgdPropertyDTOList!.light?.colorTempRange?.maxColorTemp ?? 6500;
    minColorTemp = data.mzgdPropertyDTOList!.light?.colorTempRange?.minColorTemp ?? 2700;
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'colorTemp': colorTemp,
      'power': power,
      'delayClose': delayClose,
    };
  }
}

class ZigbeeLightDataAdapter extends DeviceCardDataAdapter<DeviceDataEntity> {
  String deviceName = "Zigbee智能灯";
  String masterId = "";
  String applianceCode = "";
  String modelNumber = "";
  String nodeId = '';
  int controlLastTime = 0;

  NodeInfo<Endpoint<ZigbeeLightEvent>>? _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  DeviceDataEntity? data = DeviceDataEntity(
      brightness: 1, colorTemp: 0, power: false, delayClose: 0);

  final BuildContext context;

  Timer? delayTimer;

  ZigbeeLightDataAdapter(super.platform, this.context, this.masterId, this.applianceCode) {
    type = AdapterType.zigbeeLight;
    Log.develop('$hashCode construct');
  }

  @override
  void init() {
    _startPushListen();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "nodeId": StrUtils.isNotNullAndEmpty(nodeId) ? nodeId : null,
      "power": data!.power,
      "brightness": data!.brightness,
      "colorTemp": data!.colorTemp,
      "maxColorTemp": data!.maxColorTemp,
      "minColorTemp": data!.minColorTemp
    };
  }

  @override
  String? getDeviceId() {
    return applianceCode;
  }

  @override
  bool getPowerStatus() {
    Log.i('获取开关状态', data!.power);
    return data!.power;
  }

  @override
  String? getCharacteristic() {
    Log.i('获取$applianceCode特征状态', data!.brightness);
    return "${data!.brightness}%";
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
    Log.i('准备触发更新 $hashCode ${runtimeType}');
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
        _homluxData = await fetchHomluxData();
      }
      if (_meijuData != null) {
        data = DeviceDataEntity.fromMeiJu(_meijuData!);
      } else if (_homluxData != null) {
        data = DeviceDataEntity.fromHomlux(_homluxData!);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = DeviceDataEntity(
            brightness: 1, colorTemp: 0, power: false, delayClose: 0);
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

  Future<NodeInfo<Endpoint<ZigbeeLightEvent>>?> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<ZigbeeLightEvent>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<ZigbeeLightEvent>(applianceCode,
              masterId, (json) => ZigbeeLightEvent.fromJson(json));
      nodeId = nodeInfo.nodeId;
      return nodeInfo;
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
    Log.i('开关调用', data!.power);
    updateUI();
    controlLastTime = DateTime.now().millisecondsSinceEpoch;
    if (platform.inMeiju()) {
      /// todo: 可以优化类型限制
      var command = {
        "msgId": uuid.v4(),
        "deviceId": masterId,
        "nodeId": nodeId,
        "deviceControlList": [
          {"endPoint": 1, "attribute": data!.power ? 1 : 0}
        ]
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'subDeviceControl',
        applianceCode: masterId,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeLightOnOff(
          applianceCode, "2", masterId, data!.power ? 1 : 0);
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    }
    updateUI();
  }

  /// 控制延时关
  Future<void> controlDelay() async {
    int lastDelayClose = data!.delayClose;
    if (!data!.power) return;
    if (data!.delayClose == 0) {
      data!.delayClose = 3;
    } else {
      data!.delayClose = 0;
    }
    updateUI();
    controlLastTime = DateTime.now().millisecondsSinceEpoch;
    if (platform.inMeiju()) {
      var command = {
        "msgId": uuid.v4(),
        "deviceControlList": [
          {"endPoint": 1, "attribute": data!.delayClose}
        ],
        "deviceId": masterId,
        "nodeId": nodeId
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'lightDelayControl',
        applianceCode: masterId,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.delayClose = lastDelayClose;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeLightDelayOff(
          applianceCode, "2", masterId, data!.delayClose);
      if (res.isSuccess) {
      } else {
        data!.delayClose = lastDelayClose;
      }
    }
  }

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    int lastBrightness = data!.brightness;
    int? lastColorTemp = data!.colorTemp;
    var curMode = lightModes
        .where((element) => element.key == mode.key)
        .toList()[0] as ZigbeeLightMode;
    data!.brightness = curMode.brightness.toInt();
    data!.colorTemp = curMode.colorTemperature.toInt();
    updateUI();
    controlLastTime = DateTime.now().millisecondsSinceEpoch;
    if (platform.inMeiju()) {
      var command = {
        "brightness": data!.brightness,
        "msgId": uuid.v4(),
        "power": true,
        "deviceId": masterId,
        "nodeId": nodeId,
        "colorTemperature": data!.colorTemp,
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'lightControl',
        applianceCode: masterId,
        command: command,
      );
      if (res.isSuccess) {
        Log.i('lmn>>> controlMode success');
      } else {
        data!.brightness = lastBrightness;
        data!.colorTemp = lastColorTemp;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeColorTempAndBrightness(
          applianceCode,
          "2",
          masterId,
          curMode.colorTemperature.toInt(),
          curMode.brightness.toInt());

      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
        data!.colorTemp = lastColorTemp;
      }
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    int lastBrightness = data!.brightness;
    data!.brightness = value.toInt() < 1 ? 1 : value.toInt();
    updateUI();
    controlLastTime = DateTime.now().millisecondsSinceEpoch;
    if (platform.inMeiju()) {
      var command = {
        "brightness": data!.brightness,
        "msgId": uuid.v4(),
        "power": true,
        "deviceId": masterId,
        "nodeId": nodeId,
        "colorTemperature": data!.colorTemp,
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'lightControl',
        applianceCode: masterId,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeBrightness(
          applianceCode, "2", masterId, data!.brightness.toInt());
      if (res.isSuccess) {
      } else {
        data!.brightness = lastBrightness;
      }
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    int? lastColorTemp = data!.colorTemp;
    data!.colorTemp = value.toInt();
    updateUI();
    controlLastTime = DateTime.now().millisecondsSinceEpoch;
    if (platform.inMeiju()) {
      var command = {
        "brightness": data!.brightness,
        "msgId": uuid.v4(),
        "power": true,
        "deviceId": masterId,
        "nodeId": nodeId,
        "colorTemperature": data!.colorTemp,
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'lightControl',
        applianceCode: masterId,
        command: command,
      );
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeColorTemp(
          applianceCode, "2", masterId, data!.colorTemp!.toInt());
      if (res.isSuccess) {
      } else {
        data!.colorTemp = lastColorTemp;
      }
    }
  }

  Future<void> controlBrightnessFaker(num value, Color? activeColor) async {
    data!.brightness = value.toInt() < 1 ? 1 : value.toInt();
    updateUI();
  }

  Future<void> controlColorTemperatureFaker(num value, Color? activeColor) async {
    data!.colorTemp = value.toInt();
    updateUI();
  }

  void homluxPush(HomluxDevicePropertyChangeEvent event) {
    Log.file('接收到推送，即将请求设备状态 $this');
    if (event.deviceInfo.eventData?.deviceId == masterId || event.deviceInfo.eventData?.deviceId == applianceCode) {
      _throttledFetchData();
    }
  }

  void homluxMovePush(HomluxMovSubDeviceEvent event) {
    if (event.deviceInfo.eventData?.deviceId == masterId || event.deviceInfo.eventData?.deviceId == applianceCode) {
      context.read<DeviceInfoListModel>().getDeviceList();
    }
  }

  void homluxOfflinePush(HomluxDeviceOnlineStatusChangeEvent event) {
    if (event.deviceInfo.eventData?.deviceId == masterId || event.deviceInfo.eventData?.deviceId == applianceCode) {
      context.read<DeviceInfoListModel>().getDeviceList();
    }
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    Log.file('$applianceCode接收到推送，即将请求设备状态 MeiJuSubDevicePropertyChangeEvent ${args.nodeId}');
    if (args.nodeId == nodeId) {
      _throttledFetchData();
    }
  }

  void meijuPushOnline(MeiJuDeviceOnlineStatusChangeEvent args) {
    Log.file('$applianceCode接收到推送，即将请求设备状态 MeiJuDeviceOnlineStatusChangeEvent ${args.deviceId}');
    if (args.deviceId == masterId) {
      context.read<DeviceInfoListModel>().getDeviceList();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush, this);
      bus.typeOn<HomluxMovSubDeviceEvent>(homluxMovePush, this);
      bus.typeOn<HomluxDeviceOnlineStatusChangeEvent>(homluxOfflinePush, this);
      Log.develop('$hashCode bind');
    } else {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush, this);
      bus.typeOn<MeiJuDeviceOnlineStatusChangeEvent>(meijuPushOnline, this);
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush, this);
      bus.typeOff<HomluxMovSubDeviceEvent>(homluxMovePush, this);
      bus.typeOff<HomluxDeviceOnlineStatusChangeEvent>(homluxOfflinePush, this);
      Log.develop('$hashCode unbind');
    } else {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush, this);
      bus.typeOff<MeiJuDeviceOnlineStatusChangeEvent>(meijuPushOnline, this);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }
}

class ZigbeeLightEvent extends Event {
  dynamic OnOff = '0';
  dynamic DelayClose = '0';
  dynamic Level = '1';
  dynamic ColorTemp = '0';
  dynamic duration = 3;

  ZigbeeLightEvent(
      {required this.OnOff,
      required this.DelayClose,
      required this.Level,
      this.ColorTemp,
      this.duration});

  factory ZigbeeLightEvent.fromJson(Map<String, dynamic> json) {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return ZigbeeLightEvent(
        OnOff: json['OnOff'],
        DelayClose: json['DelayClose'],
        Level: json['Level'],
        ColorTemp: json['ColorTemp'],
        duration: json['duration'], // 可能不存在的键
      );
    } else {
      return ZigbeeLightEvent(
        OnOff: json['OnOff'],
        DelayClose: json['DelayClose'],
        Level: json['Level'],
        ColorTemp: json['ColorTemp'],
        duration: json['duration'], // 可能不存在的键
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
