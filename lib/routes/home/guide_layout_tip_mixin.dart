

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/homlux/push/event/homlux_push_event.dart';
import 'package:screen_app/widgets/event_bus.dart';

import '../../common/meiju/push/event/meiju_push_event.dart';
import '../../states/layout_notifier.dart';
import '../../widgets/life_cycle_state.dart';
import '../dropdown/drop_down_page.dart';
import 'device/card_type_config.dart';

mixin GuideLayoutTipMixin<W extends StatefulWidget> on LifeCycleStateMixin<W> {

  void meijuDeviceAdd(MeiJuDeviceAddEvent event) {
    showGuideLayoutDialog();
  }

  void homluxSubDeviceAdd(HomluxAddSubEvent event) {
    showGuideLayoutDialog();
  }

  void homluxWifiDeviceAdd(HomluxAddWifiEvent event) {
    showGuideLayoutDialog();
  }

  void showGuideLayoutDialog() {
    final layoutModel = context.read<LayoutModel>();
    // 1. 当前布局状态为空或者初始状态
    bool layout = layoutModel.layouts.isEmpty;
    var defaultLayout = [DeviceEntityTypeInP4.Default, DeviceEntityTypeInP4.Clock, DeviceEntityTypeInP4.Weather,
      DeviceEntityTypeInP4.DeviceEdit, DeviceEntityTypeInP4.DeviceNull, DeviceEntityTypeInP4.LocalPanel1, DeviceEntityTypeInP4.LocalPanel2];
    layout |= layoutModel.layouts.length == 1 && layoutModel.layouts.every((element) => defaultLayout.contains(element.type));
    // 2. 当前路由是否正在首页中
    bool isNiceShow = isAtLastState(LifeCycle.create);
    // 3. 一键布局弹窗还未显示
    if(layout && isNiceShow) {
      CustomLayoutHelper.showToLayout(context);
    }
  }


  @override
  void initState() {
    super.initState();

    if(MideaRuntimePlatform.platform.inMeiju()) {
      bus.typeOn<MeiJuDeviceAddEvent>(meijuDeviceAdd);
    } else if(MideaRuntimePlatform.platform.inHomlux()) {
      bus.typeOn<HomluxAddSubEvent>(homluxSubDeviceAdd);
      bus.typeOn<HomluxAddWifiEvent>(homluxWifiDeviceAdd);
    }

  }

  @override
  void dispose() {
    super.dispose();
    bus.typeOff<MeiJuDeviceAddEvent>(meijuDeviceAdd);
    bus.typeOff<HomluxAddSubEvent>(homluxSubDeviceAdd);
    bus.typeOff<HomluxAddWifiEvent>(homluxWifiDeviceAdd);
  }

}