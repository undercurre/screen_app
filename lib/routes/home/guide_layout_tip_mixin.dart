

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/push/event/homlux_push_event.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/event_bus.dart';

import '../../common/homlux/api/homlux_device_api.dart';
import '../../common/homlux/models/homlux_device_entity.dart';
import '../../common/homlux/models/homlux_response_entity.dart';
import '../../common/logcat_helper.dart';
import '../../common/meiju/push/event/meiju_push_event.dart';
import '../../common/system.dart';
import '../../states/layout_notifier.dart';
import '../../widgets/life_cycle_state.dart';
import '../dropdown/drop_down_page.dart';
import 'device/card_type_config.dart';

mixin GuideLayoutTipMixin<W extends StatefulWidget> on LifeCycleStateMixin<W> {

  bool waitToTip = false;

  bool currentShow = false;

  void homluxDeviceAdd(HomluxBindDeviceEvent event) {
    showGuideLayoutDialog();
  }

  void showGuideLayoutDialog() async {
    if(!CustomLayoutHelper.currentGuideDialogShow && System.isLogin()) {
      // 1. 当前路由是否正在首页中
      bool isNiceShow = isAtLastState(LifeCycle.create);
      if(!isNiceShow) {
        waitToTip = true;
        return;
      }

      waitToTip = false;
      final layoutModel = context.read<LayoutModel>();
      // 2. 当前布局状态为空或者初始状态
      var defaultLayout = [DeviceEntityTypeInP4.Default, DeviceEntityTypeInP4.Clock, DeviceEntityTypeInP4.Weather,
        DeviceEntityTypeInP4.DeviceEdit, DeviceEntityTypeInP4.DeviceNull, DeviceEntityTypeInP4.LocalPanel1, DeviceEntityTypeInP4.LocalPanel2];
      bool layout = layoutModel.layouts.isEmpty || layoutModel.layouts.every((element) => defaultLayout.contains(element.type));

      // 3. 查询云端是否有wifi灯具、zigbee灯具、开关面板等设备 -- Homlux
      bool otherCondition = false;
      if(MideaRuntimePlatform.platform.inHomlux() && StrUtils.isNotNullAndEmpty(System.familyInfo?.familyId)) {
        try {
          HomluxResponseEntity<List<HomluxDeviceEntity>> homluxRes = await HomluxDeviceApi
              .queryDeviceListByHomeId(System.familyInfo!.familyId);
          var listPanel = ["midea.mfswitch.*", 
            "zk527b6c944a454e9fb15d3cc1f4d55b", 
            "ok523b6c941a454e9fb15d3cc1f4d55b",
            "midea.knob.*"];
          if (homluxRes.isSuccess && homluxRes.result != null) {
            otherCondition = homluxRes.data!.any(
                    (element) => element.deviceId != 'G-${System.gatewayApplianceCode}' && element.deviceId != System.gatewayApplianceCode && element.roomId == System.roomInfo?.id
                        && ('0x13' == element.proType?.toLowerCase() || listPanel.any((element1) => element.productId?.contains(RegExp(element1)) ?? false))
            );
          }
        } catch(e) {}
      }

      Log.file('【guide】 layout=${layout} isNiceShow=${isNiceShow} otherCondition=${otherCondition} guideShow=${CustomLayoutHelper.currentGuideDialogShow}');
      // 4. 一键布局弹窗还未显示
      if(layout && isNiceShow && otherCondition && !CustomLayoutHelper.currentGuideDialogShow) {
        CustomLayoutHelper.showToLayout(context);
      }
    }
  }

  @override
  void onResume() {
    super.onResume();
    if(waitToTip) {
      showGuideLayoutDialog();
    }
  }


  @override
  void initState() {
    super.initState();

    if(MideaRuntimePlatform.platform.inHomlux()) {
      bus.typeOn<HomluxBindDeviceEvent>(homluxDeviceAdd);
      // bus.typeOn<HomluxAddSubEvent>(homluxSubDeviceAdd);
      // bus.typeOn<HomluxAddWifiEvent>(homluxWifiDeviceAdd);
    }

  }

  @override
  void dispose() {
    bus.typeOff<HomluxBindDeviceEvent>(homluxDeviceAdd);
    super.dispose();
    // bus.typeOff<HomluxAddSubEvent>(homluxSubDeviceAdd);
    // bus.typeOff<HomluxAddWifiEvent>(homluxWifiDeviceAdd);
  }

}