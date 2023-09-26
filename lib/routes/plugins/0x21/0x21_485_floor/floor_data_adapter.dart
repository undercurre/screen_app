import 'package:screen_app/common/global.dart';
import '../../../../channel/index.dart';
import '../../../../channel/models/local_485_device_state.dart';
import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/homlux/homlux_global.dart';
import '../../../../common/homlux/models/homlux_485_device_list_entity.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../common/system.dart';
import '../../../../widgets/event_bus.dart';

class FloorDataAdapter extends DeviceCardDataAdapter<Floor485Data> {
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
  bool isLocalDevice = false;

  Floor485Data? data;

  DataState dataState = DataState.NONE;

  String localDeviceCode = "";

  FloorDataAdapter(super.platform, this.name, this.applianceCode, this.masterId, this.modelNumber) {
    type = AdapterType.floor485;
  }

  // Method to retrieve data from both platforms and construct PanelData object
  Future<void> fetchData() async {
    if (isLocalDevice == false) {
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
      }
    }
  }

  Future<void> orderPower(int onOff) async {
    if (nodeId != null) {
      bus.emit('operateDevice', nodeId);
      if (nodeId.split('-')[0] == System.macAddress) {
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485FloorHeatPower(
            onOff.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderPowerMeiju(onOff);
        }
      } else {
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderPowerMeiju(onOff);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485FloorHeatPower(
              onOff.toString(), applianceCode);
        }
      }
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatPower(
          onOff.toString(), applianceCode);
    }
  }

  Future<void> orderTemp(int temp) async {
    if (nodeId != null) {
      bus.emit('operateDevice', nodeId);
      if (nodeId.split('-')[0] == System.macAddress) {
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485FloorHeatTemper(
            temp.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderTempMeiju(temp);
        }
      } else {
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderTempMeiju(temp);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485FloorHeatTemper(
              temp.toString(), applianceCode);
        }
      }
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatTemper(
          temp.toString(), applianceCode);
    }
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

  void handle(MeiJuSubDevicePropertyChangeEvent args) {
    if(nodeId==args.nodeId){
      fetchData();
    }
  }

  @override
  void init() {
    // Initialize the adapter and fetch data
    deviceLocal485ControlChannel.registerLocal485CallBack(_local485StateCallback);
    if (applianceCode.length != 4) {
      isLocalDevice = false;
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(handle);
      fetchData();
    } else {
      isLocalDevice = true;
      Homlux485DeviceListEntity? deviceList =
          HomluxGlobal.getHomlux485DeviceList;

      ///homlux添加本地485空调设备
      if (deviceList != null) {
        for (int i = 0;
            i < deviceList!.nameValuePairs!.floorHotList!.length;
            i++) {
          if ("${(deviceList!.nameValuePairs!.floorHotList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.floorHotList![i].inSideAddress)!}" ==
              applianceCode) {
            String? OnOff = deviceList!.nameValuePairs!.floorHotList![i].onOff;
            String? targetTemp =
                deviceList!.nameValuePairs!.floorHotList![i].currTemperature;
            data = Floor485Data(
              name: name,
              targetTemp: int.parse(targetTemp!, radix: 16).toString()!,
              OnOff: OnOff!,
            );
          }
        }
      } else {
        data = Floor485Data(
          name: name,
          targetTemp: "26",
          OnOff: "0",
        );
      }
    }
  }

  void _local485StateCallback(Local485DeviceState state) {
    if (state.modelId == "zhonghong.heat.001" &&
        localDeviceCode == state.address) {
      data = Floor485Data(
        name: name,
        targetTemp: state.temper.toString(),
        OnOff: state.onOff.toString(),
      );
      logger.i("Local地暖温度:${data?.targetTemp}");
      updateUI();
    }
  }

  @override
  void dispose() {
    logger.i("注销Local485CallBack");
    deviceLocal485ControlChannel
        .unregisterLocal485CallBack(_local485StateCallback);
    bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(handle);
  }

  @override
  void destroy() {}

  Future<NodeInfo<Endpoint<Floor485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<Floor485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<Floor485Event>(
              applianceCode, masterId, (json) => Floor485Event.fromJson(json));
      nodeId = nodeInfo.nodeId;
      localDeviceCode = nodeId.split('-')[1];
      Log.i('地暖拿到的nodeid:$nodeId');
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
}

// The rest of the code for PanelData class remains the same as before
class Floor485Data {
  // 空调名称
  String name = '485地暖';

  // 设定温度
  String targetTemp = "26";

  // 开关状态
  String OnOff = "0";

  Floor485Data({
    required this.name,
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

  Floor485Event({
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
    return {'OnOff': OnOff, 'targetTemp': targetTemp};
  }
}
