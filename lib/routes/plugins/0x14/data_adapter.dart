import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

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
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../../widgets/util/deviceEntityTypeInP4Handle.dart';
import '../0x21/0x21_curtain/mode_list.dart';

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

  CurtainDataEntity.fromMeiJu(dynamic data) {
    curtainPosition = getCurtainPosition(data);
    curtainStatus = data['curtain_status'];
    curtainDirection = data['curtain_direction'];
    onlineState = 1;
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

class WIFICurtainDataAdapter extends DeviceCardDataAdapter<CurtainDataEntity> {
  String deviceName = "Wifi窗帘";
  String applianceCode = "";

  dynamic _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  Timer? delayTimer;

  CurtainDataEntity? data = CurtainDataEntity(
    curtainPosition: 0,
    curtainStatus: 'stop',
    curtainDirection: 'positive',
    onlineState: 0
  );


  WIFICurtainDataAdapter(super.platform, this.applianceCode) {
    type = AdapterType.wifiCurtain;
  }

  @override
  void init() {
    _startPushListen();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      'curtainPosition': data!.curtainPosition,
      'curtainStatus': data!.curtainStatus,
      'curtainDirection': data!.curtainDirection,
    };
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  Future<void> power(bool? onOff) async {
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

  @override
  bool fetchOnlineState(BuildContext context, String deviceId) {
    if(platform.inMeiju()) {
      return super.fetchOnlineState(context, deviceId);
    } else {
      return data?.onlineState == 1;
    }
  }

  @override
  Future<void> tryOnce() async {
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

  @override
  bool getPowerStatus() {
    // Log.i('获取开关状态', data!.curtainPosition > 0);
    return data!.curtainPosition > 0;
  }

  @override
  String? getCharacteristic() {
    // Log.i('获取特征状态', data!.curtainPosition);
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
  Future<dynamic> slider1To(int? value) async {
    return controlCurtain(value as num);
  }

  @override
  Future<dynamic> slider1ToFaker(int? value) async {
    return controlCurtainFaker(value as num);
  }

  /// 防抖刷新
  void _throttledFetchData() {
    fetchData();
  }

  void delayFetchData() {
    delayTimer?.cancel();
    delayTimer = Timer(const Duration(seconds: 5), () {
      fetchData();
    });
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
        data = CurtainDataEntity.fromMeiJu(_meijuData!);
      } else if (_homluxData != null) {
        data = CurtainDataEntity.fromHomlux(_homluxData!);
      } else {
        dataState = DataState.ERROR;
        data = CurtainDataEntity(
          curtainPosition: 0,
          curtainStatus: 'stop',
          curtainDirection: 'positive',
          onlineState: 0
        );
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
          await MeiJuDeviceApi.getDeviceDetail('0x14', applianceCode);
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

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    String lastModel = data!.curtainStatus;
    data!.curtainStatus = mode.key;
    if (mode.key == 'open') {
      data!.curtainPosition = 100;
    } else if (mode.key == 'close') {
      data!.curtainPosition = 0;
    }
    updateUI();
    delayFetchData();
    if (platform.inMeiju()) {
      var command = {
        "curtain_status": data!.curtainStatus,
        'curtain_direction': data!.curtainDirection
      };
      var res = await MeiJuDeviceApi.sendLuaOrder(
        categoryCode: '0x14',
        applianceCode: applianceCode,
        command: command,
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
    } else if (platform.inHomlux()) {
      var res;
      if (mode.key == "stop") {
        res = await HomluxDeviceApi.controlWifiCurtainStop(applianceCode, "3");
      } else {
        res = await HomluxDeviceApi.controlWifiCurtainOnOff(
            applianceCode, "3", mode.key == 'open' ? 1 : 0);
      }
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
  }

  /// 控制位置
  Future<void> controlCurtain(num value) async {
    int lastPosition = data!.curtainPosition;
    data!.curtainPosition = value.toInt();
    data!.curtainStatus = 'stop';
    updateUI();
    delayFetchData();
    if (platform.inMeiju()) {
      var command = {
        "curtain_position": value,
        'curtain_direction': data!.curtainDirection
      };
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0x14', applianceCode: applianceCode, command: command);

      if (res.isSuccess) {
      } else {
        data!.curtainPosition = lastPosition;
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiCurtainPosition(
          applianceCode, "3", value.toInt());
      if (res.isSuccess) {
      } else {
        data!.curtainPosition = lastPosition;
      }
    }
  }

  Future<void> controlCurtainFaker(num value) async {
    data!.curtainPosition = value.toInt();
    data!.curtainStatus = 'stop';
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
    delayTimer?.cancel();
  }
}
