import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/states/page_change_notifier.dart';
import 'package:screen_app/widgets/card/edit.dart';
import 'package:screen_app/widgets/keep_alive_wrapper.dart';
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

class DevicePage extends StatefulWidget {
  DevicePage({Key? key}) : super(key: key);

  // 创建一个全局的定时器
  Timer? _timer;

  // 页数计算器
  // int currentPage = 0;

  // 启动定时器
  Future<void> startPolling(BuildContext context) async {
    const oneMinute = Duration(seconds: 180);
    // 立即清除一次
    final deviceModel = context.read<DeviceInfoListModel>();
    final layoutModel = context.read<LayoutModel>();
    List<DeviceEntity> deviceRes = await deviceModel.getDeviceList();
    List<String> layoutDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type == DeviceEntityTypeInP4.Scene &&
            element.type == DeviceEntityTypeInP4.Weather &&
            element.type == DeviceEntityTypeInP4.Clock &&
            element.type == DeviceEntityTypeInP4.DeviceEdit)
        .map((e) => e.deviceId)
        .toList();
    List<String> netListDeviceIds =
        deviceRes.map((e) => e.applianceCode).toList();
    List<List<String>> compareDevice =
        Compare.compareData<String>(layoutDeviceIds, netListDeviceIds);
    compareDevice[1].forEach((compare) {
      Layout curLayout = layoutModel.getLayoutsByDevice(compare);
      int curPageIndex = curLayout.pageIndex;
      if (layoutModel.hasLayoutWithDeviceId(compare)) {
        layoutModel.deleteLayout(compare);
        // 检查还有没有不是空卡
        Log.i('检查是否还有空卡');
        bool hasNotNullCard = layoutModel.layouts.any((element) =>
            element.cardType != CardType.Null &&
            element.pageIndex == curPageIndex);
        Log.i('是否有$curPageIndex页的其他空卡', curLayout.pageIndex);
        if (!hasNotNullCard) {
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
        } else {
          // 删除后还有其他有效卡片就补回去那张删掉的空卡片
          // 因为要流式布局就要删掉空卡片，重新排过
          List<Layout> curPageLayoutsAfterFill = Layout.flexLayout(
              layoutModel.getLayoutsByPageIndex(curLayout.pageIndex));
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
          for (int o = 0; o < curPageLayoutsAfterFill.length; o++) {
            layoutModel.addLayout(curPageLayoutsAfterFill[o]);
          }
        }
        // 看看是否删空
        if (!layoutModel.layouts
            .map((e) => e.pageIndex)
            .contains(curLayout.pageIndex)) {
          layoutModel.handleNullPage(curLayout.pageIndex);
          curLayout.pageIndex =
              (curLayout.pageIndex - 1) < 0 ? 0 : (curLayout.pageIndex - 1);
        }
      }
    });
    // 使用周期性定时器，每分钟触发一次
    _timer = Timer.periodic(oneMinute, (Timer timer) async {
      autoDeleleLayout(context);
    });
  }

  Future<void> autoDeleleLayout(BuildContext context) async {
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
    Log.i('对比后发现删除了', compareDevice[1]);
    compareDevice[1].forEach((compare) {
      Layout curLayout = layoutModel.getLayoutsByDevice(compare.applianceCode);
      int curPageIndex = curLayout.pageIndex;
      if (layoutModel.hasLayoutWithDeviceId(compare.applianceCode)) {
        layoutModel.deleteLayout(compare.applianceCode);
        // 检查还有没有不是空卡
        Log.i('检查是否还有空卡');
        bool hasNotNullCard = layoutModel.layouts.any((element) =>
            element.cardType != CardType.Null &&
            element.pageIndex == curPageIndex);
        Log.i('是否有$curPageIndex页的其他空卡', curLayout.pageIndex);
        if (!hasNotNullCard) {
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
        } else {
          // 删除后还有其他有效卡片就补回去那张删掉的空卡片
          // 因为要流式布局就要删掉空卡片，重新排过
          List<Layout> curPageLayoutsAfterFill = Layout.flexLayout(
              layoutModel.getLayoutsByPageIndex(curLayout.pageIndex));
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
          for (int o = 0; o < curPageLayoutsAfterFill.length; o++) {
            layoutModel.addLayout(curPageLayoutsAfterFill[o]);
          }
        }
        // 看看是否删空
        if (!layoutModel.layouts
            .map((e) => e.pageIndex)
            .contains(curLayout.pageIndex)) {
          layoutModel.handleNullPage(curLayout.pageIndex);
          curLayout.pageIndex =
              (curLayout.pageIndex - 1) < 0 ? 0 : (curLayout.pageIndex - 1);
        }
        TipsUtils.toast(content: '已删除${compare.name}');
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  PageController _pageController = PageController();
  List<Widget> _screens = [];
  GlobalKey<_IndicatorState> indicatorState = GlobalKey();

  LayoutModel? layoutModel;

  @override
  void initState() {
    super.initState();
    _startPushListen();
    Log.develop("DevicePageState initState");
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);
    deviceListModel.getDeviceList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.startPolling(context);
    });
    bus.on("mainToRecoverState", changeToTargetPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    layoutModel = context.read<LayoutModel>();
  }

  @override
  void dispose() {
    _stopPushListen();
    Log.develop("DevicePageState dispose");
    bus.off("mainToRecoverState", changeToTargetPage);
    widget.stopPolling();
    super.dispose();
  }

  /// 显示更改页面的位置
  void changeToTargetPage(dynamic position) {
    if (mounted) {
      final pageCounterModel = Provider.of<PageCounter>(context, listen: false);
      Log.i('切换到页面：${pageCounterModel.currentPage}');
      _pageController.jumpToPage(pageCounterModel.currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          PageView.builder(
            key: const ValueKey("123456"),
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              context.read<PageCounter>().currentPage = index;
              Log.i("scroll page = $index");
              indicatorState.currentState?.updateIndicator();
            },
            allowImplicitScrolling: true,
            itemCount: _screens.length,
            itemBuilder: (context, index) {
              return KeepAliveWrapper(child: _screens[index]);
            },
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
        Indicator(
            key: indicatorState,
            pageController: _pageController,
            itemCount: _screens.length)
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
          key: UniqueKey(),
          crossAxisCellCount: sizeMap[layoutAfterSort.cardType]!['cross']!,
          child: UnconstrainedBox(
            key: UniqueKey(),
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
        );
        // 扔进页面里
        curScreenWidgetList.add(cardWithPosition);
      }
      // ************单页构造

      // ************插入pageview
      _screens.add(
        UnconstrainedBox(
          key: UniqueKey(),
          child: Container(
            width: 480,
            height: 480,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
            child: SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                axisDirection: AxisDirection.down,
                children: curScreenWidgetList,
              ),
            ),
          ),
        ),
      );
      // ************插入pageview

      if (!isCanAdd) {
        _screens.add(Center(key: UniqueKey(), child: const EditCardWidget()));
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

  void homluxDeviceListChange(HomluxLanDeviceChange arg) {
    handleHomluxDeviceListChange();
  }

  void homluxPushGroupDelete(HomluxGroupDelEvent arg) {
    handlePushDelete();
  }

  handleHomluxDeviceListChange() {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList();
  }

  handlePushDelete() async {
    Log.i('更新列表');
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
    compareDevice[1].forEach((compare) {
      Layout curLayout = layoutModel.getLayoutsByDevice(compare.applianceCode);
      int curPageIndex = curLayout.pageIndex;
      if (layoutModel.hasLayoutWithDeviceId(compare.applianceCode)) {
        layoutModel.deleteLayout(compare.applianceCode);
        // 检查还有没有不是空卡
        Log.i('检查是否还有空卡');
        bool hasNotNullCard = layoutModel.layouts.any((element) =>
            element.cardType != CardType.Null &&
            element.pageIndex == curPageIndex);
        Log.i('是否有$curPageIndex页的其他空卡', curLayout.pageIndex);
        if (!hasNotNullCard) {
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
        } else {
          // 删除后还有其他有效卡片就补回去那张删掉的空卡片
          // 因为要流式布局就要删掉空卡片，重新排过
          List<Layout> curPageLayoutsAfterFill = Layout.flexLayout(
              layoutModel.getLayoutsByPageIndex(curLayout.pageIndex));
          layoutModel.layouts.removeWhere(
              (element) => element.pageIndex == curLayout.pageIndex);
          for (int o = 0; o < curPageLayoutsAfterFill.length; o++) {
            layoutModel.addLayout(curPageLayoutsAfterFill[o]);
          }
        }
        // 看看是否删空
        if (!layoutModel.layouts
            .map((e) => e.pageIndex)
            .contains(curLayout.pageIndex)) {
          layoutModel.handleNullPage(curLayout.pageIndex);
          curLayout.pageIndex =
              (curLayout.pageIndex - 1) < 0 ? 0 : (curLayout.pageIndex - 1);
        }
        TipsUtils.toast(content: '已删除${compare.name}');
      }
    });
  }

  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxMovWifiDeviceEvent>(homluxPushMov);
      bus.typeOn<HomluxMovSubDeviceEvent>(homluxPushSubMov);
      bus.typeOn<HomluxDelWiFiDeviceEvent>(homluxPushDel);
      bus.typeOn<HomluxDelSubDeviceEvent>(homluxPushSubDel);
      bus.typeOn<HomluxGroupDelEvent>(homluxPushGroupDelete);
      bus.typeOn<HomluxLanDeviceChange>(homluxDeviceListChange);
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
      bus.typeOff<HomluxLanDeviceChange>(homluxDeviceListChange);
    } else {
      bus.typeOff<MeiJuDeviceDelEvent>(meijuPushDelete);
    }
  }
}

class Indicator extends StatefulWidget {
  final PageController pageController;
  final int itemCount;

  const Indicator(
      {super.key, required this.pageController, required this.itemCount});

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  void updateIndicator() {
    Log.i("update indicator ${widget.pageController.page}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Positioned(
          left: 215,
          bottom: 12,
          child: Stack(
            children: [
              Positioned(
                left: (widget.pageController.page?.round() ?? 0) /
                    (widget.itemCount - 1) *
                    25,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 背景颜色
                    borderRadius: BorderRadius.circular(10.0), // 圆角半径
                  ),
                ),
              ),
              Container(
                width: 51,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // 背景颜色
                  borderRadius: BorderRadius.circular(10.0), // 圆角半径
                ),
              ),
            ],
          ));
    });
  }
}
