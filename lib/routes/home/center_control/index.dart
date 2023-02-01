import 'dart:async';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/center_control/air_condition_control.dart';
import 'package:screen_app/routes/home/center_control/curtain_control.dart';
import 'package:screen_app/routes/home/center_control/light_control.dart';
import 'package:screen_app/routes/home/center_control/quick_scene.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../states/device_change_notifier.dart';
import '../../../states/room_change_notifier.dart';
import '../device/register_controller.dart';
import '../device/service.dart';

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

class _CenterControlPageState extends State<CenterControlPage> {
  double roomTitleScale = 1;

  // 获取现在日期
  String time = '';

  // 定时器
  late Timer timeTimer = Timer(const Duration(seconds: 1), () {}); // 定义定时器

  void startTimer() {
    timeTimer.cancel(); // 取消定时器
    timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //TODO
      setState(() {
        time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      });
    });
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
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> updateHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      var homeInfo = res.data.homeList[0];
      var roomList = homeInfo.roomList ?? [];
      Global.profile.roomInfo =
          roomList.where((element) => element.roomId == (Global.profile.roomInfo?.roomId ?? '')).toList()[0];
    }
  }

  initPage() async {
    await initializeDateFormatting('zh_CN', null);
    setState(() {
      time = DateFormat('MM月d日 E  kk:mm', 'zh_CN').format(DateTime.now());
      startTimer();
    });
    // 更新家庭信息
    await updateHomeData();
    // 查灯组列表
    if (!mounted) return;
    context.read<DeviceListModel>().selectLightGroupList();
    // 更新设备detail
    var deviceList = context.read<DeviceListModel>().deviceList;
    debugPrint('加载到的设备列表$deviceList');
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      debugPrint('遍历中$deviceInfo');
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          (DeviceService.isSupport(deviceInfo) || DeviceService.isVistual(deviceInfo))) {
        // 调用provider拿detail存入状态管理里
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo,
            callback: () => {
                  // todo: 优化刷新效率
                  if (DeviceService.isVistual(deviceInfo)) {DeviceService.setVistualDevice(context, deviceInfo)}
                });
      } else {
        if (DeviceService.isVistual(deviceInfo)) {
          DeviceService.setVistualDevice(context, deviceInfo);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                      fontSize: 18, fontFamily: "MideaType-Regular", fontWeight: FontWeight.w400),
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
                margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                    await Future.delayed(const Duration(seconds: 2));
                    if (!mounted) {
                      return;
                    }
                    initPage();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CurtainControl(disabled: !CenterControlService.isCurtainSupport(context),),
                              Expanded(flex: 1, child: LightControl(disabled: !CenterControlService.isLightSupport(context)))
                            ],
                          ),
                          AirConditionControl(disabled: !CenterControlService.isAirConditionSupport(context)),
                          const QuickScene()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
