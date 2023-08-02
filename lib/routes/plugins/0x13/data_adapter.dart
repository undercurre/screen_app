import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import '../../../common/homlux/models/homlux_device_entity.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/push.dart';
import '../../../models/device_entity.dart';
import '../../../models/mz_response_entity.dart';
import '../../../states/device_change_notifier.dart';
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
    brightness = detail.mzgdPropertyDTOList?.x1?.level as num;
    colorTemp = detail.mzgdPropertyDTOList?.x1?.colorTemp ?? 0;
    power = detail.mzgdPropertyDTOList?.x1?.onOff == 1;
    // screenModel = detail.mzgdPropertyDTOList?.x1?.buttonScene ?? "manual";
    timeOff = detail.mzgdPropertyDTOList?.x1?.delayClose ?? 0;
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

class WIFILightDataAdapter extends MideaDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  final BuildContext context;

  Timer? delayTimer;

  WIFILightDataAdapter(super.platform, this.context);

  /// 初始化，开启推送监听
  void initAdapter() {
    Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
    device.deviceID = args?['deviceId'] ?? "";
    if (device.deviceID.isNotEmpty) {
      device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);

      if (platform.inMeiju()) {
        var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
        if (data.isNotEmpty) {
          device.deviceName = data["deviceName"];
          device.setDetailMeiJu(data['detail']);
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
      DeviceService.getDeviceDetail(device.deviceEnt!).then((res) {
        device.setDetailMeiJu(res);
        updateUI();
        /// 更新DeviceListModel
        if (device.deviceEnt != null) {
          context.read<DeviceListModel>().setProviderDeviceInfo(device.deviceEnt!);
        }
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
    if (platform.inMeiju()) {
      late MzResponseEntity<dynamic> res;
      if (device.deviceEnt?.sn8 == '79009833') {
        res = await WIFILightApi.modePDM(device.deviceID, mode.key);
      } else {
        res = await WIFILightApi.modeLua(device.deviceID, mode.key);
      }
      if (res.isSuccess) {
        device.screenModel = mode.key;
      }
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlWifiLightMode(device.deviceID, "3", mode.key);
      if (res.isSuccess) {
        device.screenModel = mode.key;
      }
      _delay2UpdateDetail(2);
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color activeColor) async {
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
  Future<void> controlColorTemperature(num value, Color activeColor) async {
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

  void _startPushListen(BuildContext context) {
    Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
      String event = (arg['event'] as String).replaceAll("\\\"", "\"");
      Map<String, dynamic> eventMap = json.decode(event);
      String nodeId = eventMap['nodeId'] ?? "";
      var detail = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);

      if (nodeId.isEmpty) {
        if (detail['deviceId'] == arg['applianceCode']) {
          updateDetail();
        }
      } else {
        if ((detail['masterId'] as String).isNotEmpty && detail['detail']?['nodeId'] == nodeId) {
          updateDetail();
        }
      }
    }));
    Push.listen("appliance/status/report", _reportCallback = ((arg) {
      var detail = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
      if (arg.containsKey('applianceId')) {
        if (detail['deviceId'] == arg['applianceId']) {
          updateDetail();
        }
      }
    }));
  }

  void _stopPushListen() {
    Push.dislisten("gemini/appliance/event", _eventCallback);
    Push.dislisten("appliance/status/report", _reportCallback);
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

}