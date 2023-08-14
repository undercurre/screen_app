import 'dart:convert';

import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/gateway_platform.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';

class CACDataAdapter extends MideaDataAdapter {
  NodeInfo<Endpoint<CAC485Event>> _meijuData = NodeInfo(
    devId: '',
    registerUsers: [],
    masterId: 123,
    nodeName: '',
    idType: '',
    modelId: '',
    endList: [],
    guard: 0,
    isAlarmDevice: '',
    nodeId: '',
    status: 0,
  );
  dynamic _homluxData;
  String name;
  String applianceCode;
  String masterId;
  String nodeId = '';
  String modelNumber = '';

  CAC485Data data = CAC485Data(
      name: "",
      currTemp: "28",
      targetTemp: "26",
      operationMode: "1",
      OnOff: "0",
      windSpeed: "1");

  DataState dataState = DataState.NONE;

  CACDataAdapter(this.name,this.applianceCode, this.masterId, this.modelNumber,
      GatewayPlatform platform)
      : super(platform);

  // Method to retrieve data from both platforms and construct PanelData object
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;

      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else {
        _homluxData = await fetchHomluxData();
      }

      if (_meijuData != null) {
        data = CAC485Data.fromMeiJu(_meijuData, modelNumber);
      } else if (_homluxData != null) {
        data = CAC485Data.fromHomlux(_homluxData, modelNumber);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = CAC485Data(
            name: name,
            currTemp: "28",
            targetTemp: "26",
            operationMode: "4",
            OnOff: "0",
            windSpeed: "1");
        return;
      }

      // Data retrieval success
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      data = CAC485Data(
          name: name,
          currTemp: "28",
          targetTemp: "26",
          operationMode: "4",
          OnOff: "0",
          windSpeed: "1");
      updateUI();
    }
  }

  Future<void> orderPower(int onOff) async {
    if (platform.inMeiju()) {
      fetchOrderPowerMeiju(onOff);
    } else {}
  }

  Future<void> orderMode(int mode) async {
    if (platform.inMeiju()) {
      fetchOrderModeMeiju(mode);
    } else {}
  }

  Future<void> orderTemp(int temp) async {
    if (platform.inMeiju()) {
      fetchOrderTempMeiju(temp);
    } else {}
  }

  Future<void> orderSpeed(int speed) async {
    if (platform.inMeiju()) {
      fetchOrderSpeedMeiju(speed);
    } else {}
  }

  Future<MeiJuResponseEntity> fetchOrderModeMeiju(int mode) async {
    updateUI();
    MeiJuResponseEntity MeijuRes = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'airOperationModeControl',
        applianceCode: masterId,
        command: {
          "msgId": uuid.v4(),
          "deviceId": masterId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": mode}
          ]
        });
    if (!MeijuRes.isSuccess) {
      updateUI();
    }
    return MeijuRes;
  }

  Future<MeiJuResponseEntity> fetchOrderTempMeiju(int temp) async {
    updateUI();
    MeiJuResponseEntity MeijuRes = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'subTargetTempControl',
        applianceCode: masterId,
        command: {
          "msgId": uuid.v4(),
          "deviceId": masterId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": temp}
          ]
        });
    if (!MeijuRes.isSuccess) {
      updateUI();
    }
    return MeijuRes;
  }

  Future<MeiJuResponseEntity> fetchOrderSpeedMeiju(int speed) async {
    updateUI();
    MeiJuResponseEntity MeijuRes = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'subWindSpeedControl',
        applianceCode: masterId,
        command: {
          "msgId": uuid.v4(),
          "deviceId": masterId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": speed}
          ]
        });
    if (!MeijuRes.isSuccess) {
      updateUI();
    }
    return MeijuRes;
  }

  Future<MeiJuResponseEntity> fetchOrderPowerMeiju(int onOff) async {
    updateUI();
    MeiJuResponseEntity MeijuRes = await MeiJuDeviceApi.sendPDMControlOrder(
        categoryCode: '0x16',
        uri: 'subDeviceControl',
        applianceCode: masterId,
        command: {
          "msgId": uuid.v4(),
          "deviceId": masterId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": 1, "attribute": onOff}
          ]
        });
    if (!MeijuRes.isSuccess) {
      updateUI();
    }
    return MeijuRes;
  }


  @override
  void init() {
    // Initialize the adapter and fetch data
    Log.i("初始化空调adapter");
    fetchData();
  }

  @override
  void destroy() {
    clearBindDataUpdateFunction();
  }

  Future<NodeInfo<Endpoint<CAC485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<CAC485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<CAC485Event>(
              applianceCode, masterId, (json) => CAC485Event.fromJson(json));
      nodeId = nodeInfo.nodeId;
      return nodeInfo;
    } catch (e) {
      Log.i('getNodeInfo Error', e);
      return NodeInfo(
        devId: '',
        registerUsers: [],
        masterId: 123,
        nodeName: '',
        idType: '',
        modelId: '',
        endList: [],
        guard: 0,
        isAlarmDevice: '',
        nodeId: '',
        status: 0,
      );
    }
  }

  Future<dynamic> fetchHomluxData() async {
    dynamic HomluxRes = {};
    return HomluxRes;
  }


  Future<void> fetchOrderPowerHomlux() async {
    dynamic HomluxRes = {};
    return HomluxRes;
  }

  static CACDataAdapter create(
      String name, String applianceCode, String masterId, String modelNumber) {
    Log.i("创建空调adapter");
    return CACDataAdapter(
        name,applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for PanelData class remains the same as before
class CAC485Data {
  // 空调名称
  String name = '485空调';

  // 当前室温
  String currTemp = '28';

  // 设定温度
  String targetTemp = "26";

  // 运行模式
  String operationMode = "1";

  // 开关状态
  String OnOff = "0";

  //风速
  String windSpeed = "1";

  CAC485Data(
      {required this.name,
      required this.currTemp,
      required this.targetTemp,
      required this.operationMode,
      required this.OnOff,
      required this.windSpeed});

  CAC485Data.fromMeiJu(
      NodeInfo<Endpoint<CAC485Event>> data, String modelNumber) {
    name = data.endList[0].name;
    currTemp = data.endList[0].event.currTemp;
    targetTemp = data.endList[0].event.targetTemp;
    operationMode = data.endList[0].event.operationMode;
    OnOff = data.endList[0].event.OnOff;
    windSpeed = data.endList[0].event.windSpeed;
  }

  CAC485Data.fromHomlux(dynamic data, String modelNumber) {}
}

class CAC485Event extends Event {
  // 当前室温
  String currTemp = '28';

  // 设定温度
  String targetTemp = "26";

  // 运行模式
  String operationMode = "1";

  // 开关状态
  String OnOff = "0";

  //风速
  String windSpeed = "1";

  CAC485Event(
      {required this.currTemp,
      required this.targetTemp,
      required this.operationMode,
      required this.OnOff,
      required this.windSpeed});

  factory CAC485Event.fromJson(Map<String, dynamic> json) {
    return CAC485Event(
      currTemp: json['currTemp'],
      OnOff: json['OnOff'],
      targetTemp: json['targetTemp'],
      operationMode: json['operationMode'],
      windSpeed: json['windSpeed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currTemp': currTemp,
      'OnOff': OnOff,
      'windSpeed': windSpeed,
      'operationMode': operationMode,
      'targetTemp': targetTemp
    };
  }
}
