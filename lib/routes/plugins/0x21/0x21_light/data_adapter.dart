import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/homlux/api/homlux_device_api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../../models/device_entity.dart';
import '../../../../states/device_change_notifier.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../../home/device/service.dart';
import 'api.dart';
import 'mode_list.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceName = "Zigbee智能灯";

  String masterId = "";
  String nodeId = "";
  String modelNumber = "";
  //-------
  num brightness = 1; // 亮度
  num colorTemp = 0; // 色温
  var power = false; //开关
  var delayClose = 0; //延时关

  var fakeModel = ''; //模式

  void setDetailMeiJu(Map<String, dynamic> detail) {
    brightness = detail["lightPanelDeviceList"][0]["brightness"] ?? 1;
    colorTemp = detail["lightPanelDeviceList"][0]["colorTemperature"] ?? 0;
    power = detail["lightPanelDeviceList"][0]["attribute"] == 1;
    delayClose = detail["lightPanelDeviceList"][0]["delayClose"];

    masterId = detail["deviceId"];
    nodeId = detail["nodeId"];

    deviceEnt?.detail = detail;
  }

  void setDetailHomlux(HomluxDeviceEntity detail) {
    power = detail.mzgdPropertyDTOList?.x1?.power == 1;
    brightness = detail.mzgdPropertyDTOList?.x1?.brightness as num;
    colorTemp = detail.mzgdPropertyDTOList?.x1?.colorTemperature as num;

  }

  @override
  String toString() {
    return jsonEncode({
      "deviceEnt": deviceEnt?.toJson(),
      "masterId": masterId,
      "nodeId": nodeId,
      "power": power,
      "brightness": brightness,
      "colorTemp": colorTemp,
      "delayClose": delayClose
    });
  }

}

class ZigbeeLightDataAdapter extends DeviceCardDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  final BuildContext context;

  Timer? delayTimer;

  ZigbeeLightDataAdapter(super.platform, this.context, String masterId, String nodeId) {
    device.masterId = masterId;
    device.nodeId = nodeId;
    type = AdapterType.zigbeeLight;
  }

  @override
  void init() {
    if (device.masterId.isNotEmpty) {
      if (platform.inMeiju()) {
        device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.masterId);

        var data = context.read<DeviceListModel>().getDeviceDetailById(device.masterId);
        if (data.isNotEmpty) {
          device.deviceName = data["deviceName"] ?? "";
          device.modelNumber = data["modelNumber"] ?? "";
          device.setDetailMeiJu(data['detail']);
        }
      } else if (platform.inHomlux()) {

      }
    }
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
        judgeModel();
        updateUI();
        /// 更新DeviceListModel
        if (device.deviceEnt != null) {
          context.read<DeviceListModel>().setProviderDeviceInfo(device.deviceEnt!);
        }
      });
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.queryDeviceStatusByDeviceId(device.nodeId);
      if(res.isSuccess) {
        if(res.result == null) return;
        device.setDetailHomlux(res.result!);
        judgeModel();
        updateUI();
      }
    }
  }

  judgeModel() {
    for (var element in lightModes) {
      var curMode = element as ZigbeeLightMode;
      if (device.brightness == curMode.brightness &&
          device.colorTemp == curMode.colorTemperature) {
        device.fakeModel = curMode.key;
      }
    }
  }

  /// 控制开关
  Future<void> controlPower() async {
    device.power = !device.power;
    updateUI();
    if (platform.inMeiju()) {
      var res = await ZigbeeLightApi.powerPDM(device.masterId, device.power, device.nodeId);
      if (!res.isSuccess) {
        _delay2UpdateDetail(2);
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeLightOnOff(device.nodeId, "2", device.masterId, device.power ? 1 : 0);
      if (!res.isSuccess) {
        _delay2UpdateDetail(2);
      }
    }
  }

  /// 控制延时关
  Future<void> controlDelay() async {
    if (!device.power) return;
    if (device.delayClose == 0) {
      device.delayClose = 3;
    } else {
      device.delayClose = 0;
    }
    updateUI();
    if (platform.inMeiju()) {
      await ZigbeeLightApi.delayPDM(device.masterId, !(device.delayClose == 0), device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeLightDelayOff(device.nodeId, "2", device.masterId, device.delayClose);
      _delay2UpdateDetail(2);
    }
  }

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    device.fakeModel = mode.key;
    updateUI();
    var curMode = lightModes
        .where((element) => element.key == device.fakeModel)
        .toList()[0] as ZigbeeLightMode;

    if (platform.inMeiju()) {
      await ZigbeeLightApi.adjustPDM(
          device.masterId,
          curMode.brightness,
          curMode.colorTemperature,
          device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeColorTempAndBrightness(
          device.nodeId,
          "2",
          device.masterId,
          curMode.colorTemperature.toInt(),
          curMode.brightness.toInt()
      );
      _delay2UpdateDetail(2);
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color? activeColor) async {
    device.brightness = value;
    device.fakeModel = "";
    updateUI();

    if (platform.inMeiju()) {
      await ZigbeeLightApi.adjustPDM(device.masterId, value, device.brightness, device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeBrightness(
          device.nodeId,
          "2",
          device.masterId,
          device.brightness.toInt()
      );
      _delay2UpdateDetail(2);
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color? activeColor) async {
    device.colorTemp = value;
    device.fakeModel = "";
    updateUI();
    if (platform.inMeiju()) {
      await ZigbeeLightApi.adjustPDM(device.masterId, device.colorTemp, value, device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeColorTemp(
          device.nodeId,
          "2",
          device.masterId,
          device.colorTemp.toInt()
      );
      _delay2UpdateDetail(2);
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
    if (event.deviceInfo.eventData?.deviceId == device.masterId) {
      updateDetail();
    }
  }

  void _startPushListen() {
    if (platform.inHomlux()) {
      bus.typeOn(statusChangePushHomlux);
    }
  }

  void _stopPushListen() {
    if (platform.inHomlux()) {
      bus.typeOff(statusChangePushHomlux);
    }
  }

  @override
  void destroy() {
    super.destroy();
    _stopPushListen();
  }

}