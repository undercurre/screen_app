import 'dart:async';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:date_format/date_format.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';
import 'package:screen_app/mixins/auto_sniffer.dart';
import '../../common/api/user_api.dart';
import '../../common/global.dart';
import '../../states/room_change_notifier.dart';
import '../sniffer/device_item.dart';
import 'device_card.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> with AutoSniffer {
  int _count = 5;
  late EasyRefreshController _controller;
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  double roomTitleScale = 1;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  List<Map<String, String>> btnList = [
    {'title': '添加设备', 'route': 'SnifferPage'},
    {'title': '切换房间', 'route': 'Room'}
  ];

  List<Widget> deviceWidgetList = [];
  List<DeviceEntity> deviceEntityList = [];

  initPage() {
    // 更新房间信息
    updateHomeData();
    // 查灯组列表
    context.read<DeviceListModel>().selectLightGroupList();
    // 更新设备detail
    var deviceList = context.read<DeviceListModel>().deviceList;
    debugPrint('加载到的设备列表$deviceList');
    setState(() {
      deviceEntityList = deviceList;
    });
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          (DeviceService.isSupport(deviceInfo) ||
              DeviceService.isVistual(deviceInfo))) {
        // 调用provider拿detail存入状态管理里
        context.read<DeviceListModel>().updateDeviceDetail(deviceInfo,
            callback: () => {
                  // todo: 优化刷新效率
                  updateBins(deviceInfo)
                });
      } else {
        updateBins(deviceInfo);
      }
    }
  }

  void updateHomeData() async {
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

  updateBins(DeviceEntity deviceInfo) {
    if (DeviceService.isVistual(deviceInfo)) {
      DeviceService.setVistualDevice(context, deviceInfo);
    }
    setState(() {
      deviceWidgetList = deviceEntityList
          .map((device) => DeviceCard(deviceInfo: device))
          .toList();
    });
  }

  @override
  void initState() {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initPage();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), setTime);
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final offset = min(_scrollController.offset, 150);
        setState(() {
          roomTitleScale = min(1 - (offset / 150), 1.3);
        });
      }
    });
    super.initState();
  }

  void setTime(Timer timer) {
    setState(() {
      time = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
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
                        "${time.month}月${time.day}日  ${weekday[time.weekday]}     ${formatDate(time, [
                              HH,
                              ':',
                              nn
                            ])}",
                        style: const TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 18.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                    PopupMenuButton(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
                      offset: const Offset(0, 36.0),
                      itemBuilder: (context) {
                        return btnList.map((item) {
                          return PopupMenuItem<String>(
                              value: item['route'],
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(item['title']!,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.w400)),
                              ));
                        }).toList();
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
                        fontFamily: "MideaType",
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
                    setState(() {
                      _count = 5;
                    });
                    _controller.finishRefresh();
                    _controller.resetFooter();
                  },
                  child: ReorderableWrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    padding: const EdgeInsets.all(8),
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
                      setState(() {
                        Widget row = deviceWidgetList.removeAt(oldIndex);
                        DeviceEntity deviceRow =
                            deviceEntityList.removeAt(oldIndex);
                        deviceWidgetList.insert(newIndex, row);
                        deviceEntityList.insert(newIndex, deviceRow);
                      });
                    },
                    onNoReorder: (int index) {
                      //this callback is optional
                      debugPrint(
                          '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                    },
                    onReorderStarted: (int index) {
                      //this callback is optional
                      debugPrint(
                          '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                    },
                    children: deviceWidgetList,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget feedback(List<DraggableGridItem> list, int index) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 20,
      height: MediaQuery.of(context).size.height / 2 - 40,
      child: list[index].child,
    );
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  void onDragAccept(
      List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    debugPrint('onDragAccept: $beforeIndex -> $afterIndex');
  }

  //声明星期变量
  var weekday = [" ", "周一", "周二", "周三", "周四", "周五", "周六", "周日"];
}
