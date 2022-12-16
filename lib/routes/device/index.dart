import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:date_format/date_format.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/device/register_controller.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';
import '../../states/room_change_notifier.dart';
import 'device_item.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  int _count = 5;
  late EasyRefreshController _controller;
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  List<Map<String, String>> btnList = [
    {'title': '添加设备', 'route': 'SnifferPage'},
    {'title': '切换房间', 'route': 'Room'}
  ];

  initPage() {
    // 更新设备detail
    var deviceList = context.read<DeviceListModel>().deviceList;
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      // 查看品类控制器看是否支持该品类
      var hasController = getController(deviceInfo) != null;
      if (hasController &&
          DeviceService.isOnline(deviceInfo) &&
          DeviceService.isSupport(deviceInfo)) {
        // 调用provider拿detail存入状态管理里
        context.read<DeviceListModel>().setDeviceDetail(deviceInfo,
            callback: () => {
                  // todo: 优化刷新效率
                  updateBins()
                });
      }
    }
  }

  updateBins() {
    List<DraggableGridItem> newBins = [];
    var deviceList = context.read<DeviceListModel>().deviceList;
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      newBins.add(DraggableGridItem(
        child: DeviceItem(deviceInfo: deviceInfo),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          debugPrint('设备$xx+"isDragging: $isDragging');
        },
      ));
    }
    setState(() {
      itemBins = newBins;
    });
  }

  @override
  void initState() {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    for (int xx = 1; xx < 7; xx++) {
      itemBins.add(DraggableGridItem(
        child: const DeviceItem(),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          debugPrint('设备$xx+"isDragging: $isDragging');
        },
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initPage();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), setTime);
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
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
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(context.watch<RoomModel>().roomInfo.name,
                    style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 30.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ))
              ],
            ),
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
                setState(() {
                  _count = 5;
                });
                _controller.finishRefresh();
                _controller.resetFooter();
              },
              child: DraggableGridViewBuilder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // 垂直方向item之间的间距
                  mainAxisSpacing: 17.0,
                  // 水平方向item之间的间距
                  crossAxisSpacing: 17.0,
                  childAspectRatio: 0.7,
                ),
                children: context
                    .watch<DeviceListModel>()
                    .deviceList
                    .map((deviceInfo) {
                  return DraggableGridItem(
                    child: DeviceItem(deviceInfo: deviceInfo),
                    isDraggable: true,
                    dragCallback: (context, isDragging) {
                      debugPrint('设备isDragging: $isDragging');
                    },
                  );
                }).toList(),
                dragCompletion: onDragAccept,
                isOnlyLongPress: true,
                dragFeedback: feedback,
                dragPlaceHolder: placeHolder,
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
