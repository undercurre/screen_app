import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/states/page_change_notifier.dart';
import 'package:screen_app/widgets/card/edit.dart';
import 'package:screen_app/widgets/util/debouncer.dart';

import '../../../common/api/api.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/util/compare.dart';
import '../../../widgets/util/deviceEntityTypeInP4Handle.dart';
import 'card_type_config.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class newPage extends StatefulWidget {
  newPage({Key? key}) : super(key: key);

  // 创建一个全局的定时器
  Timer? _timer;

  // 页数计算器
  int currentPage = 0;

  // 启动定时器
  void startPolling(BuildContext context) {
    const oneMinute = Duration(minutes: 5);

    // 使用周期性定时器，每分钟触发一次
    _timer = Timer.periodic(oneMinute, (Timer timer) async {
      final deviceModel = context.read<DeviceInfoListModel>();
      final layoutModel = context.read<LayoutModel>();
      List<DeviceEntity> deviceCache = deviceModel.deviceCacheList;
      List<DeviceEntity> deviceRes = await deviceModel.getDeviceList();
      deviceCache = deviceCache
          .where((element) =>
      DeviceEntityTypeInP4Handle.getDeviceEntityType(
          element.type, element.modelNumber) !=
          DeviceEntityTypeInP4.Default)
          .toList();
      deviceRes = deviceRes
          .where((element) =>
      DeviceEntityTypeInP4Handle.getDeviceEntityType(
          element.type, element.modelNumber) !=
          DeviceEntityTypeInP4.Default)
          .toList();
      List<List<DeviceEntity>> compareDevice =
      Compare.compareData<DeviceEntity>(deviceCache, deviceRes);
      compareDevice[1].forEach((element) {
        layoutModel.deleteLayout(element.applianceCode);
        TipsUtils.toast(content: '已删除${element.name}');
      });
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<newPage> {
  final PageController _pageController = PageController();
  List<Widget> _screens = [];

  LayoutModel? layoutModel;

  @override
  void initState() {
    super.initState();
    _startPushListen();
    final deviceListModel =
    Provider.of<DeviceInfoListModel>(context, listen: false);
    deviceListModel.getDeviceList();
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      widget.startPolling(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    layoutModel = context.read<LayoutModel>();
  }

  @override
  void dispose() {
    _stopPushListen();
    super.dispose();
    widget.stopPolling();
  }

  @override
  Widget build(BuildContext context) {
    final Debouncer debouncer = Debouncer(milliseconds: 2000);
    // 处理布局信息
    final layoutModel = Provider.of<LayoutModel>(context);
    if (mounted) {
      try {
        getScreenList(layoutModel);
      } catch (e) {
        Log.i('Error', e);
        _screens = [];
      }
    }
    // logger.i('屏幕页面数量', _screens.length);
    return Stack(
      children: [
        if (layoutModel.layouts.isNotEmpty)
        // PageView.builder(
        //   controller: _pageController,
        //   scrollDirection: Axis.horizontal,
        //   onPageChanged: (index) {
        //     context.read<PageCounter>().currentPage = index;
        //     _pageController.animateToPage(index,
        //         duration: const Duration(milliseconds: 10),
        //         curve: Curves.ease);
        //     // debouncer.run(() {
        //     //   setState(() {
        //     //     widget.currentPage = index;
        //     //   });
        //     // });
        //   },
        //   itemCount: _screens.length,
        //   itemBuilder: (context, index) {
        //     return _screens[index];
        //   },
        // ),
          Container(
            width: 480,
            height: 480,
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 34),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                axisDirection: AxisDirection.right,
                children: _screens,
              ),
            ),
          ),

        if (layoutModel.layouts.isEmpty)
          const SizedBox(
            width: 480,
            height: 480,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/newUI/empty.png')),
                  Padding(
                    padding: EdgeInsets.only(top: 21),
                    child: EditCardWidget(),
                  )
                ],
              ),
            ),
          ),
        // Positioned(
        //     left: 215,
        //     bottom: 12,
        //     child: Stack(
        //       children: [
        //         Positioned(
        //           left: widget.currentPage / (_screens.length - 1) * 25,
        //           bottom: 0,
        //           child: Container(
        //             width: 26,
        //             height: 4,
        //             decoration: BoxDecoration(
        //               color: Colors.white.withOpacity(0.8), // 背景颜色
        //               borderRadius: BorderRadius.circular(10.0), // 圆角半径
        //             ),
        //           ),
        //         ),
        //         Container(
        //           width: 51,
        //           height: 4,
        //           decoration: BoxDecoration(
        //             color: Colors.white.withOpacity(0.1), // 背景颜色
        //             borderRadius: BorderRadius.circular(10.0), // 圆角半径
        //           ),
        //         ),
        //       ],
        //     )),
      ],
    );
  }

  List<Widget> getScreenList(LayoutModel layoutModel) {
    // 清空
    _screens.clear();
    // 当前页面的widgets
    List<Widget> curScreenWidgetList = [];
    // 当前要布局的页面
    int pageCount = 0;
    // 已经被排布的页面数量
    int hadPageCount = layoutModel.getMaxPageIndex();
    // 初始化布局占位器
    Screen screenLayer = Screen();

    if (layoutModel.layouts.isEmpty) {
      _screens.add(const Center(child: EditCardWidget()));
      return _screens;
    }

    for (; pageCount <= hadPageCount; pageCount++) {
      // ************布局
      // 先获取当前页的布局，设置screenLayer布局器
      List<Layout> layoutsInCurPage =
      layoutModel.getLayoutsByPageIndex(pageCount);
      // 逃避空页
      if (layoutsInCurPage.isEmpty) continue;
      for (int layoutInCurPageIndex = 0;
      layoutInCurPageIndex < layoutsInCurPage.length;
      layoutInCurPageIndex++) {
        // 取出当前布局的grids
        for (int gridsIndex = 0;
        gridsIndex < layoutsInCurPage[layoutInCurPageIndex].grids.length;
        gridsIndex++) {
          // 把已经布局的数据在布局器中占位
          int grid = layoutsInCurPage[layoutInCurPageIndex].grids[gridsIndex];
          int row = (grid - 1) ~/ 4;
          int col = grid % 4 - 1 != -1 ? grid % 4 - 1 : 3;
          screenLayer.setCellOccupied(row, col, true);
        }
      }
      // ************布局

      // ************单页构造
      // 当前页
      List<Layout> curScreenLayouts =
      layoutModel.getLayoutsByPageIndex(pageCount);
      // 处理editCard
      bool isCanAdd = true;
      // if (pageCount == hadPageCount && hadNotInList.isEmpty) {
      if (pageCount == hadPageCount) {
        List<int> editCardFillCells =
        screenLayer.checkAvailability(CardType.Edit);
        // Log.i('编辑条目占位结果', editCardFillCells);
        // 当占位成功
        List<int> sumGrid = [];
        curScreenLayouts.forEach((element) {
          sumGrid.addAll(element.grids);
        });
        if (editCardFillCells.isNotEmpty &&
            editCardFillCells[0] > sumGrid.reduce(max)) {
          curScreenLayouts.add(
            Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceEdit,
              CardType.Edit,
              hadPageCount,
              editCardFillCells,
              DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1',
              ),
            ),
          );
        } else {
          isCanAdd = false;
        }
      }
      // 填充
      // List<Layout> fillNullLayoutList =
      //     layoutModel.fillNullLayoutList(curScreenLayouts, pageCount);
      // 映射排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(curScreenLayouts);
      // 根据队列顺序插入该屏页面
      for (Layout layoutAfterSort in sortedLayoutList) {
        // 映射出对应的Card
        layoutAfterSort.data.disabled = false;
        layoutAfterSort.data.context = context;
        Widget cardWidget =
        buildMap[layoutAfterSort.type]![layoutAfterSort.cardType]!(
            layoutAfterSort.data);
        // 映射布局占格
        Widget cardWithPosition = StaggeredGridTile.fit(
          crossAxisCellCount: sizeMap[layoutAfterSort.cardType]!['main']!,
          child: UnconstrainedBox(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                child: cardWidget,
                onLongPress: () {
                  Navigator.pushNamed(
                    context,
                    'Custom',
                  );
                },
              ),
            ),
          ),
        );
        // 扔进页面里
        curScreenWidgetList.add(cardWithPosition);
      }
      // ************单页构造

      // ************插入pageview
      // _screens.add(
      //   UnconstrainedBox(
      //     child: Container(
      //       width: 480,
      //       height: 480,
      //       padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
      //       child: SingleChildScrollView(
      //         child: StaggeredGrid.count(
      //           crossAxisCount: 4,
      //           mainAxisSpacing: 20,
      //           crossAxisSpacing: 20,
      //           axisDirection: AxisDirection.down,
      //           children: curScreenWidgetList,
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      // ************插入pageview
      _screens.addAll(curScreenWidgetList);
      if (!isCanAdd) {
        _screens.add(const Center(child: EditCardWidget()));
      }

      // 每一页处理前重置布局器
      screenLayer.resetGrid();
      // 每一页处理前情况当前页Widget存储器
      curScreenWidgetList = [];
    }
    return _screens;
  }

  void meijuPushDelete(MeiJuDeviceDelEvent args) {
    handlePushDelete();
  }

  void homluxPushMov(HomluxMovWifiDeviceEvent arg) {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList();
  }

  void homluxPushSubMov(HomluxMovSubDeviceEvent arg) {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList();
  }

  void homluxPushDel(HomluxDelWiFiDeviceEvent arg) {
    handlePushDelete();
  }

  void homluxPushSubDel(HomluxDelSubDeviceEvent arg) {
    handlePushDelete();
  }

  void homluxPushGroupDelete(HomluxGroupDelEvent arg) {
    handlePushDelete();
  }

  handlePushDelete() async {
    Log.i('首页推送响应');
    final deviceModel = context.read<DeviceInfoListModel>();
    final layoutModel = context.read<LayoutModel>();
    List<DeviceEntity> deviceCache = deviceModel.deviceCacheList;
    List<DeviceEntity> deviceRes = await deviceModel.getDeviceList();
    List<List<DeviceEntity>> compareDevice =
    Compare.compareData<DeviceEntity>(deviceCache, deviceRes);
    compareDevice[1].forEach((element) {
      layoutModel.deleteLayout(element.applianceCode);
    });
  }

  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxMovWifiDeviceEvent>(homluxPushMov);
      bus.typeOn<HomluxMovSubDeviceEvent>(homluxPushSubMov);
      bus.typeOn<HomluxDelWiFiDeviceEvent>(homluxPushDel);
      bus.typeOn<HomluxDelSubDeviceEvent>(homluxPushSubDel);
      bus.typeOn<HomluxGroupDelEvent>(homluxPushGroupDelete);
    } else {
      bus.typeOn<MeiJuDeviceDelEvent>(meijuPushDelete);
    }
  }

  void _stopPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOff<HomluxMovWifiDeviceEvent>(homluxPushMov);
      bus.typeOff<HomluxMovSubDeviceEvent>(homluxPushSubMov);
      bus.typeOff<HomluxDelWiFiDeviceEvent>(homluxPushDel);
      bus.typeOff<HomluxDelSubDeviceEvent>(homluxPushSubDel);
      bus.typeOff<HomluxGroupDelEvent>(homluxPushGroupDelete);
    } else {
      bus.typeOff<MeiJuDeviceDelEvent>(meijuPushDelete);
    }
  }
}
