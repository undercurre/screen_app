import '../../../../channel/index.dart';
import '../../../../channel/models/local_485_device_state.dart';
import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../common/system.dart';
import '../../../../common/utils.dart';
import '../../../../widgets/event_bus.dart';

class AirDataAdapter extends DeviceCardDataAdapter<Air485Data> {
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
  bool isLocalDevice=false;


  Air485Data? data = Air485Data(
      name: "新风",
      online: true,
      operationMode: 1,
      OnOff: true,
      windSpeed: 1);

  DataState dataState = DataState.NONE;

  String localDeviceCode="0000";


  AirDataAdapter(super.platform, this.name, this.applianceCode, this.masterId, this.modelNumber) {
    type = AdapterType.air485;
  }

  // Method to retrieve data from both platforms and construct PanelData object
  @override
  Future<void> fetchData() async {
    if(isLocalDevice==false){
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
              online: true,
              operationMode: 4,
              OnOff: true,
              windSpeed: 1);
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
            online: true,
            operationMode: 4,
            OnOff: true,
            windSpeed: 1);
        updateUI();
      }
    } else {
      deviceLocal485ControlChannel.get485DeviceStateByAddr(localDeviceCode,"zhonghong.air.001");
    }
  }

  Future<void> orderPower(int onOff) async {

    if (localDeviceCode.isNotEmpty&&isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirFreshPower(
          onOff.toString(), localDeviceCode);
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485AirFreshPower(
          onOff.toString(), localDeviceCode);
    } else if (nodeId.isNotEmpty) {
      bus.emit('operateDevice', nodeId);
      if (nodeId.split('-')[0] == System.macAddress) {
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirFreshPower(
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
          deviceLocal485ControlChannel.controlLocal485AirFreshPower(
              onOff.toString(), localDeviceCode);
        }
      }
    }
  }

  Future<void> orderSpeed(int speed) async {
    if (localDeviceCode.isNotEmpty&&isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirFreshWindSpeed(
          speed.toString(), localDeviceCode);
    } else if (applianceCode.length == 4) {
      deviceLocal485ControlChannel.controlLocal485AirFreshWindSpeed(
          speed.toString(), localDeviceCode);
    } else if (nodeId.isNotEmpty) {
      bus.emit('operateDevice', nodeId);
      if (nodeId.split('-')[0] == System.macAddress) {
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirFreshWindSpeed(
            speed.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderSpeedMeiju(speed);
        }
      } else {
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderSpeedMeiju(speed);

          }
        } else {
          deviceLocal485ControlChannel.controlLocal485AirFreshWindSpeed(
              speed.toString(), localDeviceCode);
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
    deviceLocal485ControlChannel.registerLocal485CallBack(_local485StateCallback);
    getLocalDeviceCode();
    _startPushListen();
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
    if(state.modelId=="zhonghong.air.001"&&localDeviceCode==state.address){
      data = Air485Data(
          name: name,
          online: state.online==1?true:false,
          operationMode: state.mode,
          OnOff: state.onOff==1?true:false,
          windSpeed: state.speed);
      updateUI();
    }else if(state.modelId=="zhonghong.air.001"&&applianceCode==state.address){
      data = Air485Data(
          name: name,
          online: state.online==1?true:false,
          operationMode: state.mode,
          OnOff: state.onOff==1?true:false,
          windSpeed: state.speed);
      updateUI();
    }
  }

  @override
  void destroy() {
    deviceLocal485ControlChannel.unregisterLocal485CallBack(_local485StateCallback);
    _stopPushListen();
  }

  Future<NodeInfo<Endpoint<Air485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<Air485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<Air485Event>(
              applianceCode, masterId, (json) => Air485Event.fromJson(json));
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

  Future<void> getLocalDeviceCode() async {
    nodeId = await LocalStorage.getItem(applianceCode) ?? "";
    String macAddr = await aboutSystemChannel.getMacAddress();
    System.macAddress=macAddr.replaceAll(":", "").toUpperCase();
    if(applianceCode.length!=4){
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
    }else{
      isLocalDevice = true;
      localDeviceCode=applianceCode;
    }
  }

}

// The rest of the code for PanelData class remains the same as before
class Air485Data {
  // 空调名称
  String name = '485新风';

  // 当前室温
  int currTemp = 28;

  // 设定温度
  int targetTemp = 26;

  // 运行模式
  int operationMode = 1;

  // 开关状态
  bool OnOff = false;

  bool online = true;

  //风速
  int windSpeed = 1;

  Air485Data(
      {required this.name,
      required this.operationMode,
      required this.OnOff,
        required this.online,
        required this.windSpeed});

  Air485Data.fromMeiJu(
      NodeInfo<Endpoint<Air485Event>> data, String modelNumber) {
    name = data.endList[0].name ?? "新风";
    operationMode = int.parse(data.endList[0].event.operationMode);
    OnOff = data.endList[0].event.OnOff=="1"?true:false;
    windSpeed = int.parse(data.endList[0].event.windSpeed);
    online = true;
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
      OnOff: json['OnOff'].toString(),
      operationMode: json['operationMode'].toString(),
      windSpeed: json['windSpeed'].toString(),
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
