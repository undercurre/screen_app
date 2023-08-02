import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../models/device_entity.dart';
import '../../../../states/device_change_notifier.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import 'api.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceID = "";
  String deviceName = "灯光分组";
  String groupId = "";
  //-------
  num brightness = 1; // 亮度
  num colorTemp = 0; // 色温
  var power = false; //开关
  var isColorful = false;

  void setDetailMeiJu(Map<String, dynamic> detail) {
    brightness = detail["brightness"];
    colorTemp = detail["colorTemperature"];
    power = detail["switchStatus"] == "1";

    groupId = deviceEnt!.detail!["groupId"] ?? "";
    deviceEnt!.detail!["detail"] = detail;
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

class LightGroupDataAdapter extends MideaDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  // Function(Map<String,dynamic> arg)? _eventCallback;
  // Function(Map<String,dynamic> arg)? _reportCallback;

  final BuildContext context;

  Timer? delayTimer;

  LightGroupDataAdapter(super.platform, this.context);

  /// 初始化，开启推送监听
  void initAdapter() {
    Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
    device.deviceID = args?['deviceId'] ?? "";
    if (device.deviceID.isNotEmpty) {
      device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);
      device.setIsColorFul();

      if (platform.inMeiju()) {
        var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
        if (data["detail"]["detail"] != null) {
          device.setDetailMeiJu(data["detail"]["detail"]);
        }
      } else if (platform.inHomlux()) {
        // TODO

      }
    }

    Log.i("lmn>>> initAdapter:: ${device.toString()}");
    _startPushListen(context);
    _delay2UpdateDetail(1);
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
        if (device.deviceEnt != null) {
          context.read<DeviceListModel>().setProviderDeviceInfo(device.deviceEnt!);
        }
      });
    } else if (platform.inHomlux()) {
      // TODO
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
      var res = await HomluxDeviceApi.controlGroupLightOnOff(device.groupId, device.power ? 1 : 0);
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.power = !device.power;
        updateUI();
      }
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color activeColor) async {
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
      var res = await HomluxDeviceApi.controlGroupLightBrightness(device.groupId, value.toInt());
      if (res.isSuccess) {
        _delay2UpdateDetail(2);
      } else {
        device.brightness = exValue;
        updateUI();
      }
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color activeColor) async {
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
      var res = await HomluxDeviceApi.controlGroupLightColorTemp(device.groupId, value.toInt());
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

  void _startPushListen(BuildContext context) {
    // Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
    //   String event = (arg['event'] as String).replaceAll("\\\"", "\"");
    //   Map<String, dynamic> eventMap = json.decode(event);
    //   var detail = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
    //
    // }));
    // Push.listen("appliance/status/report", _reportCallback = ((arg) {
    //   var detail = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
    //   if (arg.containsKey('applianceId')) {
    //     if (detail['deviceId'] == arg['applianceId']) {
    //       updateDetail();
    //     }
    //   }
    // }));
  }

  void _stopPushListen() {
    // Push.dislisten("gemini/appliance/event", _eventCallback);
    // Push.dislisten("appliance/status/report", _reportCallback);
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

}