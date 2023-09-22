
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/common/adapter/bind_gateway_data_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/widgets/event_bus.dart';

import '../../common/homlux/push/event/homlux_push_event.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/push/event/meiju_push_event.dart';
import '../../common/system.dart';

mixin CheckGatewayBind<T extends StatefulWidget> on State<T> {

  Timer? checkGatewayTimer;

  void notifyMeiJuDeviceChange(dynamic event) {
    apiCheckLogout();
  }

  void notifyHomluxLogout(dynamic event) {
    System.logout('Homlux推送事件，用户退出登录');
  }

  void apiCheckLogout() {
    try {
      if (System.isLogin()) {
        var adapter = BindGatewayAdapter(MideaRuntimePlatform.platform);
        adapter.checkGatewayBindState(System.familyInfo!, (bind, code) {
          if (!bind && System.isLogin()) {
            System.logout('检查到网关未绑定，即将退出登录');
          }
        }, () {
          Log.file('网关检查失败，检查失败了');
        });
      }
    } catch (e) {
      Log.file('检查网关绑定异常', e);
    }
  }


  @override
  void initState() {
    super.initState();

    if(MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxChangHouseEvent>(notifyHomluxLogout);
      bus.typeOn<HomluxProjectChangeHouse>(notifyHomluxLogout);
      bus.typeOn<HomluxDeleteHouseUser>(notifyHomluxLogout);
    } else if(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      bus.typeOn<MeiJuDeviceDelEvent>(notifyMeiJuDeviceChange);
      bus.typeOn<MeiJuDeviceUnbindEvent>(notifyMeiJuDeviceChange);
    }

    checkGatewayTimer?.cancel();
    checkGatewayTimer = Timer.periodic(const Duration(hours: 1, minutes: 30), (timer) {
      apiCheckLogout();
    });
  }

  @override
  void dispose() {
    super.dispose();
    bus.typeOff<HomluxChangHouseEvent>(notifyHomluxLogout);
    bus.typeOff<HomluxProjectChangeHouse>(notifyHomluxLogout);
    bus.typeOff<HomluxDeleteHouseUser>(notifyHomluxLogout);
    bus.typeOff<MeiJuDeviceDelEvent>(notifyMeiJuDeviceChange);
    bus.typeOff<MeiJuDeviceUnbindEvent>(notifyMeiJuDeviceChange);
    checkGatewayTimer?.cancel();
  }

}