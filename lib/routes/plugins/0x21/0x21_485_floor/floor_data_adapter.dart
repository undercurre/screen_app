import '../../../../channel/index.dart';
import '../../../../channel/models/local_485_device_state.dart';
import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../common/system.dart';
import '../../../../common/utils.dart';
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

  Floor485Data? data= Floor485Data(
    name: "地暖",
    online: true,
    targetTemp: 26,
    currentTemp:30,
    OnOff: true,
  );

  DataState dataState = DataState.NONE;

  String localDeviceCode = "0000";

  FloorDataAdapter(super.platform, this.name, this.applianceCode, this.masterId, this.modelNumber) {
    type = AdapterType.floor485;
  }

  // Method to retrieve data from both platforms and construct PanelData object
  @override
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
            online: true,
            targetTemp: 26,
            OnOff: true,
            currentTemp: 30,
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
          online: true,
          targetTemp: 26,
          currentTemp: 30,
          OnOff: true,
        );
      }
    }else {
      deviceLocal485ControlChannel.get485DeviceStateByAddr(localDeviceCode,"zhonghong.heat.001");
    }
  }

  Future<void> orderPower(int onOff) async {

    if (localDeviceCode.isNotEmpty&&isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatPower(
          onOff.toString(), localDeviceCode);
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatPower(
          onOff.toString(), localDeviceCode);
    } else if (nodeId.isNotEmpty) {
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
              onOff.toString(), localDeviceCode);
        }
      }
    }
  }

  Future<void> orderTemp(int temp) async {
    if (localDeviceCode.isNotEmpty&&isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatTemper(
          temp.toString(), localDeviceCode);
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485FloorHeatTemper(
          temp.toString(), localDeviceCode);
    } else if (nodeId.isNotEmpty) {
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
              temp.toString(), localDeviceCode);
        }
      }
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

  @override
  void init() {
    deviceLocal485ControlChannel.registerLocal485CallBack(_local485StateCallback);
    getLocalDeviceCode();
    _startPushListen();
    fetchData();

  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (nodeId==args.nodeId) {
      fetchData();
    }
  }

  void _startPushListen() {
    if (platform.inMeiju()) {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (platform.inMeiju()) {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _local485StateCallback(Local485DeviceState state) {
    if (state.modelId == "zhonghong.heat.001" && localDeviceCode == state.address) {
      data = Floor485Data(
        name: name,
        online: state.online==1?true:false,
        targetTemp: state.temper,
        OnOff: state.onOff==1?true:false,
        currentTemp: state.currTemperature,
      );
      updateUI();
    }else if(state.modelId=="zhonghong.heat.001"&&applianceCode==state.address){
      data = Floor485Data(
        name: name,
        online: state.online==1?true:false,
        targetTemp: state.temper,
        OnOff: state.onOff==1?true:false,
        currentTemp: state.currTemperature,

      );
      updateUI();
    }
  }

  @override
  void destroy() {
    deviceLocal485ControlChannel.unregisterLocal485CallBack(_local485StateCallback);
    _stopPushListen();
  }

  Future<NodeInfo<Endpoint<Floor485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<Floor485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<Floor485Event>(
              applianceCode, masterId, (json) => Floor485Event.fromJson(json));
      nodeId = nodeInfo.nodeId;
      localDeviceCode = nodeId.split('-')[1];
      if (nodeId.split('-')[0] == System.macAddress) {
        isLocalDevice = true;
      } else {
        isLocalDevice = false;
      }
      LocalStorage.setItem(applianceCode, nodeId);
      return nodeInfo;
    } catch (e) {
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

  Future<void> getLocalDeviceCode() async {
    nodeId = await LocalStorage.getItem(applianceCode) ?? "";
    String macAddr = await aboutSystemChannel.getMacAddress();
    System.macAddress=macAddr.replaceAll(":", "").toUpperCase();
    if (applianceCode.length != 4) {
      if (nodeId.isNotEmpty) {
        localDeviceCode = nodeId.split('-')[1];
        if (nodeId.split('-')[0] == System.macAddress) {
          isLocalDevice = true;
        } else {
          isLocalDevice = false;
        }
      }else{
        isLocalDevice = false;
      }
    } else {
      isLocalDevice = true;
      localDeviceCode=applianceCode;
    }
  }

}

// The rest of the code for PanelData class remains the same as before
class Floor485Data {
  // 空调名称
  String name = '485地暖';

  // 设定温度
  int targetTemp = 26;

  int currentTemp=20;

  // 开关状态
  bool OnOff = false;

  bool online = true;


  Floor485Data({
    required this.name,
    required this.online,
    required this.targetTemp,
    required this.OnOff,
    required this.currentTemp,
  });

  Floor485Data.fromMeiJu(
      NodeInfo<Endpoint<Floor485Event>> data, String modelNumber) {
    name = data.endList[0].name;
    targetTemp = int.parse(data.endList[0].event.targetTemp);
    currentTemp = int.parse(data.endList[0].event.currTemp);
    OnOff = data.endList[0].event.OnOff=="1"?true:false;
  }

  Floor485Data.fromHomlux(dynamic data, String modelNumber) {}
}

class Floor485Event extends Event {
  // 设定温度
  String targetTemp = "26";

  String currTemp = "30";

  // 开关状态
  String OnOff = "0";

  Floor485Event({
    required this.targetTemp,
    required this.currTemp,
    required this.OnOff,
  });

  factory Floor485Event.fromJson(Map<String, dynamic> json) {
    return Floor485Event(
      OnOff: json['OnOff'].toString(),
      targetTemp: json['targetTemp'].toString(),
      currTemp: json['currTemp'].toString(),

    );
  }

  Map<String, dynamic> toJson() {
    return {'OnOff': OnOff, 'targetTemp': targetTemp, 'currTemp': currTemp};
  }
}
