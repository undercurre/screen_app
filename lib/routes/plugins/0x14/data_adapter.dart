import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/adapter/midea_data_adapter.dart';
import '../../../common/homlux/api/homlux_device_api.dart';
import '../../../common/homlux/models/homlux_device_entity.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';
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

  void setDetailHomlux(HomluxDeviceEntity detail) {
    curtainPosition = int.parse(detail.mzgdPropertyDTOList?.x1?.curtainPosition ?? "0");
    curtainStatus = detail.mzgdPropertyDTOList?.x1?.curtainStatus ?? "stop";
    curtainDirection = detail.mzgdPropertyDTOList?.x1?.curtainDirection ?? "positive";
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

  final BuildContext context;

  Timer? delayTimer;

  WIFICurtainDataAdapter(super.platform, this.context, String deviceId) {
    device.deviceID = deviceId;
  }

  @override
  void init() {
    if (device.deviceID.isNotEmpty) {
      if (platform.inMeiju()) {
        device.deviceEnt = context.read<DeviceListModel>().getDeviceInfoById(device.deviceID);

        var data = context.read<DeviceListModel>().getDeviceDetailById(device.deviceID);
        if (data.isNotEmpty) {
          device.deviceName = data["deviceName"];
          device.setDetailMeiJu(data['detail']);
        }
      } else if (platform.inHomlux()) {

      }
    }
    _startPushListen();
    updateDetail();
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

  /// 控制模式
  Future<void> controlMode(Mode mode) async {
    device.curtainStatus = mode.key;
    if (mode.key == 'open') {
      device.curtainPosition = 100;
    } else if (mode.key == 'close') {
      device.curtainPosition = 0;
    }
    updateUI();
    if (platform.inMeiju()) {
      CurtainApi.setMode(device.deviceID, mode.key, device.curtainDirection);
    } else if(platform.inHomlux()) {
      if (mode.key == "stop") {
        HomluxDeviceApi.controlWifiCurtainStop(device.deviceID, "3");
      } else {
        HomluxDeviceApi.controlWifiCurtainOnOff(device.deviceID, "3", mode.key == 'open' ? 1 : 0);
      }
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

  void statusChangePushHomlux(HomluxDevicePropertyChangeEvent event) {
    if (event.deviceInfo.eventData?.deviceId == device.deviceID) {
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