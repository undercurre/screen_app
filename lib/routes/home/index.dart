import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/top_to_bottom_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/adapter/push_data_adapter.dart';
import 'package:screen_app/routes/login/check_gateway_bind.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/life_cycle_state.dart';
import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/setting.dart';
import '../../main.dart';
import '../../states/weather_change_notifier.dart';
import '../../widgets/util/net_utils.dart';
import './device/index.dart';
import '../../channel/index.dart';
import '../../common/adapter/ai_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/global.dart';
import '../../common/system.dart';
import '../../mixins/ota.dart';
import '../../widgets/event_bus.dart';
import '../../widgets/standby.dart';
import '../dropdown/drop_down_page.dart';
import '../sniffer/device_manager_sdk_initializer.dart';

export './center_control/index.dart';
export './device/index.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initValue = 0});

  final int initValue;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with DeviceManagerSDKInitialize, LifeCycleState, Ota, CheckGatewayBind , WidgetNetState{
  late double po;
  var children = <Widget>[];

  @override
  void initState() {
    super.initState();
    //初始化状态
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
      num lightValue = await settingMethodChannel.getSystemLight();
      num soundValue = await settingMethodChannel.getSystemVoice();
      bool autoLight = await settingMethodChannel.getAutoLight();
      bool nearWakeup = await settingMethodChannel.getNearWakeup();
      String macAddr = await aboutSystemChannel.getMacAddress();
      System.macAddress = macAddr.replaceAll(":", "").toUpperCase();

      Global.soundValue = soundValue;
      Global.lightValue = lightValue;
      Global.autoLight = autoLight;
      Global.nearWakeup = nearWakeup;
      SelectRoomDataAdapter roomDataAd =
          SelectRoomDataAdapter(MideaRuntimePlatform.platform);
      roomDataAd?.queryRoomList(System.familyInfo!);
      // 初始化AI语音
      aiMethodChannel.registerAiSetVoiceCallBack(_aiSetVoiceCallback);
      if (System.isLogin()) {
        AiDataAdapter(MideaRuntimePlatform.platform).initAiVoice();
      }
      deviceLocal485ControlChannel.find485Device();
      // 初始化推送
      PushDataAdapter(MideaRuntimePlatform.platform).startConnect();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _aiSetVoiceCallback(int voice) {
    Global.soundValue = voice;
    Setting.instant().showVolume = (voice / 15 * 100).toInt();
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
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width),
                      height: MediaQuery.of(context).size.height,
                      child: DevicePage(),
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

  @override
  void netChange(MZNetState? state) {
    if(state!=null){
      final weatherModel = Provider.of<WeatherModel>(navigatorKey.currentContext!);
      weatherModel.fetchWeatherData();
    }

    // TODO: implement netChange
  }
}
