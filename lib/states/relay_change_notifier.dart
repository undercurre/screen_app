import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/index.dart';

import '../channel/index.dart';
import '../common/adapter/panel_data_adapter.dart';
import '../common/gateway_platform.dart';
import '../common/homlux/api/homlux_device_api.dart';
import '../common/homlux/models/homlux_device_entity.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/meiju/api/meiju_device_api.dart';
import '../common/models/endpoint.dart';
import '../common/models/node_info.dart';
import '../widgets/event_bus.dart';

class RelayModel extends ChangeNotifier {
  bool localRelay1 = false;
  bool localRelay2 = false;
  String localRelay1Name="灯1";
  String localRelay2Name="灯2";
  RelayModel() {
    gatewayChannel.relay2IsOpen()
        .then((value) => localRelay2 = value);
    gatewayChannel.relay1IsOpen()
        .then((value) => localRelay1 = value);

    bus.off("relay1StateChange", relay1StateChange);
    bus.off("relay2StateChange", relay2StateChange);
    bus.on("relay1StateChange", relay1StateChange);
    bus.on("relay2StateChange", relay2StateChange);

    getLocalRelayName();

  }

  void relay1StateChange(dynamic open) {
    localRelay1 = open as bool;
    notifyListeners();
  }

  void relay2StateChange(dynamic open) {
    localRelay2 = open as bool;
    notifyListeners();
  }

  // 控制Relay1
  void toggleRelay1() {
    localRelay1 = !localRelay1;
    gatewayChannel.controlRelay1Open(localRelay1);
    notifyListeners();
  }

  // 控制Relay2
  void toggleRelay2() {
    localRelay2 = !localRelay2;
    gatewayChannel.controlRelay2Open(localRelay2);
    notifyListeners();
  }

  void getLocalRelayName() async {
    if(MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX&&System.gatewayApplianceCode!=null){
        HomluxResponseEntity<HomluxDeviceEntity> nodeInfoRes =
        await HomluxDeviceApi.queryDeviceStatusByDeviceId(System.gatewayApplianceCode!);
        HomluxDeviceEntity? nodeInfo = nodeInfoRes.result;
        if (nodeInfo != null) {
          localRelay1Name=nodeInfo.switchInfoDTOList![0].switchName!;
          localRelay2Name=nodeInfo.switchInfoDTOList![1].switchName!;
          notifyListeners();
        }
    }
  }



}
