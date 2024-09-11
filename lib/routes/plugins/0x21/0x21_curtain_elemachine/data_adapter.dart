import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/meiju/api/meiju_device_api.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../0x14/mode_list.dart';

class CurtainDataEntity {
  int curtainPosition = 0;
  String curtainStatus = 'stop';
  String curtainDirection = 'positive';
  int onlineState = 0;

  CurtainDataEntity({
    required this.curtainPosition,
    required this.curtainDirection,
    required this.curtainStatus,
    required this.onlineState
  });

  CurtainDataEntity.defaultState();

  CurtainDataEntity.fromMeiJu(NodeInfo<Endpoint<_ZigbeeEleMachineCurtainEvent>>? data) {
    if(data != null) {
      Log.i("窗帘数据：${jsonEncode(data.endList[0].event.toJson())}");
      curtainPosition = data.endList[0].event.movePercentage;
      curtainStatus = data.endList[0].event.curtainState == 0x00 ?
      "stop" : data.endList[0].event.curtainState == 0x01 ? "open" : "close";
      curtainDirection = data.endList[0].event.motorDirection == 0x00 ? "positive" : "negative";
    }
  }

  int getCurtainPosition(dynamic data){
    if(data.containsKey("curtain_position")){
      return int.parse(data['curtain_position']);
    }else{
      return 0;
    }

  }

  CurtainDataEntity.fromHomlux(HomluxDeviceEntity data) {
    curtainPosition = int.parse(data.mzgdPropertyDTOList?.curtain?.curtainPosition ?? "0");
    curtainStatus = data.mzgdPropertyDTOList?.curtain?.curtainStatus ?? "stop";
    curtainDirection = data.mzgdPropertyDTOList?.curtain?.curtainDirection ?? "positive";
    onlineState = data.onLineStatus ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'curtainPosition': curtainPosition,
      'curtainStatus': curtainStatus,
      'curtainDirection': curtainDirection,
    };
  }
}

class _ZigbeeEleMachineCurtainEvent extends Event {
  // 0-100， 255:未校准
  late int movePercentage;
  // 0:正，1：反
  late int motorDirection;
  // 0x0：开，0x1：关，0x2：停，0xFB：校准行程，0xFC：删除行程
  late int curtainCtrl;
  // 0x0: 停，0x1：开，0x2：关，0x3：异常
  late int curtainState;

  _ZigbeeEleMachineCurtainEvent.fromJson(Map<String, dynamic> json) {
    movePercentage = max(0, min(int.parse(json['movePercentage'] as String), 100));
    curtainCtrl = json['curtainCtrl'] as int;
    motorDirection = int.parse(json['motorDirection'] as String);
    curtainState = int.parse(json['curtainState'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'movePercentage': movePercentage,
      'motorDirection': motorDirection,
      'curtainCtrl': curtainCtrl,
      'curtainState': curtainState
    };
  }

}

class ZigbeeEleMachineCurtainDataAdapter extends DeviceCardDataAdapter<CurtainDataEntity> {

  String deviceName = 'zigbee窗帘';

  final String applianceCode;

  final String masterId;

  Timer? delayTimer;

  NodeInfo<Endpoint<_ZigbeeEleMachineCurtainEvent>>? _meijuData = null;

  ZigbeeEleMachineCurtainDataAdapter(super.platform, this.applianceCode, this.masterId) {
    data = CurtainDataEntity.defaultState();
  }

