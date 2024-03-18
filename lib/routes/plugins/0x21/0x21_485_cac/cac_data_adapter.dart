import 'package:screen_app/common/homlux/api/homlux_device_api.dart';

import '../../../../channel/index.dart';
import '../../../../channel/models/local_485_device_state.dart';
import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/api/api.dart';
import '../../../../common/global.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/homlux/models/homlux_response_entity.dart';
import '../../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/models/meiju_response_entity.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../common/models/endpoint.dart';
import '../../../../common/models/node_info.dart';
import '../../../../common/system.dart';
import '../../../../common/utils.dart';
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
  HomluxDeviceEntity? _homluxData;
  String name;
  String applianceCode;
  String masterId;
  String nodeId = '';
  String modelNumber = '';
  bool isLocalDevice = false;

  CAC485Data? data = CAC485Data(
      name: "空调",
      online: true,
      currTemp: 28,
      targetTemp: 26,
      operationMode: 1,
      OnOff: true,
      windSpeed: 1);

  DataState dataState = DataState.NONE;

  String localDeviceCode = "0000";

  CACDataAdapter(super.platform, this.name, this.applianceCode, this.masterId,
      this.modelNumber) {
    type = AdapterType.CRC485;
  }

  // Method to retrieve data from both platforms and construct PanelData object
  @override
  Future<void> fetchData() async {
    if (isLocalDevice == false) {
      try {
        dataState = DataState.LOADING;
        if (platform.inMeiju()) {
          _meijuData = await fetchMeijuData();
          if(_meijuData != null) {
            data = CAC485Data.fromMeiJu(_meijuData, modelNumber);
          }
        } else {
          _homluxData = await fetchHomluxData();
          if (_homluxData != null) {
            data = CAC485Data.fromHomlux(_homluxData!, modelNumber);
          }
        }
        dataState = DataState.SUCCESS;
        if(data == null) {
          dataState = DataState.ERROR;
          data = CAC485Data(
              name: name,
              online: true,
              currTemp: 28,
              targetTemp: 26,
              operationMode: 4,
              OnOff: true,
              windSpeed: 1);
        }
        updateUI();
      } catch (e) {
        logger.i("485空调获取美居数据出错:${e.toString()}");
        // Error occurred while fetching data
        dataState = DataState.ERROR;
        data = CAC485Data(
            name: name,
            online: true,
            currTemp: 28,
            targetTemp: 26,
            operationMode: 4,
            OnOff: true,
            windSpeed: 1);
        updateUI();
      }
    } else {
      logger.i("485空调获取本地数据:$localDeviceCode");
      deviceLocal485ControlChannel.get485DeviceStateByAddr(
          localDeviceCode, "zhonghong.cac.002");
    }
  }

  Future<void> orderPower(int onOff) async {
    if (localDeviceCode.isNotEmpty && isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirConditionPower(
          onOff.toString(), localDeviceCode);
    } else {
      if (platform.inMeiju()) {
        bus.emit('operateDevice', nodeId);
        fetchOrderPowerMeiju(onOff);
      } else {
        bus.emit('operateDevice', applianceCode);
        fetchOrderPowerHomlux(onOff);
      }
    }
  }

  Future<void> orderMode(int mode) async {
    if (localDeviceCode.isNotEmpty && isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirConditionModel(
          mode.toString(), localDeviceCode);
    } else {
      if (platform.inMeiju()) {
        bus.emit('operateDevice', nodeId);
        fetchOrderModeMeiju(mode);
      } else {
        bus.emit('operateDevice', applianceCode);
        fetchOrderModeHomlux(mode);
      }
    }
  }

  Future<void> orderTemp(int temp) async {
    if (isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirConditionTemper(
          temp.toString(), localDeviceCode);
    } else {
      if (platform.inMeiju()) {
        bus.emit('operateDevice', nodeId);
        fetchOrderTempMeiju(temp);
      } else {
        bus.emit('operateDevice', applianceCode);
        fetchOrderTempHomlux(temp);
      }
    }
  }

  Future<void> orderSpeed(int speed) async {
    if (isLocalDevice) {
      deviceLocal485ControlChannel.controlLocal485AirConditionWindSpeed(
          speed.toString(), localDeviceCode);
    } else {
      if (platform.inMeiju()) {
        bus.emit('operateDevice', nodeId);
        fetchOrderSpeedMeiju(speed);
      } else {
        bus.emit('operateDevice', applianceCode);
        fetchOrderSpeedHomlux(speed);
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

  Future<HomluxResponseEntity> fetchOrderSpeedHomlux(int speed) async {
    return HomluxDeviceApi.control485AirWindSpeed(
        masterId, applianceCode, speed);
  }

  Future<HomluxResponseEntity> fetchOrderTempHomlux(int temp) async {
    return HomluxDeviceApi.control485AirTemp(masterId, applianceCode, temp);
  }

  Future<HomluxResponseEntity> fetchOrderModeHomlux(int mode) async {
    return HomluxDeviceApi.control485AirMode(masterId, applianceCode, mode);
  }

  Future<HomluxResponseEntity> fetchOrderPowerHomlux(int power) async {
    return HomluxDeviceApi.control485AirPower(masterId, applianceCode, power);
  }

  @override
  void init() {
    deviceLocal485ControlChannel.registerLocal485CallBack(_local485StateCallback);
    getLocalDeviceCode();
    _startPushListen();
  }

  void meijuPush(MeiJuSubDevicePropertyChangeEvent args) {
    if (nodeId == args.nodeId) {
      fetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent args) {
    if(!isLocalDevice && applianceCode == args.deviceInfo.eventData?.deviceId) {
      fetchData();
    }
  }

  void _startPushListen() {
    if (platform.inMeiju()) {
      bus.typeOn<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    } else {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
    }
  }

  void _stopPushListen() {
    if (platform.inMeiju()) {
      bus.typeOff<MeiJuSubDevicePropertyChangeEvent>(meijuPush);
    } else {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
    }
  }

  void _local485StateCallback(Local485DeviceState state) {
    if (state.modelId == "zhonghong.cac.002" &&
        localDeviceCode == state.address) {
      data = CAC485Data(
          name: name,
          online: state.online == 1 ? true : false,
          currTemp: state.currTemperature,
          targetTemp: state.temper,
          operationMode: state.mode,
          OnOff: state.onOff == 1 ? true : false,
          windSpeed: state.speed);
      updateUI();
    }
  }

  @override
  void destroy() {
    deviceLocal485ControlChannel
        .unregisterLocal485CallBack(_local485StateCallback);
    _stopPushListen();
  }

  Future<NodeInfo<Endpoint<CAC485Event>>> fetchMeijuData() async {
    try {
      NodeInfo<Endpoint<CAC485Event>> nodeInfo =
          await MeiJuDeviceApi.getGatewayInfo<CAC485Event>(
              applianceCode, masterId, (json) => CAC485Event.fromJson(json));
      nodeId = nodeInfo.nodeId;
      localDeviceCode = nodeId.split('-')[1];
      logger.i("拿到的nodeId:$nodeId----拿到的nodeInfo:$nodeInfo");
      LocalStorage.setItem(applianceCode, nodeId);
      if (nodeId.split('-')[0] == System.macAddress) {
        isLocalDevice = true;
      } else {
        isLocalDevice = false;
      }
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

  Future<HomluxDeviceEntity?> fetchHomluxData() async {
    try {
      // 请求云端数据
      HomluxResponseEntity<HomluxDeviceEntity> response = await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
      if(response.isSuccess && response.result != null) {
        return response.result;
      }
    } catch (e) {
      Log.e("485空调状态请求", e);
    }
    return null;
  }

  Future<void> getLocalDeviceCode() async {
    if(StrUtils.isNullOrEmpty(System.macAddress)) {
      String macAddr = await aboutSystemChannel.getMacAddress();
      System.macAddress = macAddr.replaceAll(":", "").toUpperCase();
    }
    if(platform.inMeiju()) {
      nodeId = await LocalStorage.getItem(applianceCode) ?? "";
      // "nodeId": "F43C3BD9001C-4204"
      if (nodeId.isNotEmpty) {
        localDeviceCode = nodeId.split('-')[1];
        if (nodeId.split('-')[0] == System.macAddress) {
          isLocalDevice = true;
        } else {
          isLocalDevice = false;
        }
      } else {
        isLocalDevice = false;
      }
    } else if(platform.inHomlux()) {
      // "deviceId": "F43C3BD9001C-4204"
      if(StrUtils.isNotNullAndEmpty(applianceCode)) {
        bool containResult = applianceCode.contains('-');
        assert(containResult, "云端设备id规则出错，需包含 -，当前设备id为$applianceCode");
        Log.e("wnp 当前设备 $applianceCode 为本地设备 $isLocalDevice");
        if(containResult) {
          var ids = applianceCode.split('-');
          localDeviceCode = ids[1];
          isLocalDevice = ids[0] == System.macAddress;
        }
      }
    }
  }
}

// The rest of the code for PanelData class remains the same as before
class CAC485Data {
  // 空调名称
  String name = '485空调';

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

  CAC485Data(
      {required this.name,
      required this.currTemp,
      required this.targetTemp,
      required this.operationMode,
      required this.OnOff,
      required this.online,
      required this.windSpeed});

  CAC485Data.fromMeiJu(
      NodeInfo<Endpoint<CAC485Event>> data, String modelNumber) {
    logger.i(
        "485空调获取美居数据开关状态:${data.endList[0].event.OnOff}---名称:${data.endList[0].name}---当前温度:${data.endList[0].event.currTemp}---模式:${data.endList[0].event.operationMode}---目标温度:${data.endList[0].event.targetTemp}---风速:${data.endList[0].event.windSpeed}");
    name = data.endList[0].name ?? "空调";
    currTemp = int.parse(data.endList[0].event.currTemp);
    targetTemp = int.parse(data.endList[0].event.targetTemp == "2600"
        ? "26"
        : data.endList[0].event.targetTemp);
    operationMode = int.parse(data.endList[0].event.operationMode);
    OnOff = data.endList[0].event.OnOff == "1" ? true : false;
    windSpeed = int.parse(data.endList[0].event.windSpeed);
    online = true;
  }

  CAC485Data.fromHomlux(HomluxDeviceEntity data, String modelNumber) {
    name = data.deviceName ?? "空调";
    operationMode = data.mzgdPropertyDTOList?.air485Conditioner?.mode ?? 0;
    OnOff = data.mzgdPropertyDTOList?.air485Conditioner?.OnOff == 1;
    windSpeed = data.mzgdPropertyDTOList?.air485Conditioner?.windSpeed ?? 0;
    online = data.onLineStatus == 1;
    currTemp = data.mzgdPropertyDTOList?.air485Conditioner?.windSpeed ?? 0;
    targetTemp = data.mzgdPropertyDTOList?.air485Conditioner?.targetTemperature ?? 0;
  }
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
      currTemp: json['currTemp'].toString(),
      OnOff: json['OnOff'].toString(),
      targetTemp: json['targetTemp'].toString(),
      operationMode: json['operationMode'].toString(),
      windSpeed: json['windSpeed'].toString(),
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
