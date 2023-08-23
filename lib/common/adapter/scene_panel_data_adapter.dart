import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/homlux/api/homlux_device_api.dart';
import 'package:screen_app/common/logcat_helper.dart';

import '../gateway_platform.dart';
import '../homlux/models/homlux_device_entity.dart';
import '../homlux/models/homlux_response_entity.dart';
import '../meiju/api/meiju_device_api.dart';
import '../meiju/api/meiju_gateway_cloud_api.dart';
import '../meiju/models/meiju_response_entity.dart';
import '../models/endpoint.dart';
import '../models/node_info.dart';
import 'midea_data_adapter.dart';

class ScenePanelDataAdapter extends MideaDataAdapter {
  NodeInfo<Endpoint<PanelEvent>>? _meijuData = null;
  HomluxDeviceEntity? _homluxData = null;

  String applianceCode;
  String masterId;
  String nodeId = '';
  String modelNumber = '';

  ScenePanelData data = ScenePanelData(
    modeList: ['0', '0', '0', '0'],
    sceneList: ['场景1', '场景2', '场景3', '场景4'],
    nameList: ['按键1', '按键2', '按键3', '按键4'],
    statusList: [false, false, false, false],
  );

  DataState dataState = DataState.NONE;

  ScenePanelDataAdapter(this.applianceCode, this.masterId, this.modelNumber,
      GatewayPlatform platform)
      : super(platform);

  // Method to retrieve data from both platforms and construct ScenePanelData object
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;

      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else {
        _homluxData = await fetchHomluxData();
      }

      if (_meijuData != null) {
        // Log.i(_meijuData.toString(), modelNumber);
        data = ScenePanelData.fromMeiJu(_meijuData!, modelNumber);
      } else if (_homluxData != null) {
        data = ScenePanelData.fromHomlux(_homluxData!);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = ScenePanelData(
          modeList: [],
          sceneList: [],
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
      Log.i(e.toString());
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
      MeiJuResponseEntity sceneListRes = await MeiJuGatewayCloudApi.queryPanelBindList(applianceCode);
      Log.i('多功能面板场景接口', sceneListRes.data);
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

  Future<void> fetchOrderPower(int PanelIndex) async {
    if (platform.inMeiju()) {
      fetchOrderPowerMeiju(PanelIndex);
    } else {
      fetchOrderPowerHomlux(PanelIndex);
    }
  }

  Future<MeiJuResponseEntity> fetchOrderPowerMeiju(int PanelIndex) async {
    data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
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
            {
              "endPoint": PanelIndex,
              "attribute": data.statusList[PanelIndex - 1] ? 1 : 0
            }
          ]
        });
    if (!MeijuRes.isSuccess) {
      data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
      updateUI();
    }
    return MeijuRes;
  }

  Future<HomluxResponseEntity> fetchOrderPowerHomlux(int PanelIndex) async {
    data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
    updateUI();
    HomluxResponseEntity HomluxRes = await HomluxDeviceApi.controlPanelOnOff(
        applianceCode,
        PanelIndex.toString(),
        masterId,
        data.statusList[PanelIndex - 1] ? 1 : 0);
    if (!HomluxRes.isSuccess) {
      data.statusList[PanelIndex - 1] = !data.statusList[PanelIndex - 1];
      updateUI();
    }
    return HomluxRes;
  }

  static ScenePanelDataAdapter create(
      String applianceCode, String masterId, String modelNumber) {
    return ScenePanelDataAdapter(
        applianceCode, masterId, modelNumber, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for ScenePanelData class remains the same as before
class ScenePanelData {
  // 模式列表
  List modeList = ['0', '0', '0', '0'];

  // 绑定的场景列表
  List<String> sceneList = ['场景1', '场景2', '场景3', '场景4'];

  // 开关名称列表
  List<String> nameList = ['按键1', '按键2', '按键3', '按键4'];

  // 开关状态列表
  List<bool> statusList = [false, false, false, false];

  ScenePanelData({
    required this.modeList,
    required this.nameList,
    required this.statusList,
    required this.sceneList,
  });

  ScenePanelData.fromMeiJu(
      NodeInfo<Endpoint<PanelEvent>> data, String modelNumber) {
    if (_isWaterElectron(modelNumber)) {
      nameList = ['水阀', '电阀'];
    } else {
      nameList = data.endList.map((e) => e.name).toList();
    }
    statusList = data.endList.map((e) => e.event.onOff == '1').toList();
  }

  ScenePanelData.fromHomlux(HomluxDeviceEntity data) {
    nameList = data.switchInfoDTOList!.map((e) => e.switchName!).toList();
    statusList = [
      data.mzgdPropertyDTOList!.x1?.power == 1,
      data.mzgdPropertyDTOList!.x2?.power == 1,
      data.mzgdPropertyDTOList!.x3?.power == 1,
      data.mzgdPropertyDTOList!.x4?.power == 1
    ];
  }
}

class PanelEvent extends Event {
  dynamic onOff;
  dynamic startupOnOff; // 将 startupOnOff 变为可选属性

  PanelEvent({
    required this.onOff,
    this.startupOnOff, // 标记 startupOnOff 为可选参数
  });

  factory PanelEvent.fromJson(Map<String, dynamic> json) {
    return PanelEvent(
      onOff: json['OnOff'],
      startupOnOff: json['StartUpOnOff'], // 可能不存在的键
    );
  }

  Map<String, dynamic> toJson() {
    return {'onOff': onOff, 'startupOnOff': startupOnOff};
  }
}

bool _isWaterElectron(String modelNumber) {
  List<String> validList = ['1344', '1112', '1111', '80', '81', '22'];

  return validList.contains(modelNumber);
}
