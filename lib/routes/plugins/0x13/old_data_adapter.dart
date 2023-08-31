import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import '../../../common/homlux/models/homlux_device_entity.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../models/device_entity.dart';
import '../../../models/mz_response_entity.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/plugins/mode_card.dart';
import '../../home/device/service.dart';
import 'api.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceID = "";
  String deviceName = "吸顶灯";
  //-------
  num brightness = 1; // 亮度
  var colorTemp = 0; // 色温
  var power = false; //开关
  var screenModel = 'manual'; //模式
  var timeOff = 0; //延时关

  void setDetailMeiJu(Map<String, dynamic> detail) {
    if (deviceEnt?.sn8 == "79009833") {
      brightness = formatValue(detail["brightValue"] < 1 ? 1 : detail["brightValue"]);
      colorTemp = formatValue(detail["colorTemperatureValue"]);
      power = detail["power"];
      screenModel = detail["screenModel"];
      timeOff = detail["timeOff"];
    } else {
      brightness = formatValue(int.parse(detail["brightness"]) < 1 ? 1 : int.parse(detail["brightness"]));
      colorTemp = formatValue(int.parse(detail["color_temperature"]));
      power = detail["power"] == 'on';
      screenModel = detail["scene_light"] ?? 'manual';
      timeOff = int.parse(detail["delay_light_off"]);
    }
    deviceEnt?.detail = detail;
  }

  void setDetailHomlux(HomluxDeviceEntity detail) {
    brightness = detail.mzgdPropertyDTOList?.light?.brightness ?? 0;
    colorTemp = detail.mzgdPropertyDTOList?.light?.colorTemperature ?? 0;
    power = detail.mzgdPropertyDTOList?.light?.wifiLightPower == "on"
        || detail.mzgdPropertyDTOList?.light?.power == 1;
    screenModel = detail.mzgdPropertyDTOList?.light?.wifiLightScene ?? "manual";
    timeOff = int.parse(detail.mzgdPropertyDTOList?.light?.wifiLightDelayOff ?? "0");
  }

  @override
  String toString() {
    return jsonEncode({
      "deviceEnt": deviceEnt?.toJson(),
      "deviceID": deviceID,
      "power": power,
      "brightness": brightness,
      "colorTemp": colorTemp,
      "screenModel": screenModel,
      "timeOff": timeOff
    });
  }

  int formatValue(num value) {
    return int.parse((value / 255 * 100).toStringAsFixed(0));
  }
}

