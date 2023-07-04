import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/global.dart';
import '../../../states/device_position_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/mz_buttion.dart';
import 'device_card.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final PageController _pageController = PageController();
  List<Widget> _screens = [];
  late EasyRefreshController _controller;
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  double roomTitleScale = 1;
  Function(Map<String, dynamic> arg)? cb;
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
      setState(() {
        deviceEntityList = entityList;
        deviceWidgetList = deviceEntityList
            .map((device) => DeviceCard(deviceInfo: device))
            .toList();
      });
      initDeviceState();
    }
  }

  initDeviceState() async {
    var deviceModel = context.read<DeviceListModel>();
    await deviceModel.onlyFetchDetailForAll();
    var entityList = deviceModel.showList;
    setState(() {
      deviceEntityList = entityList;

      deviceWidgetList = deviceEntityList.map((device) {
        logger.i('装载卡片数据', device);
        return DeviceCard(deviceInfo: device);
      }).toList();
    });
    bus.emit('updateDeviceCardState');
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

    cb = (arg) {
      initPage();
      GatewayApi.check((bind, code) {
        if (!bind) {
          bus.emit('logout');
        }
      }, () {
        //接口请求报错
      });
    };

    Push.listen("添加设备", cb!);
    Push.listen("解绑设备", cb!);
    Push.listen("删除设备", cb!);
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
    Push.dislisten("添加设备", cb!);
    Push.dislisten("解绑设备", cb!);
    Push.dislisten("删除设备", cb!);
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final layoutModel = Provider.of<LayoutModel>(context);
    // 处理布局信息
    _screens = getScreenList();
    logger.i('custom屏幕页面数量', _screens.length);
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF272F41), Color(0xFF080C14)],
            ),
          ),
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          height: MediaQuery.of(context).size.height,
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {},
            children: _screens,
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 48),
                width: MediaQuery.of(context).size.width,
                height: 72,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MzButton(
                        width: 168,
                        height: 56,
                        borderRadius: 29,
                        backgroundColor: const Color(0xFF818C98),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        text: '添加(${layoutModel.layouts.length}/16)',
                        onPressed: () {
                          Navigator.pushNamed(context, 'AddDevice');
                        },
                      ),
                      MzButton(
                        width: 168,
                        height: 56,
                        borderRadius: 29,
                        backgroundColor: const Color(0xFF818C98),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        text: '完成',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

  List<Widget> getScreenList() {
    // 使用provider
    final layoutModel = Provider.of<LayoutModel>(context);
    // 屏幕页面列表
    List<Widget> screenList = [];
    // 最大页数
    int maxPage = layoutModel.getMaxPageIndex();
          for (int page = 0; page <= maxPage; page ++) {
            // 收集当前page的widget
            List<Widget> curScreenWidgets = [];
            // 拿到当前页的layout
            List curScreenLayouts = layoutModel.getLayoutsByPageIndex(page);
            // 映射成widget放进去
            for (Layout layout in curScreenLayouts) {
              // 映射出对应的Card
              Widget cardWidget =
              buildMap[layout.cardType]![layout.type]!(
                  layout.data);
              logger.i('映射出的widget', cardWidget);
              // 映射定位
              Widget cardWithPosition = Positioned(
                  left: layout.left,
                  top: layout.top,
                  child: LongPressDraggable(
                    feedback: cardWidget,
                    childWhenDragging: Opacity(opacity: 0.5, child: cardWidget),
                    child: cardWidget,
                    onDragUpdate: (details) {
                      logger.i('拖拽x', details.delta.dx);
                      logger.i('拖拽y', details.delta.dy);
                    },
                  ));
              Widget iconWithPosition = Positioned(
                left: layout.left +
                    sizeMap[layout.cardType]!['width']! -
                    20,
                top: layout.top - 10,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6B6D73),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
              );
              // 扔进页面里
              curScreenWidgets.add(cardWithPosition);
              curScreenWidgets.add(iconWithPosition);
            }
            // 每一页插入屏幕表
            screenList.add(
              Stack(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height),
                  ...curScreenWidgets
                ],
              ),
            );
          }
    // 布局结束，抛出屏幕列表
    return screenList;
  }
}

int findMinimum(List<double> numbers) {
  double minValue = numbers.reduce((a, b) => a < b ? a : b);
  int minIndex = numbers.indexOf(minValue);

  return minIndex;
}
