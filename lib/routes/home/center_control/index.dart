import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/routes/home/center_control/air_condition_control.dart';
import 'package:screen_app/routes/home/center_control/curtain_control.dart';
import 'package:screen_app/routes/home/center_control/light_control.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/routes/home/center_control/view_part.dart';
import 'package:screen_app/widgets/card/main/small_device.dart';
import 'package:screen_app/widgets/card/main/small_scene.dart';
import 'package:screen_app/widgets/card/other/clock.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../common/push.dart';
import '../../../mixins/throttle.dart';
import '../../../states/device_change_notifier.dart';
import '../../../states/room_change_notifier.dart';
import '../../../widgets/card/other/weather.dart';

List<Map<String, String>> dropMenuBtnList = [
  {'title': '添加设备', 'route': 'SnifferPage'},
  {'title': '切换房间', 'route': 'SelectRoomPage'}
];

class CenterControlPage extends StatefulWidget {
  const CenterControlPage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _CenterControlPageState();
}

class _CenterControlPageState extends State<CenterControlPage> with Throttle {
  Function(Map<String, dynamic> arg)? _eventCallback;
  double roomTitleScale = 1;

  List<ViewPart> cardWidgetList = [];
  String centerIndexString = '["curtain_light","airCondition","quickScene"]';

  bool curtainSupport = true;
  bool lightSupport = true;
  bool airConditionSupport = true;

  bool curtainPower = false;
  bool lightPower = false;
  bool airConditionPower = false;

  num lightBrightness = 1;
  num lightColorTemp = 0;

  num airConditionTemp = 26;
  num airConditionGear = 6;
  String airConditionMode = 'auto';

  // 获取现在日期
  String time = '';

  // 定时器
  late Timer timeTimer = Timer(const Duration(seconds: 1), () {}); // 定义定时器

  void startTimer() {
    timeTimer.cancel(); // 取消定时器
    timeTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      //TODO
      setState(() {
        time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      });
    });
  }

  void curtainPowerHandler(bool value) {
    setState(() {
      curtainPower = value;
    });
  }

  void lightPowerHandler(bool value) {
    setState(() {
      lightPower = value;
    });
  }

  void lightBrightHandler(num value) {
    setState(() {
      lightBrightness = value;
    });
  }

  void lightColorHandler(num value) {
    setState(() {
      lightColorTemp = value;
    });
  }

  void airConditionModeHandler(String value) {
    setState(() {
      airConditionMode = value;
    });
  }

  void airConditionGearHandler(num value) {
    setState(() {
      airConditionGear = value;
    });
  }

  void airConditionPowerHandler(bool value) {
    setState(() {
      airConditionPower = value;
    });
  }

  void airConditionTempHandler(num value) {
    setState(() {
      airConditionTemp = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: implement dispose
    timeTimer.cancel();
  }

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final offset = min(_scrollController.offset, 50);
        setState(() {
          roomTitleScale = min(1 - (offset / 50), 1);
        });
      }
    });
    initPage();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
    //     String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
    //     Map<String, dynamic> eventMap = json.decode(event);
    //     String nodeId = eventMap['nodeId'] ?? "";
    //     logger.i('收到上报1');
    //     if (nodeId.isNotEmpty) {
    //       throttle(() {
    //         initPage();
    //       }, durationTime: const Duration(milliseconds: 8000));
    //     }
    //   }));
    //
    //   Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
    //     String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
    //     Map<String, dynamic> eventMap = json.decode(event);
    //     String nodeId = eventMap['nodeId'] ?? "";
    //     logger.i('收到上报2');
    //   }));
    // });
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> updateHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(
        homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      var homeInfo = res.data.homeList[0];
      var roomList = homeInfo.roomList ?? [];
      Global.profile.roomInfo = roomList
          .where((element) =>
              element.roomId == (Global.profile.roomInfo?.roomId ?? ''))
          .toList()[0];
    }
  }

  initPage() async {
    await initializeDateFormatting('zh_CN', null);
    setState(() {
      time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      startTimer();
    });
    if (!mounted) return;
    await context.read<DeviceListModel>().updateAllDetail();
    setState(() {
      curtainSupport = CenterControlService.isCurtainSupport(context);
      lightSupport = CenterControlService.isLightSupport(context);
      airConditionSupport = CenterControlService.isAirConditionSupport(context);

      curtainPower = CenterControlService.isCurtainPower(context);
      lightPower = CenterControlService.isLightPower(context);
      airConditionPower = CenterControlService.isAirConditionPower(context);

      lightBrightness = CenterControlService.lightTotalBrightness(context);
      lightColorTemp = CenterControlService.lightTotalColorTemperature(context);

      airConditionTemp = CenterControlService.airConditionTemperature(context);
      airConditionGear = CenterControlService.airConditionGear(context);
      airConditionMode = CenterControlService.airConditionMode(context);
    });
    initPageState();
    centerIndexString = await LocalStorage.getItem('centerIndex') ??
        '["curtain_light","airCondition","quickScene"]';
  }

  initPageState() async {
    await context.read<DeviceListModel>().updateAllDetailWaited();
    setState(() {
      curtainSupport = CenterControlService.isCurtainSupport(context);
      lightSupport = CenterControlService.isLightSupport(context);
      airConditionSupport = CenterControlService.isAirConditionSupport(context);

      curtainPower = CenterControlService.isCurtainPower(context);
      lightPower = CenterControlService.isLightPower(context);
      airConditionPower = CenterControlService.isAirConditionPower(context);

      lightBrightness = CenterControlService.lightTotalBrightness(context);
      lightColorTemp = CenterControlService.lightTotalColorTemperature(context);

      airConditionTemp = CenterControlService.airConditionTemperature(context);
      airConditionGear = CenterControlService.airConditionGear(context);
      airConditionMode = CenterControlService.airConditionMode(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF272F41), Color(0xFF080C14)],
        ),
      ),
      child: Container());
  }
}