class WIFILightDataAdapter extends DeviceCardDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  final BuildContext context;

  Timer? delayTimer;

  WIFILightDataAdapter(super.platform, this.context, String deviceId) {
    device.deviceID = deviceId;
    type = AdapterType.wifiLight;
  }

  @override
  void init() {
    // if (device.deviceID.isNotEmpty) {
    //   if (platform.inMeiju()) {
    //     device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);
    //
    //     var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
    //     if (data.isNotEmpty) {
    //       device.deviceName = data["deviceName"];
    //       device.setDetailMeiJu(data['detail']);
    //     }
    //   } else if (platform.inHomlux()) {
    //
    //   }
    // }
    _startPushListen();
    updateDetail();
  }

  @override
  Map<String, dynamic>? getCardStatus() {
    return {
      "power": device.power,
      "brightness": device.brightness,
      "colorTemp": device.colorTemp
    };
  }

  @override
  String? getStatusDes() {
    return "${device.brightness}%";
  }

  @override
  Future<void> power(bool? onOff) async {
    return controlPower();
  }

  @override
  Future<dynamic> slider1To(int? value) async {
    return controlBrightness(value as num, null);
  }

  @override
  Future<dynamic> slider2To(int? value) async {
    return controlColorTemperature(value as num, null);
  }

  /// 查询状态
  Future<void> updateDetail() async {
    if (platform.inMeiju()) {
      if (device.deviceEnt == null) {
        return;
      }
      DeviceService.getDeviceDetail(device.deviceEnt!).then((res) {
        device.setDetailMeiJu(res);
        updateUI();
        /// 更新DeviceListModel
        // if (device.deviceEnt != null) {
        //   context.read<DeviceListModel>().setProviderDeviceInfo(device.deviceEnt!);
        // }
      });
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.queryDeviceStatusByDeviceId(device.deviceID);
      if (res.isSuccess) {
        if (res.result == null) return;
        device.setDetailHomlux(res.result!);
        updateUI();
      }
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    device.power = !device.power;
    updateUI();

    if (platform.inMeiju()) {
      var res = await WIFILightApi.powerLua(device.deviceID, device.power);
      if (!res.isSuccess) {
        device.power = !device.power;
        updateUI();
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightOnOff(device.deviceID, "3", device.power ? 1 : 0);
      if (!res.isSuccess) {
        device.power = !device.power;
        updateUI();
      }
      _delay2UpdateDetail(2);
    }
  }

  /// 控制延时关
  Future<void> controlDelay() async {
    if (!device.power) return;
    if (platform.inMeiju()) {
      if (device.timeOff == 0) {
        late MzResponseEntity<dynamic> res;
        if (device.deviceEnt?.sn8 == '79009833') {
          res = await WIFILightApi.delayPDM(device.deviceID, true);
        } else {
          res = await WIFILightApi.delayLua(device.deviceID, true);
        }
        if (res.isSuccess) {
          device.timeOff = 3;
          updateUI();
        }
      } else {
        late MzResponseEntity<dynamic> res;
        if (device.deviceEnt?.sn8 == '79009833') {
          res = await WIFILightApi.delayPDM(device.deviceID, false);
        } else {
          res = await WIFILightApi.delayLua(device.deviceID, false);
        }
        if (res.isSuccess) {
          device.timeOff = 0;
          updateUI();
        }
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      if (device.timeOff == 0) {
        var res = await HomluxDeviceApi.controlWifiLightDelayOff(device.deviceID, "3", 3);
        if (res.isSuccess) {
          device.timeOff = 3;
          updateUI();
        }
      } else {
        var res = await HomluxDeviceApi.controlWifiLightDelayOff(device.deviceID, "3", 0);
        if (res.isSuccess) {
          device.timeOff = 0;
          updateUI();
        }
      }
      _delay2UpdateDetail(2);
    }
  }

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    device.screenModel = mode.key;
    updateUI();
    if (platform.inMeiju()) {
      late MzResponseEntity<dynamic> res;
      if (device.deviceEnt?.sn8 == '79009833') {
        res = await WIFILightApi.modePDM(device.deviceID, mode.key);
      } else {
        res = await WIFILightApi.modeLua(device.deviceID, mode.key);
      }
      if (res.isSuccess) {
        device.screenModel = mode.key;
        updateUI();
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightMode(device.deviceID, "3", mode.key);
      if (res.isSuccess) {
        device.screenModel = mode.key;
        updateUI();
      }
      _delay2UpdateDetail(2);
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    device.brightness = value.toInt();
    updateUI();

    if (platform.inMeiju()) {
      if (device.deviceEnt?.sn8 == '79009833') {
        await WIFILightApi.brightnessPDM(device.deviceID, value);
      } else {
        await WIFILightApi.brightnessLua(device.deviceID, value);
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      HomluxDeviceApi.controlWifiLightBrightness(device.deviceID, "3", value.toInt());
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    device.colorTemp = value.toInt();
    updateUI();

    if (platform.inMeiju()) {
      if (device.deviceEnt?.sn8 == '79009833') {
        await WIFILightApi.colorTemperaturePDM(device.deviceID, value);
      } else {
        await WIFILightApi.colorTemperatureLua(device.deviceID, value);
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      HomluxDeviceApi.controlWifiLightColorTemp(device.deviceID, "3", value.toInt());
    }
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