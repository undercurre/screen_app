import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/top_to_bottom_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/life_cycle_state.dart';

import '../../channel/ota_channel.dart';
import '../../common/api/ai_author_api.dart';
import '../../common/api/gateway_api.dart';
import '../../common/system.dart';
import '../../common/utils.dart';
import '../../mixins/ota.dart';
import '../../widgets/event_bus.dart';
import '../../widgets/standby.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../dropdown/drop_down_page.dart';
import '../sniffer/auto_sniffer.dart';
import '../sniffer/device_manager_sdk_initializer.dart';
import './center_control/index.dart';
import './device/index.dart';
import '../../channel/index.dart';
import '../../common/global.dart';

export './center_control/index.dart';
export './device/index.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initValue = 0});

  final int initValue;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with DeviceManagerSDKInitialize, LifeCycleState, Ota {
  late double po;
  var children = <Widget>[];
  late PageController _pageController;
  String pressPath = "assets/imgs/icon/button_press.png";
  String unPressPath = "assets/imgs/icon/button_normal.png";
  String selectDevice = "assets/imgs/icon/button_normal.png";
  String selectCenter = "assets/imgs/icon/button_press.png";
  String selectScene = "assets/imgs/icon/button_normal.png";

  @override
  void initState() {
    super.initState();
    //初始化状态
    _pageController = PageController(initialPage: 0);
    // children.add(const KeepAliveWrapper(child: ScenePage(text: "场景页")));
    // children.add(const KeepAliveWrapper(child: CenterControlPage(text: '中控页')));
    // children.add(const KeepAliveWrapper(child: DevicePage(text: "设备页")));
    initial();

    ShowStandby.startTimer();
    ShowStandby.aiRestartTimer();
    context.read<StandbyChangeNotifier>().startWeatherTimer();
    bus.on('onPointerDown', (arg) {
      ShowStandby.startTimer();
    });
  }

  initial() async {
    try {
      Future.delayed(const Duration(milliseconds: 4000), () {
        aiMethodChannel.registerAiSetVoiceCallBack(_aiSetVoiceCallback);
        aiMethodChannel
            .registerAiControlDeviceErrorCallBack(_aiControlDeviceError);
        AiAuthorApi.AiAuthor(deviceId: Global.profile.applianceCode);
      });
      num lightValue = await settingMethodChannel.getSystemLight();
      num soundValue = await settingMethodChannel.getSystemVoice();
      bool autoLight = await settingMethodChannel.getAutoLight();
      bool nearWakeup = await settingMethodChannel.getNearWakeup();

      Global.soundValue = soundValue;
      Global.lightValue = lightValue;
      Global.autoLight = autoLight;
      Global.nearWakeup = nearWakeup;
      String? deviceSn = await aboutSystemChannel.getGatewaySn(false);
      String? deviceId = Global.profile.applianceCode;
      String macAddress = await aboutSystemChannel.getMacAddress();
      var jsonData =
          '{ "deviceSn" : "$deviceSn", "deviceId" : "$deviceId", "macAddress" : "$macAddress","aiEnable":${Global.profile.aiEnable}}';
      var parsedJson = json.decode(jsonData);
      await aiMethodChannel.initialAi(parsedJson);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _aiSetVoiceCallback(int voice) {
    Global.soundValue = voice;
  }

  void _aiControlDeviceError() {
    /// 判定当前网关是否已经绑定
    GatewayApi.check((bind, code) {
      if (!bind) {
        TipsUtils.toast(content: '智慧屏已删除，请重新登录');
        Push.dispose();
        System.loginOut();
        Navigator.pushNamedAndRemoveUntil(
            context, "Login", (route) => route.settings.name == "/");
      }
    }, () {
      //接口请求报错
    });
  }

  @override
  void onResume() {
    super.onResume();

    checkOtaUpgrade();
  }

  @override
  void onPause() {
    super.onPause();
    ShowStandby.disposeTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
                onVerticalDragDown: (details) {
                  po = details.globalPosition.dy;
                },
                onVerticalDragUpdate: (details) {
                  debugPrint(
                      "onVerticalDragUpdate---${details.globalPosition}---${details.localPosition}---${details.delta}");
                  if (po <= 40) {
                    Navigator.of(context).push(PageAnimationTransition(
                        page: const DropDownPage(),
                        pageAnimationType: TopToBottomTransition()));
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF272F41), Color(0xFF080C14)],
                        ),
                      ),
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      height: MediaQuery.of(context).size.height,
                      child: const DevicePage(),
                    ),
                    Positioned(
                      top: 10,
                      left: MediaQuery.of(context).size.width / 2 - 46,
                      child: Container(
                        width: 92,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF818895).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    aiMethodChannel.unregisterAiSetVoiceCallBack(_aiSetVoiceCallback);
    aiMethodChannel
        .unregisterAiControlDeviceErrorCallBack(_aiControlDeviceError);
    debugPrint("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    debugPrint("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("didChangeDependencies");
  }
}
