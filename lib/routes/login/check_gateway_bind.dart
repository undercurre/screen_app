
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/bind_gateway_data_adapter.dart';
import 'package:screen_app/common/adapter/check_auth_adapter.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/widgets/event_bus.dart';

import '../../channel/index.dart';
import '../../common/homlux/api/homlux_user_api.dart';
import '../../common/homlux/push/event/homlux_push_event.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/push/event/meiju_push_event.dart';
import '../../common/setting.dart';
import '../../common/system.dart';
import '../../common/utils.dart';
import '../../states/layout_notifier.dart';

mixin CheckGatewayBind<T extends StatefulWidget> on State<T> {

  Timer? checkGatewayTimer;

  void notifyMeiJuDeviceChange(dynamic event) {
    apiCheckLogout();
  }

  void notifyHomluxLogout(HomluxDeleteHouseUser event) {
    if(event.uid == System.getUid()) {
      System.logout('Homlux推送事件，用户${event.uid}退出登录');
    }
  }

  void notifyHomluxGatewayDelete(HomluxDeviceDelEvent event) {
    Log.i("[bus] 接收到删除设备指令 待删除设备device=${event.deviceId} 网关deviceId=${HomluxGlobal.gatewayApplianceCode}");
    if(event.deviceId == HomluxGlobal.gatewayApplianceCode) {
      resetByGatewayDelete();
      System.logout('接收到删除网关的推送, 网关设备code = ${event.deviceId}');
    }
  }

  void apiCheckUserAuth(dynamic event) async {
    String? familyId = System.familyInfo?.familyId;
    if(familyId == null) {
      Log.e('程序异常，访问到的家庭Id为空');
      return;
    }
    var adapter = CheckAuthAdapter(MideaRuntimePlatform.platform);
    var result = await adapter.check();
    if(result == false && System.isLogin()) {
      System.logout('当前用户身份无权限登录，强制登出');
    }
  }

  void apiCheckLogout() {
    try {
      if (System.isLogin()) {
        var adapter = BindGatewayAdapter(MideaRuntimePlatform.platform);
        adapter.checkGatewayBindState(System.familyInfo!, (bind, code) {
          if (!bind && System.isLogin()) {
            resetByGatewayDelete();
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

  void resetByGatewayDelete() {
    gatewayChannel.resetRelayModel();
    final layoutModel = Provider.of<LayoutModel>(context, listen: false);
    layoutModel.removeLayouts();
    Setting.instant().lastBindHomeId = '';
    Setting.instant().lastBindRoomId = '';
    // 删除本地所有缓存
    LocalStorage.clearAllData();
  }


  @override
  void initState() {
    super.initState();

    if(MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxDeleteHouseUser>(notifyHomluxLogout);
      bus.typeOn<HomluxChangeUserAuthEvent>(apiCheckUserAuth);
      bus.typeOn<HomluxDeviceDelEvent>(notifyHomluxGatewayDelete);
    } else if(MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      bus.typeOn<MeiJuDeviceDelEvent>(notifyMeiJuDeviceChange);
      bus.typeOn<MeiJuDeviceUnbindEvent>(notifyMeiJuDeviceChange);
    }

    checkGatewayTimer?.cancel();
    checkGatewayTimer = Timer.periodic(const Duration(hours: 1, minutes: 30), (timer) {
      apiCheckLogout();
      apiCheckUserAuth(123);
    });
  }

  @override
  void dispose() {
    super.dispose();
    bus.typeOff<HomluxDeleteHouseUser>(notifyHomluxLogout);
    bus.typeOff<MeiJuDeviceDelEvent>(notifyMeiJuDeviceChange);
    bus.typeOff<MeiJuDeviceUnbindEvent>(notifyMeiJuDeviceChange);
    bus.typeOff<HomluxDeviceDelEvent>(notifyHomluxGatewayDelete);
    bus.typeOff<HomluxChangeUserAuthEvent>(apiCheckUserAuth);
    checkGatewayTimer?.cancel();
  }

}