import 'dart:async';
import 'dart:developer';


import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/homlux/api/homlux_device_api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/homlux/models/homlux_response_entity.dart';
import '../../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/meiju/api/meiju_device_api.dart';
import '../../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/util/deviceEntityTypeInP4Handle.dart';

class GasWaterHeaterDataEntity {
  bool power = false; //开关
  bool coldWater = false; //零冷水
  String mode = ""; //模式
  int temperature = 0; //温度
  int endTimeHour = 0; //加热剩余小时
  int endTimeMinute=0;//加热剩余分钟
  int curTemperature=0;//


  num minTemperature = 32; //可设置的最小温度
  num maxTemperature = 65; //可设置的最大温度

  GasWaterHeaterDataEntity({
    required power,
    required coldWater,
    required mode,
    required temperature,
    required endTimeHour,
    required endTimeMinute,
    required curTemperature,
    required String workState,

  });

  GasWaterHeaterDataEntity.fromMeiJu(dynamic data) {
    power = data["power"] == "on";
    coldWater = getColdWaterFromData(data);
    temperature = data["temperature"]??35;
    endTimeHour= data["end_time_hour"]??0;
    endTimeMinute= data["end_time_minute"]??0;
    curTemperature=data["cur_temperature"]??30;
  }

  bool getColdWaterFromData(dynamic data){
    if(data.containsKey("cold_water_master")){
      return data["cold_water_master"]== "on";
    }else{
      return false;
    }
  }

  GasWaterHeaterDataEntity.fromHomlux(HomluxDeviceEntity data) {

  }

  Map<String, dynamic> toJson() {
    return {
      "power": power,
      "coldWater": coldWater,
      "mode": mode,
      "temperature": temperature,
      "endTimeHour": endTimeHour,
      "endTimeMinute": endTimeMinute,
      "curTemperature": curTemperature,
    };
  }
}

class GasWaterHeaterDataAdapter extends DeviceCardDataAdapter<GasWaterHeaterDataEntity> {
  String deviceName = "燃热水器";
  String applianceCode = "";

  dynamic _meijuData = null;

  HomluxDeviceEntity? _homluxData = null;

  GasWaterHeaterDataEntity? data = GasWaterHeaterDataEntity(
    power: false,
    coldWater:false,
    mode: "",
    temperature: 35,
    endTimeHour : 0,
    endTimeMinute: 0,
    curTemperature: 35,
    workState:"",
  );


  GasWaterHeaterDataAdapter(super.platform, this.applianceCode) {
    type = AdapterType.wifiRanre;
  }

