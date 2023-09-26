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

class CACDataAdapter extends DeviceCardDataAdapter<CAC485Data> {
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
  bool isLocalDevice = false;

  CAC485Data? data = CAC485Data(
      name: "",
      currTemp: "28",
      targetTemp: "26",
      operationMode: "1",
      OnOff: "0",
      windSpeed: "1");

  DataState dataState = DataState.NONE;

  String localDeviceCode="";

  CACDataAdapter(super.platform, this.name, this.applianceCode, this.masterId, this.modelNumber) {
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
          updateUI();
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
  }

  Future<void> orderPower(int onOff) async {
    if(nodeId!=null){
      bus.emit('operateDevice', nodeId);
      if(nodeId.split('-')[0]==System.macAddress){
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirConditionPower(
            onOff.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderPowerMeiju(onOff);
        }
      }else{
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderPowerMeiju(onOff);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485AirConditionPower(
              onOff.toString(), applianceCode);
        }
      }
    }else if(applianceCode.length==4){
      deviceLocal485ControlChannel.controlLocal485AirConditionPower(
          onOff.toString(), applianceCode);
    }
  }

  Future<void> orderMode(int mode) async {
    if(nodeId!=null){
      bus.emit('operateDevice', nodeId);
      if(nodeId.split('-')[0]==System.macAddress){
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirConditionModel(
            mode.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderModeMeiju(mode);
        }
      }else{
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderModeMeiju(mode);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485AirConditionModel(
              mode.toString(), applianceCode);
        }
      }
    }else if(applianceCode.length==4){
      deviceLocal485ControlChannel.controlLocal485AirConditionModel(
          mode.toString(), applianceCode);
    }

  }

  Future<void> orderTemp(int temp) async {
    if(nodeId!=null){
      bus.emit('operateDevice', nodeId);
      if(nodeId.split('-')[0]==System.macAddress){
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirConditionTemper(
            temp.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderTempMeiju(temp);
        }
      }else{
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderTempMeiju(temp);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485AirConditionTemper(
              temp.toString(), applianceCode);
        }
      }
    }else if(applianceCode.length==4){
      deviceLocal485ControlChannel.controlLocal485AirConditionTemper(
          temp.toString(), applianceCode);
    }
  }

  Future<void> orderSpeed(int speed) async {
    if(nodeId!=null){
      bus.emit('operateDevice', nodeId);
      if(nodeId.split('-')[0]==System.macAddress){
        localDeviceCode = nodeId.split('-')[1];
        deviceLocal485ControlChannel.controlLocal485AirConditionWindSpeed(
            speed.toString(), localDeviceCode);
        if (platform.inMeiju()) {
          fetchOrderSpeedMeiju(speed);
        }
      }else{
        if (isLocalDevice == false) {
          if (platform.inMeiju()) {
            fetchOrderSpeedMeiju(speed);
          }
        } else {
          deviceLocal485ControlChannel.controlLocal485AirConditionWindSpeed(
              speed.toString(), applianceCode);
        }
      }
    }else if(applianceCode.length==4){
      deviceLocal485ControlChannel.controlLocal485AirConditionWindSpeed(
          speed.toString(), applianceCode);
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
    if (nodeId == args.nodeId) {
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
            i < deviceList!.nameValuePairs!.airConditionList!.length;
            i++) {
          if ("${(deviceList!.nameValuePairs!.airConditionList![i].outSideAddress)!}${(deviceList!.nameValuePairs!.airConditionList![i].inSideAddress)!}" ==
              applianceCode) {
            String? targetTemp = deviceList!
                .nameValuePairs!.airConditionList![i].currTemperature;
            String? currTemp =
                deviceList!.nameValuePairs!.airConditionList![i].temperature;
            String? operationMode =
                deviceList!.nameValuePairs!.airConditionList![i].workModel;
            String? OnOff =
                deviceList!.nameValuePairs!.airConditionList![i].onOff;
            String? windSpeed =
                deviceList!.nameValuePairs!.airConditionList![i].windSpeed;
            data = CAC485Data(
                name: name,
                currTemp: int.parse(currTemp!, radix: 16).toString()!,
                targetTemp: int.parse(targetTemp!, radix: 16).toString()!,
                operationMode: int.parse(operationMode!, radix: 16).toString()!,
                OnOff: OnOff!,
                windSpeed: int.parse(windSpeed!, radix: 16).toString()!);
          }
        }
      } else {
        data = CAC485Data(
            name: name,
            currTemp: "28",
            targetTemp: "26",
            operationMode: "4",
            OnOff: "0",
            windSpeed: "1");
      }
    }
  }

  void _local485StateCallback(Local485DeviceState state) {
    if(state.modelId=="zhonghong.cac.002"&&localDeviceCode==state.address){
     data = CAC485Data(
         name: name,
         currTemp: state.currTemperature.toString(),
         targetTemp: state.temper.toString(),
         operationMode: state.mode.toString(),
         OnOff: state.onOff.toString(),
         windSpeed: state.speed.toString());
     updateUI();
   }
  }

  @override
  void destroy() {
    deviceLocal485ControlChannel.unregisterLocal485CallBack(_local485StateCallback);
    bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(handle);
  }

  Future<NodeInfo<Endpoint<CAC485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<CAC485Event>> nodeInfo = await MeiJuDeviceApi.getGatewayInfo<CAC485Event>(
              applianceCode, masterId, (json) => CAC485Event.fromJson(json));
      nodeId = nodeInfo.nodeId;
      localDeviceCode = nodeId.split('-')[1];
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
