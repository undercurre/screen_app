import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/adapter/midea_data_adapter.dart';
import '../../../../common/homlux/api/homlux_device_api.dart';
import '../../../../common/homlux/models/homlux_device_entity.dart';
import '../../../../common/logcat_helper.dart';
import '../../../../common/push.dart';
import '../../../../models/device_entity.dart';
import '../../../../states/device_change_notifier.dart';
import '../../../../widgets/plugins/mode_card.dart';
import '../../../home/device/service.dart';
import 'api.dart';
import 'mode_list.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceID = "";
  String deviceName = "Zigbee智能灯";

  String deviceIDInDetail = "";
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

    deviceIDInDetail = detail["deviceId"];
    nodeId = detail["nodeId"];

    deviceEnt?.detail = detail;
  }

  void setDetailHomlux(HomluxDeviceEntity detail) {
    power = detail.mzgdPropertyDTOList?.x1?.onOff == 1;
    brightness = detail.mzgdPropertyDTOList?.x1?.level as num;
    colorTemp = detail.mzgdPropertyDTOList?.x1?.colorTemp as num;

  }

  @override
  String toString() {
    return jsonEncode({
      "deviceEnt": deviceEnt?.toJson(),
      "deviceID": deviceID,
      "deviceIDInDetail": deviceIDInDetail,
      "nodeId": nodeId,
      "power": power,
      "brightness": brightness,
      "colorTemp": colorTemp,
      "delayClose": delayClose
    });
  }

}

class ZigbeeLightDataAdapter extends MideaDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  final BuildContext context;

  Timer? delayTimer;

  ZigbeeLightDataAdapter(super.platform, this.context);

  /// 初始化，开启推送监听
  void initAdapter() {
    Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
    device.deviceID = args?['deviceId'] ?? "";
    if (device.deviceID.isNotEmpty) {
      device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);

      if (platform.inMeiju()) {
        var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
        if (data.isNotEmpty) {
          device.deviceName = data["deviceName"] ?? "";
          device.modelNumber = data["modelNumber"] ?? "";
          data['detail']["lightPanelDeviceList"][0]["attribute"] = args?['power'] ? 1 : 0;
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
      var res = await ZigbeeLightApi.powerPDM(device.deviceIDInDetail, device.power, device.nodeId);
      if (!res.isSuccess) {
        _delay2UpdateDetail(2);
      }
    } else if (platform.inHomlux()) {
      var res = await HomluxDeviceApi.controlZigbeeLightOnOff(device.nodeId, "2", device.deviceIDInDetail, device.power ? 1 : 0);
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
      await ZigbeeLightApi.delayPDM(device.deviceIDInDetail, !(device.delayClose == 0), device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeLightDelayOff(device.nodeId, "2", device.deviceIDInDetail, device.delayClose);
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
          device.deviceIDInDetail,
          curMode.brightness,
          curMode.colorTemperature,
          device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeColorTempAndBrightness(
          device.nodeId,
          "2",
          device.deviceIDInDetail,
          curMode.colorTemperature.toInt(),
          curMode.brightness.toInt()
      );
      _delay2UpdateDetail(2);
    }
  }

  /// 控制亮度
  Future<void> controlBrightness(num value, Color activeColor) async {
    device.brightness = value;
    device.fakeModel = "";
    updateUI();

    if (platform.inMeiju()) {
      await ZigbeeLightApi.adjustPDM(device.deviceIDInDetail, value, device.brightness, device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeBrightness(
          device.nodeId,
          "2",
          device.deviceIDInDetail,
          device.brightness.toInt()
      );
      _delay2UpdateDetail(2);
    }
  }

  /// 控制色温
  Future<void> controlColorTemperature(num value, Color activeColor) async {
    device.colorTemp = value;
    device.fakeModel = "";
    updateUI();
    if (platform.inMeiju()) {
      await ZigbeeLightApi.adjustPDM(device.deviceIDInDetail, device.colorTemp, value, device.nodeId);
      _delay2UpdateDetail(2);
    } else if (platform.inHomlux()) {
      await HomluxDeviceApi.controlZigbeeColorTemp(
          device.nodeId,
          "2",
          device.deviceIDInDetail,
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