import 'dart:async';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/api/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';
import 'package:screen_app/widgets/card/main/big_device_light.dart';
import 'package:screen_app/widgets/card/other/weather.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../states/room_change_notifier.dart';
import '../../../widgets/card/main/middle_device.dart';
import '../../../widgets/card/main/middle_device_panel.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/card/main/small_scene.dart';
import '../../../widgets/card/other/clock.dart';
import '../../../widgets/event_bus.dart';
import 'device_card.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
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
    // 处理布局信息
    // 假设现在有布局
    List<Layout> layout = [
      Layout('183472490233', 'clock', CardType.Other, -1, -1, -1, null),
      Layout('183472490231', 'scene', CardType.Small, -1, -1, -1, {
        'name': '默认情景',
        'icon': const Image(
          image: AssetImage('assets/newUI/scene/default.png'),
        ),
        'onOff': true,
      }),
      Layout('183472490232', '0x13', CardType.Small, -1, -1, -1, null),
      Layout('183472490235', '0x13', CardType.Big, -1, -1, -1, null),
      Layout('183472490234', '0x13', CardType.Middle, -1, -1, -1, null),
      Layout('183472490231', 'scene', CardType.Small, -1, -1, -1, {
        'name': '默认情景',
        'icon': const Image(
          image: AssetImage('assets/newUI/scene/default.png'),
        ),
        'onOff': true,
      }),
      Layout('183472490231', 'scene', CardType.Small, -1, -1, -1, {
        'name': '默认情景',
        'icon': const Image(
          image: AssetImage('assets/newUI/scene/default.png'),
        ),
        'onOff': true,
      }),
      Layout('183472490234', '0x13', CardType.Middle, -1, -1, -1, null),
      Layout('183472490231', 'scene', CardType.Small, -1, -1, -1, {
        'name': '默认情景',
        'icon': const Image(
          image: AssetImage('assets/newUI/scene/default.png'),
        ),
        'onOff': true,
      }),
      Layout('183472490231', 'scene', CardType.Small, -1, -1, -1, {
        'name': '默认情景',
        'icon': const Image(
          image: AssetImage('assets/newUI/scene/default.png'),
        ),
        'onOff': true,
      }),
      Layout('183472490235', '0x13', CardType.Big, -1, -1, -1, null),
      Layout('183472490235', '0x13', CardType.Big, -1, -1, -1, null),
    ];
    _screens = getScreenList(layout);
    logger.i('屏幕页面数量', _screens.length);
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index) {},
      children: _screens,
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

  List<Widget> getScreenList(List<Layout> layout) {
    const paddingNum = 20;
    // 屏幕页面列表
    List<Widget> screenList = [];
    // 当前页面的widgets
    List<Widget> curScreenWidgetList = [];
    // 当前要布局的页面
    int pageCount = 0;
    // 已经被排布的页面数量
    int hadPageCount = 0;
    // 没有被排进过页面的元素
    List<Layout> hadNotInList = [];
    // 排进过页面的元素
    List<Layout> hadInList = [];
    // 准备元素队列
    for (var element in layout) {
      // 先把拿到的布局数据分成已布局好的和没布局好的，没布局好的pageIndex,left和top都是-1
      if (element.pageIndex == -1 && element.left == -1 && element.top == -1) {
        hadNotInList.add(element);
      } else {
        if (hadPageCount < element.pageIndex) hadPageCount = element.pageIndex;
        hadInList.add(element);
      }
    }
    // 虚拟布局计算
    // 在已排布局中消耗未排队列元素
    while (pageCount < hadPageCount) {}
    // 把剩余的未排元素生成新页面
    Screen screenLayer = Screen();
    while (hadNotInList.isNotEmpty) {
      logger.i('循环开始', hadNotInList.length);
      List<Layout> completeList = [];
      for (var hadNotElement in hadNotInList) {
        // 先找到这个元素在当前页面的占位情况
        List<int> fillCells =
        screenLayer.checkAvailability(hadNotElement.cardType);
        logger.i('占位', fillCells);
        // 当占位成功
        if (fillCells.isNotEmpty) {
          completeList.add(hadNotElement);
          for (var item in fillCells) {
            Map<String, int> mark = screenLayer.getGridCoordinates(item);
            screenLayer.setCellOccupied(mark['row']!, mark['col']!, true);
          }
          // 虚拟占位成功就可以把布局写入未排数据里
          // 通过最初的一个占位来判断left定位数据
          hadNotElement.left = ((fillCells[0] - 1) % 4 * 105 +
              (((fillCells[0] - 1) % 4 == 0 ? 1 : (fillCells[0] - 1) % 4) *
                  paddingNum))
              .toDouble();
          // 通过最后一个占位来判断top定位数据
          hadNotElement.top = ((fillCells[0] ~/ 4) * 88 +
              (fillCells[0] ~/ 4 + 1) * paddingNum +
              12)
              .toDouble();
          logger.i(
              '定位数据', 'left: ${hadNotElement.left} top: ${hadNotElement.top}');
          // 把当前页码放进去
          hadNotElement.pageIndex = pageCount;
          // 映射出对应的Card
          Widget cardWidget =
          buildMap[hadNotElement.cardType]![hadNotElement.type]!(
              hadNotElement.data);
          logger.i('映射出的widget', cardWidget);
          // 映射定位
          Widget cardWithPosition = Positioned(
              left: hadNotElement.left,
              top: hadNotElement.top,
              child: cardWidget);
          // 扔进页面里
          curScreenWidgetList.add(cardWithPosition);
          logger.i('curScreenWidgetList.length', curScreenWidgetList.length);
        } else {
          // 占位失败
          // 查询占位是否填满屏幕
          List<int> arrHasPosition = screenLayer.getOccupiedGridIndices();
          if (arrHasPosition.length == 16) {
            logger.i('屏幕被占满');
            break;
          } else {
            // 屏幕没占满
          }
        }
      }
      hadNotInList.removeWhere((element) => completeList.contains(element));
      if (completeList.isNotEmpty) {
        // 生成页面Widget插入渲染流程
        screenList.add(
          Stack(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
              ...curScreenWidgetList
            ],
          ),
        );
        // 清空当前屏幕数据容器
        curScreenWidgetList = [];
        // 重置布局器
        screenLayer.resetGrid();
        // 新增页面
        pageCount += 1;
      }
      logger.i('剩余长度', hadNotInList.length);
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