  @override
  void init() {
    super.init();
    _startPushListen();
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

  // 开发、关闭
  @override
  Future power(bool? onOff) {
    var openMode = Mode(
        'open',
        '全开',
        'assets/imgs/plugins/0x14/all-open-on.png',
        'assets/imgs/plugins/0x14/all-open-off.png');
    var closeMode = Mode(
        'close',
        '全关',
        'assets/imgs/plugins/0x14/all-close-on.png',
        'assets/imgs/plugins/0x14/all-close-off.png');
    if (data!.curtainPosition > 0) {
      // 关
      return controlMode(closeMode);
    }
    // 开
    return controlMode(openMode);
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent arg) {
    if (arg.nodeId == _meijuData?.nodeId) {
      Log.i("窗帘接收到设备推送！！！");
      fetchData();
    }
  }

  void _startPushListen() {
    if(MideaRuntimePlatform.inMeiJu()) {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if(MideaRuntimePlatform.inMeiJu()) {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  Future<void> controlMode(Mode mode) async {
    String lastModel = data!.curtainStatus;
    data!.curtainStatus = mode.key;
    if (mode.key == 'open') {
      data!.curtainPosition = 100;
    } else if (mode.key == 'close') {
      data!.curtainPosition = 0;
    }
    var ctr = mode.key == 'open' ? 0 : mode.key == 'close' ? 1 : 2;
    updateUI();
    // delayFetchData();
    var command = {
      "msgId": uuid.v4(),
      "deviceId": masterId,
      "actionType": "curtainCtrl",
      "nodeId": _meijuData?.nodeId,
      "deviceControlList": [
        {"endPoint": 1, "attribute":ctr}
      ]
    };
    var res = await MeiJuDeviceApi.sendPDMControlOrder(
      categoryCode: '0x16',
      uri: 'curtainControl',
      applianceCode: masterId,
      command: command,
      method: "POST"
    );
    if (res.isSuccess) {
    } else {
      data!.curtainStatus = lastModel;
      if (mode.key == 'open') {
        data!.curtainPosition = 0;
      } else if (mode.key == 'close') {
        data!.curtainPosition = 100;
      }
    }
  }

  void delayFetchData() {
    delayTimer?.cancel();
    delayTimer = Timer(const Duration(seconds: 5), () {
      fetchData();
    });
  }

  // nodeId
  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      'curtainPosition': data!.curtainPosition,
      'curtainStatus': data!.curtainStatus,
      'curtainDirection': data!.curtainDirection,
    };
  }

  @override
  bool? getPowerStatus() {
    return data!.curtainPosition > 0;
  }

  @override
  String? getCharacteristic() {
    return "${data!.curtainPosition}%";
  }

  @override
  Future<dynamic> tabTo(int? index) async {
    if (index == null) return;
    if (index < 0 || index > curtainModes.length - 1) return;
    Mode mode = curtainModes[index];
    return controlMode(mode);
  }

  @override
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;
      updateUI();
      if(MideaRuntimePlatform.inMeiJu()) {
        _meijuData = await fetchMeiJuData();
      }
      if(_meijuData != null) {
        dataState = DataState.SUCCESS;
        data = CurtainDataEntity.fromMeiJu(_meijuData);
      } else {
        dataState = DataState.ERROR;
      }
      updateUI();
    } catch(e) {
      dataState = DataState.ERROR;
      updateUI();
      Log.i(e.toString());
    }
  }

  @override
  bool fetchOnlineState(BuildContext context, String deviceId) {
    return super.fetchOnlineState(context, deviceId);
  }

  @override
  Future slider1To(int? value) {
    return controlCurtain(value as num);
  }

  @override
  Future slider1ToFaker(int? value) async {
    data!.curtainPosition = value!.toInt();
    data!.curtainStatus = 'stop';
    updateUI();
  }

  /// 控制位置
  Future<void> controlCurtain(num value) async {
    int lastPosition = data!.curtainPosition;
    data!.curtainPosition = value.toInt();
    data!.curtainStatus = 'stop';
    updateUI();
    // delayFetchData();
    if (platform.inMeiju()) {
      var command = {
        "msgId": uuid.v4(),
        "deviceId": masterId,
        "nodeId": _meijuData?.nodeId,
        "actionType": "movePercentage",
        "deviceControlList": [
          {"endPoint": 1, "attribute": data!.curtainPosition}
        ]
      };
      var res = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'curtainControl',
        applianceCode: masterId,
        command: command,
        method: "POST"
      );
      if (res.isSuccess) {
      } else {
        data!.curtainPosition = lastPosition;
      }
    }
  }

  Future<NodeInfo<Endpoint<_ZigbeeEleMachineCurtainEvent>>> fetchMeiJuData() {

    return MeiJuDeviceApi.getGatewayInfo<_ZigbeeEleMachineCurtainEvent>(
        applianceCode,
        masterId,
        (p0) => _ZigbeeEleMachineCurtainEvent.fromJson(p0)
    );

  }

}