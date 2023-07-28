import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/push.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_change_notifier.dart';
import '../../../widgets/plugins/mode_card.dart';
import '../../home/device/service.dart';
import 'api.dart';

class DeviceDataEntity {
  DeviceEntity? deviceEnt;
  String deviceID = "";
  String deviceName = "智能窗帘";
  String deviceType = '0x14';
  //-------
  int curtainPosition = 0;
  String curtainStatus = 'stop';
  String curtainDirection = 'positive';

  void setDetailMeiJu(Map<String, dynamic> detail) {
    curtainPosition = int.parse(detail['curtain_position']);
    curtainStatus = detail['curtain_status'];
    curtainDirection = detail['curtain_direction'];

    deviceEnt?.detail = detail;
  }

  @override
  String toString() {
    return jsonEncode({
      "deviceEnt": deviceEnt?.toJson(),
      "deviceID": deviceID,
      "curtainPosition": curtainPosition,
      "curtainStatus": curtainStatus,
      "curtainDirection": curtainDirection,
    });
  }
  
}

class WIFICurtainDataAdapter extends MideaDataAdapter {
  DeviceDataEntity device = DeviceDataEntity();

  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  final BuildContext context;

  Timer? delayTimer;

  WIFICurtainDataAdapter(super.platform, this.context);

  /// 初始化，开启推送监听
  void initAdapter() {
    Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
    device.deviceID = args?['deviceId'] ?? "";
    device.curtainPosition = args?['power'] ? 100 : 0;
    updateUI();

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
      // TODO
    }
  }

  /// 控制全开全关
  Future<void> controlMode(Mode mode) async {
    if (mode.key == 'open') {
      device.curtainPosition = 100;
      device.curtainStatus = mode.key;
      updateUI();
    } else if (mode.key == 'close'){
      device.curtainPosition = 0;
      device.curtainStatus = mode.key;
      updateUI();
    }
    if (platform.inMeiju()) {
      CurtainApi.setMode(device.deviceID, mode.key, device.curtainDirection);
    } else if(platform.inHomlux()) {
      HomluxDeviceApi.controlWifiCurtainOnOff(device.deviceID, "3", mode.key == 'open' ? 1 : 0);
    }
  }

  /// 控制位置
  Future<void> controlCurtain(num value) async {
    device.curtainPosition = value.toInt();
    updateUI();
    if (platform.inMeiju()) {
      CurtainApi.changePosition(device.deviceID, value, device.curtainPosition.toString());
    } else if (platform.inHomlux()) {
      HomluxDeviceApi.controlWifiCurtainPosition(device.deviceID, "3", value.toInt());
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