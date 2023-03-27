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
import 'package:screen_app/routes/home/center_control/quick_scene.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/routes/home/center_control/view_part.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../common/push.dart';
import '../../../mixins/throttle.dart';
import '../../../states/device_change_notifier.dart';
import '../../../states/room_change_notifier.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
        String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
        Map<String, dynamic> eventMap = json.decode(event);
        String nodeId = eventMap['nodeId'] ?? "";
        logger.i('收到上报');
        // if (nodeId.isNotEmpty) {
        //   throttle(() {
        //     initPage();
        //   }, durationTime: const Duration(milliseconds: 8000));
        // }
      }));

      Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
        String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
        Map<String, dynamic> eventMap = json.decode(event);
        String nodeId = eventMap['nodeId'] ?? "";
        logger.i('收到上报');
      }));
    });
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
    centerIndexString = await LocalStorage.getItem('centerIndex') ?? '["curtain_light","airCondition","quickScene"]';
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

    var defaultCenterList = [
      ViewPart(
        mark: 'curtain_light',
        child: SizedBox(
          width: 440,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CurtainControl(
                disabled: !curtainSupport,
                computedPower: curtainPower,
                onPowerChanged: curtainPowerHandler,
              ),
              Expanded(
                  flex: 1,
                  child: LightControl(
                    disabled: !lightSupport,
                    computedPower: lightPower,
                    computedBightness: lightBrightness,
                    computedColorTemp: lightColorTemp,
                    onBrightChanged: lightBrightHandler,
                    onColorChanged: lightColorHandler,
                    onPowerChanged: lightPowerHandler,
                  ))
            ],
          ),
        ),
      ),
      ViewPart(mark: 'airCondition', child: AirConditionControl(
        disabled: !airConditionSupport,
        computedPower: airConditionPower,
        computedGear: airConditionGear,
        computedMode: airConditionMode,
        computedTemp: airConditionTemp,
        onTempChanged: airConditionTempHandler,
        onPowerChanged: airConditionPowerHandler,
        onGearChanged: airConditionGearHandler,
        onModeChanged: airConditionModeHandler,
      ),),
      const ViewPart(mark: 'quickScene', child: QuickScene()),
    ];
    if (centerIndexString != null) {
      var centerIndex = List<String>.from(json.decode(centerIndexString));
      List<ViewPart> tempList = [];
      for (var i = 0; i < centerIndex.length; i ++) {
        ViewPart centerPart = defaultCenterList.where((element) => element.mark == centerIndex[i]).toList()[0];
        tempList.insert(i, centerPart);
      }
      setState(() {
        cardWidgetList = tempList;
      });
    } else {
      setState(() {
        cardWidgetList = defaultCenterList;
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 18.0,
                        fontFamily: "MideaType-Regular",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    PopupMenuButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      offset: const Offset(0, 36.0),
                      itemBuilder: (context) {
                        return dropMenuBtnList.map(
                              (item) {
                            return PopupMenuItem<String>(
                              value: item['route'],
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: "MideaType-Regular",
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            );
                          },
                        ).toList();
                      },
                      onSelected: (String route) {
                        toConfigPage(route);
                      },
                      child: Image.asset(
                        "assets/imgs/icon/select_room.png",
                        width: 40,
                        height: 40,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 0,22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      context.watch<RoomModel>().roomInfo.name,
                      textScaleFactor: roomTitleScale,
                      style: const TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 30.0,
                        fontFamily: "MideaType-Regular",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: EasyRefresh(
                  header: const ClassicHeader(
                    dragText: '下拉刷新',
                    armedText: '释放执行刷新',
                    readyText: '正在刷新...',
                    processingText: '正在刷新...',
                    processedText: '刷新完成',
                    noMoreText: '没有更多信息',
                    failedText: '失败',
                    messageText: '上次更新 %T',
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  onRefresh: () async {
                    if (!mounted) {
                      return;
                    }
                    await initPage();
                  },
                  child: ReorderableWrap(
                      direction: Axis.vertical,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      padding: const EdgeInsets.all(8),
                      controller: _scrollController,
                      buildDraggableFeedback: (context, constraints, child) {
                        return Transform(
                          transform: Matrix4.rotationZ(0),
                          alignment: FractionalOffset.topLeft,
                          child: Material(
                            elevation: 6.0,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.zero,
                            child: Card(
                              // 将默认白色设置成透明
                              color: Colors.transparent,
                              child: ConstrainedBox(
                                constraints: constraints,
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        ViewPart row = cardWidgetList.removeAt(oldIndex);
                        cardWidgetList.insert(newIndex, row);
                        setState(() {
                          cardWidgetList = cardWidgetList;
                          centerIndexString = json.encode(cardWidgetList.map((e) => e.mark).toList());
                        });
                        LocalStorage.setItem('centerIndex', json.encode(cardWidgetList.map((e) => e.mark).toList()));
                      },
                      onNoReorder: (int index) {},
                      onReorderStarted: (int index) {},
                      children: cardWidgetList),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
