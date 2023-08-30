import 'dart:async';
import 'dart:convert';

import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../widgets/event_bus.dart';
import 'api.dart';

class DeviceDataEntity {
  String deviceID = "";
  String deviceName = "空调";
  //-------
  bool power = false; //开关
  String mode = "auto"; //模式
  int temperature = 26; //温度
  double smallTemperature = 0.5; //温度小数
  int wind = 102; // 风速

  void setDetail(Map<String, dynamic> detail) {
    power = detail["power"] == "on";
    mode = detail["mode"];
    temperature = detail["temperature"];
    smallTemperature = double.parse(detail["small_temperature"].toString());
    wind = detail["wind_speed"];
  }

  @override
  String toString() {
    return jsonEncode({
      "deviceID": deviceID,
      "power": power,
      "mode": mode,
      "temperature": temperature,
      "smallTemperature": smallTemperature,
      "wind": wind
    });
  }
}

class WIFIAirDataAdapter extends DeviceCardDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  Timer? delayTimer;

  WIFIAirDataAdapter(String deviceId) : super(GatewayPlatform.MEIJU) {
    device.deviceID = deviceId;
    type = AdapterType.wifiAir;
  }

  @override
  void init() {
    _startPushListen();
    updateDetail();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "power": device.power,
      "temperature": device.temperature,
      "smallTemperature": device.smallTemperature
    };
  }

  @override
  String? getStatusDes() {
    return "${device.temperature + device.smallTemperature}℃";
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  /// 查询状态
  Future<void> updateDetail() async {
    var res = await AirConditionApi.getAirConditionDetail(device.deviceID);
    if (res.code == 0) {
      Map<String, dynamic> detail =  res.result ?? {};
      Log.i("lmn>>> updateDetail detail=${detail.toString()}");
      device.setDetail(detail);
      updateUI();
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    device.power = !device.power;
    updateUI();

    var res = await AirConditionApi.powerLua(device.deviceID, device.power);
    if (!res.isSuccess) {
      device.power = !device.power;
      updateUI();
    }
    _delay2UpdateDetail(2);
  }

  /// 控制档位
  Future<void> controlGear(num value) async {
    var exValue = device.wind;
    device.wind = value.toInt() > 0 ? (value.toInt() - 1) * 20 : 1;
    updateUI();

    var res = await AirConditionApi.gearLua(device.deviceID, value > 0 ? (value - 1) * 20 : 1);
    if (!res.isSuccess) {
      device.wind = exValue;
      updateUI();
    }
    _delay2UpdateDetail(2);
  }

  /// 控制温度
  Future<void> controlTemperature(num value) async {
    device.temperature = value.toInt();
    device.smallTemperature = value.toDouble() - device.temperature;
    updateUI();

    var res = await AirConditionApi.temperatureLua(device.deviceID, device.temperature, device.smallTemperature);
    if (!res.isSuccess) {
    }
    _delay2UpdateDetail(2);
  }

  /// 控制模式
  Future<void> controlMode(String mode) async {
    device.mode = mode;
    updateUI();

    var res = await AirConditionApi.modeLua(device.deviceID, mode);
    if (!res.isSuccess) {
    }
    _delay2UpdateDetail(2);
  }

  void _delay2UpdateDetail(int? sec) {
    delayTimer?.cancel();
    delayTimer = Timer(Duration(seconds: sec ?? 2), () {
      updateDetail();
      delayTimer = null;
    });
  }

  void statusChangePushHomlux(HomluxDevicePropertyChangeEvent event) {
    if (event.deviceInfo.eventData?.deviceId == device.deviceID) {
      updateDetail();
    }
  }

  void statusChangePushMieJu(MeiJuWifiDevicePropertyChangeEvent event) {
    if (event.deviceId == device.deviceID) {
      updateDetail();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn(statusChangePushHomlux);
    } else if(platform.inMeiju()) {
      bus.typeOn(statusChangePushMieJu);
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff(statusChangePushHomlux);
    } else if(platform.inMeiju()) {
      bus.typeOff(statusChangePushMieJu);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

}