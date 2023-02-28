import 'dart:async';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../states/room_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'device_card.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  int count = 5;
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
    {'title': '切换房间', 'route': 'SelectRoomPage'}
  ];

  List<Widget> deviceWidgetList = [];
  List<DeviceEntity> deviceEntityList = [];

  initPage() async {
    if (mounted) {
      var deviceModel = context.read<DeviceListModel>();
      // 更新设备detail
      await deviceModel.updateAllDetail();
      var entityList = deviceModel.showList;
      List<DeviceEntity> sortList = [];
      List<DeviceEntity> supportList = entityList
          .where((element) => DeviceService.isSupport(element))
          .toList();
      List<DeviceEntity> nosupportList = entityList
          .where((element) => !DeviceService.isSupport(element))
          .toList();
      List<DeviceEntity> onlineList = supportList
          .where((element) => DeviceService.isOnline(element))
          .toList();
      List<DeviceEntity> outlineList = supportList
          .where((element) => !DeviceService.isOnline(element))
          .toList();
      onlineList.sort((a, b) {
        if (a.activeTime == '' ||
            b.activeTime == '' ||
            a.activeTime == null ||
            b.activeTime == null) {
          return 1;
        }
        if (DateTime.parse(a.activeTime)
                .compareTo(DateTime.parse(b.activeTime)) ==
            0) {
          return 1;
        }
        return DateTime.parse(a.activeTime)
                    .compareTo(DateTime.parse(b.activeTime)) >
                0
            ? -1
            : 1;
      });
      sortList.addAll(onlineList);
      sortList.addAll(outlineList);
      sortList.addAll(nosupportList);
      setState(() {
        deviceEntityList = sortList;

        deviceWidgetList = deviceEntityList
            .map((device) => DeviceCard(deviceInfo: device))
            .toList();
      });
      bus.emit('updateDeviceCardState');
    }
  }

  @override
  void initState() {
    super.initState();

    bus.on('updateDeviceListState', (arg) async {
      initPage();
    });

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initPage();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), setTime);
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final offset = min(_scrollController.offset, 150);
        setState(() {
          roomTitleScale = min(1 - (offset / 150), 1);
        });
      }
    });
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
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: "MideaType",
                                      fontWeight: FontWeight.w400),
                                ),
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
                margin: EdgeInsets.fromLTRB(20, 0, 0, 10 * roomTitleScale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      context.read<RoomModel>().roomInfo.name,
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
                await initPage();
                setState(() {
                  count = 5;
                });
                _controller.finishRefresh();
                _controller.resetFooter();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 460,
                      minWidth: 460 - 32,
                      minHeight: MediaQuery.of(context).size.height - 60,
                    ),
                    child: ReorderableWrap(
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
                        Widget row = deviceWidgetList.removeAt(oldIndex);
                        DeviceEntity deviceRow =
                            deviceEntityList.removeAt(oldIndex);
                        deviceEntityList.insert(newIndex, deviceRow);
                        deviceWidgetList.insert(newIndex, row);
                        setState(() {
                          deviceEntityList = deviceEntityList;
                          deviceWidgetList = deviceWidgetList;
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
                      children: deviceEntityList.isNotEmpty
                          ? deviceWidgetList
                          : <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Image(
                                        image: AssetImage(
                                            'assets/imgs/scene/empty.png'),
                                        width: 200,
                                        height: 200),
                                    Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        '当前房间无设备',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontFamily: 'MideaType',
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
