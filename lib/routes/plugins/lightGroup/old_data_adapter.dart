import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../models/device_entity.dart';
import '../../../common/adapter/device_card_data_adapter.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import '../../../common/homlux/models/homlux_group_entity.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../widgets/event_bus.dart';
import 'api.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceID = "";
  String deviceName = "灯光分组";
  //-------
  num brightness = 1; // 亮度
  num colorTemp = 0; // 色温
  var power = false; //开关
  var isColorful = false;

  void setDetailMeiJu(Map<String, dynamic> detail) {
    brightness = detail["brightness"];
    colorTemp = detail["colorTemperature"];
    power = detail["switchStatus"] == "1";

    deviceEnt!.detail!["detail"] = detail;
  }

  void setDetailHomlux(HomluxGroupEntity detail) {
    brightness = detail.controlAction?[0].brightness as num;
    colorTemp = detail.controlAction?[0].colorTemperature as num;
    power = detail.controlAction?[0].power == 1;
  }

  setIsColorFul() async {
    var isColorfulRes = await LightGroupApi.isColorful(deviceEnt!);
    isColorful = isColorfulRes;
  }

  @override
  String toString() {
    return jsonEncode({
      "deviceEnt": deviceEnt?.toJson(),
      "deviceID": deviceID,
      "power": power,
      "brightness": brightness,
      "colorTemp": colorTemp,
      "isColorful": isColorful
    });
  }

}

class LightGroupDataAdapter extends DeviceCardDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  final BuildContext context;

  Timer? delayTimer;

  LightGroupDataAdapter(super.platform, this.context, String deviceId) {
    device.deviceID = deviceId;
    type = AdapterType.lightGroup;
  }

  @override
  void init() {
    // if (device.deviceID.isNotEmpty) {
    //   if (platform.inMeiju()) {
    //     device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);
    //     device.setIsColorFul();
    //
    //     var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
    //     if (data["detail"]["detail"] != null) {
    //       device.setDetailMeiJu(data["detail"]["detail"]);
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
      LightGroupApi.getLightDetail(device.deviceEnt!).then((res) {
        device.setDetailMeiJu(res.result["result"]["group"]);
        updateUI();
        /// 更新DeviceListModel
        // if (device.deviceEnt != null) {
        //   context.read<DeviceListModel>().setProviderDeviceInfo(device.deviceEnt!);
        // }
      });
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.queryGroupByGroupId(device.deviceID);
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
      var res = await LightGroupApi.powerPDM(device.deviceEnt!, device.power);
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.power = !device.power;
        updateUI();
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightOnOff(device.deviceID, device.power ? 1 : 0);
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.power = !device.power;
        updateUI();
      }
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    var exValue = device.brightness;
    device.brightness = value;
    updateUI();
    if (platform.inMeiju()) {
      var res = await LightGroupApi.brightnessPDM(device.deviceEnt!, value);
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.brightness = exValue;
        updateUI();
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightBrightness(device.deviceID, value.toInt());
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.brightness = exValue;
        updateUI();
      }
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    var exValue = device.colorTemp;
    device.colorTemp = value;
    updateUI();
    if (platform.inMeiju()) {
      var res = await LightGroupApi.colorTemperaturePDM(device.deviceEnt!, value);
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.colorTemp = exValue;
        updateUI();
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlGroupLightColorTemp(device.deviceID, value.toInt());
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.colorTemp = exValue;
        updateUI();
      }
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