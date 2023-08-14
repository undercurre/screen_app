import 'dart:convert';

import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/gateway_platform.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';

class AirDataAdapter extends MideaDataAdapter {
  NodeInfo<Endpoint<Air485Event>> _meijuData = NodeInfo(
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

  Air485Data data = Air485Data(
      name: "",
      operationMode: "1",
      OnOff: "0",
      windSpeed: "1");

  DataState dataState = DataState.NONE;

  AirDataAdapter(this.name,this.applianceCode, this.masterId, this.modelNumber,
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
        data = Air485Data.fromMeiJu(_meijuData, modelNumber);
      } else if (_homluxData != null) {
        data = Air485Data.fromHomlux(_homluxData, modelNumber);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = Air485Data(
            name: name,
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
      data = Air485Data(
          name: name,
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

  Future<NodeInfo<Endpoint<Air485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<Air485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<Air485Event>(
              applianceCode, masterId, (json) => Air485Event.fromJson(json));
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

  static AirDataAdapter create(
      String name, String applianceCode, String masterId, String modelNumber) {
    Log.i("创建空调adapter");
    return AirDataAdapter(
        name,applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for PanelData class remains the same as before
class Air485Data {
  // 空调名称
  String name = '485新风';

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

  Air485Data(
      {required this.name,
      required this.operationMode,
      required this.OnOff,
      required this.windSpeed});

  Air485Data.fromMeiJu(
      NodeInfo<Endpoint<Air485Event>> data, String modelNumber) {
    name = data.endList[0].name;
    operationMode = data.endList[0].event.operationMode;
    OnOff = data.endList[0].event.OnOff;
    windSpeed = data.endList[0].event.windSpeed;
  }

  Air485Data.fromHomlux(dynamic data, String modelNumber) {}
}

class Air485Event extends Event {

  // 运行模式
  String operationMode = "1";

  // 开关状态
  String OnOff = "0";

  //风速
  String windSpeed = "1";

  Air485Event(
      {
      required this.operationMode,
      required this.OnOff,
      required this.windSpeed});

  factory Air485Event.fromJson(Map<String, dynamic> json) {
    return Air485Event(
      OnOff: json['OnOff'],
      operationMode: json['operationMode'],
      windSpeed: json['windSpeed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OnOff': OnOff,
      'windSpeed': windSpeed,
      'operationMode': operationMode,
    };
  }
}