  @override
  void init() {
    _startPushListen();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "power": data!.power,
      "coldWater":data!.coldWater,
      "mode": data!.mode,
      "temperature": data!.temperature,
      "endTimeHour": data!.endTimeHour,
      "endTimeMinute": data!.endTimeMinute,
    };
  }

  @override
  bool getPowerStatus() {
    Log.i('获取燃热开关状态', data!.power);
    return data!.power;
  }

  @override
  String getDeviceId() {
    return applianceCode;
  }

  @override
  String? getCharacteristic() {
    if (dataState != DataState.SUCCESS) return '45℃';
    return "${data!.temperature}℃";
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  @override
  Future<void> tryOnce() async {
    controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    return controlTemperature(value as num);
  }

  @override
  Future<dynamic> reduceTo(int? value) async {
    int? target = value;
    return controlTemperature(target as num);
  }

  @override
  Future<dynamic> increaseTo(int? value) async {
    int? target = value;
    return controlTemperature(target as num);
  }


  /// 防抖刷新
  void _throttledFetchData() {
    fetchData();
  }

  @override
  /// 查询状态
  Future<void> fetchData() async {
    try {
      dataState = DataState.LOADING;
      updateUI();
      if (platform.inMeiju()) {
        _meijuData = await fetchMeijuData();
      } else if (platform.inHomlux()) {
        _homluxData= await fetchHomluxData();
      }
      if (_meijuData != null) {
        data = GasWaterHeaterDataEntity.fromMeiJu(_meijuData!);
      } else if (_homluxData != null) {
        data = GasWaterHeaterDataEntity.fromHomlux(_homluxData!);
      } else {
        dataState = DataState.ERROR;
        data = GasWaterHeaterDataEntity(
          power: false,
          coldWater:false,
          //开关
          mode: "",
          //模式
          temperature: 35,
          //温度
          endTimeHour : 0,
          //室内温度
          endTimeMinute: 0,

          curTemperature: 35,

          workState: "",
        );
        updateUI();
        return;
      }
      dataState = DataState.SUCCESS;
      updateUI();
    } catch (e) {
      // Error occurred while fetching data
      dataState = DataState.ERROR;
      updateUI();
      Log.i(e.toString());
    }
  }

  Future<dynamic> fetchMeijuData() async {
    try {
      var nodeInfo = await MeiJuDeviceApi.getDeviceDetail('0xE3', applianceCode);
      return nodeInfo.data;
    } catch (e) {
      Log.i('getNodeInfo Error', e);
      dataState = DataState.ERROR;
      updateUI();
      return null;
    }
  }

  Future<HomluxDeviceEntity?> fetchHomluxData() async {
    HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes =
    await HomluxDeviceApi.queryDeviceStatusByDeviceId(applianceCode);
    HomluxDeviceEntity? nodeInfo = nodeInfoRes.result;
    if (nodeInfo != null) {
      return nodeInfo;
    } else {
      return null;
    }
  }


  /// 控制开关
  Future<void> controlPower() async {
    data!.power = !data!.power;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xE3',
          applianceCode: applianceCode,
          command: {"power": data!.power ? 'on' : 'off'});
      if (res.isSuccess) {
      } else {
        data!.power = !data!.power;
      }
    } else if (platform.inHomlux()) {
    }
  }


  /// 控制温度
  Future<void> controlTemperature(num value) async {
    int lastTemp = data!.temperature;
    data!.temperature = value.toInt();
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xE3',
          applianceCode: applianceCode,
          command: {
            "temperature": data!.temperature
          });
      if (res.isSuccess) {
      } else {
        data!.temperature = lastTemp;
      }
    } else if (platform.inHomlux()) {

    }
  }

  /// 控制模式
  Future<void> controlMode(String mode) async {
    String lastMode = data!.mode;
    data!.mode = mode;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xE3',
          applianceCode: applianceCode,
          command: mode!="bath"?{"mode": mode}:{"mode":null});
      if (res.isSuccess) {
      } else {
        data!.mode = lastMode;
      }
    } else if (platform.inHomlux()) {
    }
  }

  /// 控制零冷水
  Future<void> controlColdWater(bool coldWater) async {
    data!.coldWater = coldWater;
    updateUI();
    if (platform.inMeiju()) {
      var res = await MeiJuDeviceApi.sendLuaOrder(
          categoryCode: '0xE3',
          applianceCode: applianceCode,
          command: {
            "cold_water_master": coldWater ? 'on' : 'off'
          });
      if (res.isSuccess) {
      } else {
        data!.coldWater = coldWater;
      }
    } else if (platform.inHomlux()) {
    }
  }

  void meijuPush(MeiJuWifiDevicePropertyChangeEvent args) {
    if (args.deviceId == applianceCode) {
      _throttledFetchData();
    }
  }

  void homluxPush(HomluxDevicePropertyChangeEvent arg) {
    if (arg.deviceInfo.eventData?.deviceId == applianceCode) {
      _throttledFetchData();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn<HomluxDevicePropertyChangeEvent>(homluxPush);
      Log.develop('$hashCode bind');
    } else {
      bus.typeOn<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff<HomluxDevicePropertyChangeEvent>(homluxPush);
      Log.develop('$hashCode unbind');
    } else {
      bus.typeOff<MeiJuWifiDevicePropertyChangeEvent>(meijuPush);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

}
