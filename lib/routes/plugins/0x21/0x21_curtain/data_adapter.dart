import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../widgets/event_bus.dart';

class _CurtainDataEntity {
  int curtainPosition;
  String curtainStatus;
  String curtainDirection;
  int onlineState;

  _CurtainDataEntity(
      {required this.curtainDirection,
      required this.curtainStatus,
      required this.curtainPosition,
      required this.onlineState});

  _CurtainDataEntity.fromMeiJu(_ZigbeeCurtainEvent data)
      : curtainPosition = data.position(),
        curtainStatus = data.state(),
        curtainDirection = data.direction(),
        onlineState = data.onlineState();

  _CurtainDataEntity.fromHomlux(dynamic data)
      : curtainPosition = 0,
        curtainStatus = 'stop',
        curtainDirection = 'positive',
        onlineState = 0;

  _CurtainDataEntity.defaultState()
      : curtainPosition = 0,
        curtainStatus = 'stop',
        curtainDirection = 'positive',
        onlineState = 0;

  Map<String, dynamic> toJson() {
    return {
      'curtainPosition': curtainPosition,
      'curtainStatus': curtainStatus,
      'curtainDirection': curtainDirection,
      'onlineState': onlineState
    };
  }
}

class _ZigbeeCurtainEvent extends CommonEvent {

  _ZigbeeCurtainEvent({required super.event});

  int position() {
    if(event['Level'] is int) {
      return max(min(event['Level'], 100), 0);
    } else if(event['Level'] is String) {
      return max(min(int.parse(event['Level']), 100), 0);
    }
    return 0;
  }

  String state() {
    var curPos = position();
    if(curPos == 0) {
      return 'close';
    } else if(curPos == 100) {
      return 'open';
    } else {
      return 'stop';
    }
  }

  String direction() {
    return 'positive';
  }

  int onlineState() {
    return 1;
  }
}

/// 暂停
/// OnOff: 240  Level: 0 - 100
/// 打开
/// OnOff: 1    Level: 随机
/// 关闭
/// OnOff: 0    Level: 随机
class ZigbeeCurtainDataAdapter extends DeviceCardDataAdapter<_CurtainDataEntity> {
  String deviceName = 'zigbee窗帘';

  final String applianceCode;

  final String masterId;

  NodeInfo<Endpoint<_ZigbeeCurtainEvent>>? _meijuData;

  dynamic _homluxData;

  Timer? delayTimer;

  ZigbeeCurtainDataAdapter(super.platform, this.applianceCode, this.masterId) {
    data = _CurtainDataEntity.defaultState();
  }

  @override
  Future power(bool? onOff) async {
    bus.emit('operateDevice', applianceCode);
    if (platform.inMeiju() && _meijuData != null) {
      data!.curtainPosition = onOff == false ? 100 : 0;
      data!.curtainStatus = onOff == false ? 'open' : 'close';
      updateUI();
      _meijuZigbeeCurtainControl(
          masterId: masterId,
          nodeId: _meijuData!.nodeId,
          attribute: onOff == false ? 100 : 0);
      delayFetchData();
    }
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  void delayFetchData() {
    delayTimer?.cancel();
    delayTimer = Timer(const Duration(seconds: 5), () {
      fetchData();
    });
  }

  @override
  bool getPowerStatus() {
    Log.develop("当前窗帘状态：${data!.curtainStatus}");
    // close stop open
    return data!.curtainStatus != 'close';
  }

  @override
  String? getCharacteristic() {
    return "${data!.curtainPosition}%";
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    bus.emit('operateDevice', applianceCode);
    if (platform.inMeiju()) {
      data!.curtainPosition = value!;
      data!.curtainStatus = 'stop';
      _meijuZigbeeCurtainControl(
          masterId: masterId, nodeId: _meijuData!.nodeId, attribute: value);
      updateUI();
    }
  }

  @override
  Future<dynamic> slider1ToFaker(int? value) async {
    bus.emit('operateDevice', applianceCode);
    if (platform.inMeiju()) {
      data!.curtainPosition = value!;
      data!.curtainStatus = 'stop';
      updateUI();
    }
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (_meijuData != null && args.nodeId == _meijuData!.nodeId) {
      fetchData();
    }
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      'curtainPosition': data!.curtainPosition,
      'curtainStatus': data!.curtainStatus,
      'curtainDirection': data!.curtainDirection,
    };
  }

  /// index:
  /// 0 :  全开
  /// 1 ： 暂停
  /// 2 ： 全关
  @override
  Future tabTo(int? index) async {
    bus.emit('operateDevice', applianceCode);
    if (index == null) return;
    if (index < 0 || index > 3) return;
    if (platform.inMeiju() && _meijuData != null) {
      switch (index) {
        case 0:
          power(false);
        case 2:
          power(true);
        case 1:
          data!.curtainStatus = 'stop';
          _meijuZigbeeCurtainControl(
              masterId: masterId, nodeId: _meijuData!.nodeId, attribute: 240);
          delayFetchData();
          updateUI();
      }
    }
  }

  Future _meijuZigbeeCurtainControl(
      {required String masterId,
      required String nodeId,
      required num attribute}) async {
    MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/appliance/operation/curtainOpenPerControl/$masterId",
        options: Options(method: "PUT"),
        data: {
          "msgId": const Uuid().v4(),
          "deviceControlList": [
            {"endPoint": 1, "attribute": attribute}
          ],
          "deviceId": masterId,
          "nodeId": nodeId,
        });
    // MeiJuDeviceApi.sendPDMControlOrder(
    //     categoryCode: '0x16',
    //     uri: 'subDeviceControl',
    //     applianceCode: masterId,
    //     command: {
    //       "msgId": uuid.v4(),
    //       "deviceId": masterId,
    //       "nodeId": nodeId,
    //       "deviceControlList": [
    //         {
    //           "endPoint": 1,
    //           "attribute": attribute
    //         }
    //       ]
    //     }
    // );
  }

  @override
  Future<void> fetchData() async {
    if (platform.inMeiju()) {
      try {
        var result = await MeiJuDeviceApi.getGatewayInfo(
            applianceCode, masterId, (p0) => _ZigbeeCurtainEvent(event: p0));
        _meijuData = result;
        data = _CurtainDataEntity.fromMeiJu(result.endList[0].event);
        dataState = DataState.SUCCESS;
        updateUI();
        Log.develop(
            "网络请求数据 ${jsonEncode(result.endList[0].event.event)} ${jsonEncode(data!.toJson())}");
      } catch (e, stack) {
        Log.develop("请求zigbee窗帘电机报错", e, stack);
        if(_meijuData == null) {
          dataState = DataState.ERROR;
          updateUI();
        }
      }
    } else {
      dataState = DataState.SUCCESS;
      data = _CurtainDataEntity.defaultState();
      updateUI();
    }
  }
}
