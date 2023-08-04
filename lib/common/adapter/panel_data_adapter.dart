import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/logcat_helper.dart';

import '../gateway_platform.dart';
import '../meiju/api/meiju_device_api.dart';
import '../meiju/models/meiju_response_entity.dart';
import '../models/endpoint.dart';
import '../models/node_info.dart';
import '../models/pdm_result_get_status.dart';
import 'midea_data_adapter.dart';

class PanelDataAdapter extends MideaDataAdapter {
  PanelData data = PanelData(nameList: [], statusList: []);

  NodeInfo<Endpoint<PanelEvent>> _meijuData = NodeInfo(
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

  String applianceCode;
  String masterId;
  String nodeId = '';

  DataState dataState = DataState.NONE;

  PanelDataAdapter(this.applianceCode, this.masterId, GatewayPlatform platform)
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
        data = PanelData.fromMeiJu(_meijuData);
      } else if (_homluxData != null) {
        data = PanelData.fromHomlux(_homluxData);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = PanelData(
          nameList: [],
          statusList: [],
        );
        return;
      }

      // Data retrieval success
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      data = PanelData(
        nameList: [],
        statusList: [],
      );
      updateUI();
    }
  }

  Future<void> orderPower() async {
    if (platform.inMeiju()) {
    } else {}
  }

  @override
  void init() {
    // Initialize the adapter and fetch data
    fetchData();
  }

  @override
  void destroy() {
    clearBindDataUpdateFunction();
  }

  Future<NodeInfo<Endpoint<PanelEvent>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<PanelEvent>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<PanelEvent>(
              applianceCode, masterId, (json) => PanelEvent.fromJson(json));
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

  Future<MeiJuResponseEntity> fetchOrderPowerMeiju(int PanelIndex) async {
    data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
    updateUI();
    MeiJuResponseEntity MeijuRes =
        await MeiJuDeviceApi.sendPDMControlOrder(
            categoryCode: '0x16',
            uri: 'subDeviceControl',
            applianceCode: masterId,
            command: {
          "msgId": uuid.v4(),
          "deviceId": masterId,
          "nodeId": nodeId,
          "deviceControlList": [
            {"endPoint": PanelIndex, "attribute": data.statusList[PanelIndex - 1] ? 1 : 0}
          ]
        });
    if (!MeijuRes.isSuccess) {
      data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
      updateUI();
    }
    return MeijuRes;
  }

  Future<void> fetchOrderPowerHomlux() async {
    dynamic HomluxRes = {};
    return HomluxRes;
  }

  static PanelDataAdapter create(String applianceCode, String masterId) {
    return PanelDataAdapter(
        applianceCode, masterId, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for PanelData class remains the same as before
class PanelData {
  // 开关名称列表
  List<String> nameList = [];

  // 开关状态列表
  List<bool> statusList = [];

  PanelData({
    required this.nameList,
    required this.statusList,
  });

  PanelData.fromMeiJu(NodeInfo<Endpoint<PanelEvent>> data) {
    nameList = data.endList.map((e) => e.name).toList();
    statusList = data.endList.map((e) => e.event.onOff == '1').toList();
  }

  PanelData.fromHomlux(dynamic data) {
    nameList = data.nameList;
    statusList = data.statusList;
  }
}

class PanelEvent extends Event {
  String onOff;
  String startupOnOff;

  PanelEvent({
    required this.onOff,
    required this.startupOnOff,
  });

  factory PanelEvent.fromJson(Map<String, dynamic> json) {
    return PanelEvent(
      onOff: json['OnOff'],
      startupOnOff: json['StartUpOnOff'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'onOff': onOff, 'startupOnOff': startupOnOff};
  }
}
