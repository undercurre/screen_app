import 'dart:convert';

import '../../routes/plugins/0x21/0x21_curtain/api.dart';
import '../gateway_platform.dart';
import '../global.dart';
import '../meiju/api/meiju_device_api.dart';
import '../meiju/models/meiju_response_entity.dart';
import 'midea_data_adapter.dart';

class PanelDataAdapter extends MideaDataAdapter {
  PanelData data = PanelData(name: '开关', nameList: [], statusList: [], isOnline: false, roomName: '');

  dynamic _meijuData;
  dynamic _homluxData;

  String applianceCode;
  String masterId;
  String nodeId = '';

  DataState dataState = DataState.NONE;

  PanelDataAdapter(
      this.applianceCode, this.masterId, GatewayPlatform platform)
      : super(platform);

  // Method to retrieve data from both platforms and construct PanelData object
  Future<void> fetchData() async {
    if (nodeId.isEmpty) {
      initNodeId();
    }
    try {
      dataState = DataState.LOADING;

      if (platform.inHomlux()) {
        dynamic MeijuRes = MeiJuDeviceApi.sendPDMOrder(
            categoryCode: '0x16',
            uri: '/subDeviceGetStatus',
            applianceCode: applianceCode,
            command: {
              "msgId": uuid.v4(),
              "deviceId": masterId,
              "nodeId": nodeId
            });
        logger.i('美居状态刷新结果', MeijuRes);
      } else {}

      if (_meijuData != null) {
        data = PanelData.fromMeiJu(_meijuData);
      } else if (_homluxData != null) {
        data = PanelData.fromHomlux(_homluxData);
      } else {
        // If both platforms return null data, consider it an error state
        dataState = DataState.ERROR;
        data = PanelData(name: '开关', nameList: [], statusList: [], isOnline: false, roomName: '');
        return;
      }

      // Data retrieval success
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      data = PanelData(name: '开关', nameList: [], statusList: [], isOnline: false, roomName: '');
      updateUI();
    }
  }

  @override
  void init() {
    // Initialize the adapter and fetch data
    // fetchData();
  }

  @override
  void destroy() {
    clearBindDataUpdateFunction();
  }

  // Implement fetchMeijuData() and fetchHomluxData() methods to retrieve data
  Future<dynamic> fetchMeijuData() async {
    // Replace the following line with your Meiju platform data retrieval logic
    // For example, you can use API calls or other methods to fetch data
    return null;
  }

  Future<dynamic> fetchHomluxData() async {
    // Replace the following line with your Homlux platform data retrieval logic
    // For example, you can use API calls or other methods to fetch data
    return null;
  }

  Future<void> initNodeId() async {
    MeiJuResponseEntity<String> nodeInfo = await MeiJuDeviceApi.getGatewayInfo(applianceCode, masterId);
    if (nodeInfo.data != null) {
      Map<String, dynamic> infoMap = json.decode(nodeInfo.data!);
      nodeId = infoMap["nodeid"];
    }
  }

  static PanelDataAdapter create(
      String applianceCode, String masterId) {
    return PanelDataAdapter(applianceCode, masterId, MideaRuntimePlatform.platform);
  }
}

// The rest of the code for PanelData class remains the same as before
class PanelData {
  // 开关设备名称
  String name = '开关面板';

  // 开关名称列表
  List<String> nameList = [];

  // 开关状态列表
  List<bool> statusList = [];

  // 是否在线
  bool isOnline = false;

  // 房间名
  String roomName = '房间';

  PanelData({
    required this.name,
    required this.nameList,
    required this.statusList,
    required this.isOnline,
    required this.roomName
  });

  PanelData.fromMeiJu(dynamic data) {
    name = data.name;
    nameList = data.nameList;
    statusList = data.statusList;
    isOnline = data.isOnline;
    roomName = data.roomName;
  }

  PanelData.fromHomlux(dynamic data) {
    name = data.name;
    nameList = data.nameList;
    statusList = data.statusList;
    isOnline = data.isOnline;
    roomName = data.roomName;
  }
}
