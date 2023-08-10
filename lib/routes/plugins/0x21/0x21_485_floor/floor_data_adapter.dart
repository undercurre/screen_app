import 'dart:convert';

import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/gateway_platform.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';

class FloorDataAdapter extends MideaDataAdapter {
  NodeInfo<Endpoint<Floor485Event>> _meijuData = NodeInfo(
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

  Floor485Data data = Floor485Data(
      name: "",
      targetTemp: "26",
      OnOff: "0",
      );

  DataState dataState = DataState.NONE;

  FloorDataAdapter(this.name,this.applianceCode, this.masterId, this.modelNumber,
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
        data = Floor485Data.fromMeiJu(_meijuData, modelNumber);
      } else if (_homluxData != null) {
        data = Floor485Data.fromHomlux(_homluxData, modelNumber);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = Floor485Data(
            name: name,
            targetTemp: "26",
            OnOff: "0",
            );
        return;
      }

      // Data retrieval success
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      data = Floor485Data(
          name: name,
          targetTemp: "26",
          OnOff: "0",
          );
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

  Future<NodeInfo<Endpoint<Floor485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<Floor485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<Floor485Event>(
              applianceCode, masterId, (json) => Floor485Event.fromJson(json));
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

  static FloorDataAdapter create(
      String name, String applianceCode, String masterId, String modelNumber) {
    Log.i("创建空调adapter");
    return FloorDataAdapter(
        name,applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for PanelData class remains the same as before
class Floor485Data {
  // 空调名称
  String name = '485地暖';

  // 设定温度
  String targetTemp = "26";

  // 开关状态
  String OnOff = "0";


  Floor485Data(
      {required this.name,
      required this.targetTemp,
      required this.OnOff,
      });

  Floor485Data.fromMeiJu(
      NodeInfo<Endpoint<Floor485Event>> data, String modelNumber) {
    name = data.endList[0].name;
    targetTemp = data.endList[0].event.targetTemp;
    OnOff = data.endList[0].event.OnOff;
  }

  Floor485Data.fromHomlux(dynamic data, String modelNumber) {}
}

class Floor485Event extends Event {

  // 设定温度
  String targetTemp = "26";

  // 开关状态
  String OnOff = "0";


  Floor485Event(
      {
      required this.targetTemp,
      required this.OnOff,
      });

  factory Floor485Event.fromJson(Map<String, dynamic> json) {
    return Floor485Event(
      OnOff: json['OnOff'],
      targetTemp: json['targetTemp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OnOff': OnOff,
      'targetTemp': targetTemp
    };
  }
}
