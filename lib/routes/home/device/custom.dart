import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/states/page_change_notifier.dart';

import '../../../common/adapter/select_room_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/global.dart';
import '../../../common/homlux/models/homlux_room_list_entity.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/models/meiju_room_entity.dart';
import '../../../common/system.dart';
import '../../../states/layout_notifier.dart';
import '../../../widgets/mz_buttion.dart';
import 'card_dialog.dart';
import 'card_type_config.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final PageController _pageController = PageController();
  int curPageIndex = 0;
  List<Widget> _screens = [];
  late Layout curLayout;
  String dragingWidgetId = '';
  String overlayId = '';
  List<Layout> curscreenLayout = [];
  List<Layout> backupLayout = [];
  double dragSumX = 0;
  double dragSumY = 0;

  List<MeiJuRoomEntity>? meijuRoomList;
  List<HomluxRoomInfo>? homluxRoomList;

  @override
  void initState() {
    super.initState();
    getRoomList();
    // 在小部件初始化后等待一帧再执行回调
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      var initPage = context.read<PageCounter>().currentPage;
      if (initPage > _screens.length - 1) {
        initPage = _screens.length - 1;
      }
      _pageController.animateToPage(initPage,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getRoomList() async {
    SelectRoomDataAdapter roomDataAd =
    SelectRoomDataAdapter(MideaRuntimePlatform.platform);
    await roomDataAd?.queryRoomList(System.familyInfo!);
    homluxRoomList=roomDataAd.homluxRoomList;
    meijuRoomList=roomDataAd.meijuRoomList;
  }

  @override
  Widget build(BuildContext context) {
    final layoutModel = Provider.of<LayoutModel>(context);
    // 获取屏幕信息
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    // 处理布局信息
    if (mounted) {
      _screens = getScreenList(screenWidth, screenHeight, layoutModel);
    }
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
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              curPageIndex = index;
            },
            itemCount: _screens.length,
            itemBuilder: (BuildContext context, int index) {
              return _screens[index];
            },
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
                        backgroundColor: layoutModel.layouts.length >= 16
                            ? const Color(0xFF818C98).withOpacity(0.6)
                            : const Color(0xFF818C98),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        text: '添加(${layoutModel.layouts.length})',
                        textColor: layoutModel.layouts.length >= 10000
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                        onPressed: () async {
                          if (layoutModel.layouts.length < 10000) {
                            final result = await Navigator.pushNamed(context, 'AddDevice',arguments: {"meijuRoomList": meijuRoomList, "homluxRoomList": homluxRoomList});

                            if (result != null) {
                              result as Layout;
                              // 处理回调的增加信息
                              // 尝试增加在当页
                              // 初始化布局占位器
                              Screen screenLayer = Screen();
                              // 拿到当前页的layout
                              List<Layout> layoutsInCurPage = layoutModel
                                  .getLayoutsByPageIndex(curPageIndex);
                              if (layoutsInCurPage.isNotEmpty) {
                                // 非空页
                                for (int layoutInCurPageIndex = 0;
                                    layoutInCurPageIndex <
                                        layoutsInCurPage.length;
                                    layoutInCurPageIndex++) {
                                  // 取出当前布局的grids
                                  for (int gridsIndex = 0;
                                      gridsIndex <
                                          layoutsInCurPage[layoutInCurPageIndex]
                                              .grids
                                              .length;
                                      gridsIndex++) {
                                    // 把已经布局的数据在布局器中占位
                                    int grid =
                                        layoutsInCurPage[layoutInCurPageIndex]
                                            .grids[gridsIndex];
                                    int row = (grid - 1) ~/ 4;
                                    int col = (grid - 1) % 4;
                                    screenLayer.setCellOccupied(row, col, true);
                                  }
                                }
                                // 查询是否已经用持久化的数据就填满了这一页
                                List<int> arrHasPosition =
                                    screenLayer.getOccupiedGridIndices();
                                // 尝试占位
                                List<int> fillCells = screenLayer
                                    .checkAvailability(result.cardType);
                                Log.i('新卡片占位尝试结果', fillCells);
                                if (fillCells.isEmpty) {
                                  Log.i('屏幕被占满或放不下');
                                  // 屏幕占满或放不下
                                  int maxPage = layoutModel.getMaxPageIndex();
                                  // 找到有合适空位的一页
                                  LayoutPosition proFlexiblePage = layoutModel
                                      .getFlexiblePage(result.cardType);
                                  if (proFlexiblePage.pageIndex > -1) {
                                    result.pageIndex =
                                        proFlexiblePage.pageIndex;
                                    result.grids = proFlexiblePage.grids;
                                    Log.i('找到了合适的位置',
                                        '${result.pageIndex}页${result.grids}');
                                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                                      _pageController.animateToPage(result.pageIndex,
                                          duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                    });
                                  } else {
                                    // 放到最后一页
                                    // 清空布局器
                                    screenLayer.resetGrid();
                                    // 占位
                                    List<int> fillCells = screenLayer
                                        .checkAvailability(result.cardType);
                                    result.pageIndex = maxPage + 1;
                                    result.grids = fillCells;
                                  }
                                  result.data.disabled = true;
                                  result.data.context = context;
                                  result.data.disableOnOff = false;
                                  Widget cardWidget =
                                      buildMap[result.type]![result.cardType]!(
                                          result.data);
                                  // 映射图标
                                  Widget cardWithIcon = Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 20),
                                        child: cardWidget,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            Layout deleteBackup =
                                                layoutModel.getLayoutsByDevice(
                                                    result.deviceId);
                                            layoutModel.deleteLayout(
                                                result.deviceId);
                                            if (!layoutModel.layouts.map((e) => e.pageIndex).contains(result.pageIndex)) {
                                              layoutModel.handleNullPage(result.pageIndex);
                                            }
                                            // 取出当前布局的grids
                                            for (int gridsIndex = 0;
                                                gridsIndex <
                                                    deleteBackup.grids.length;
                                                gridsIndex++) {
                                              // 把已经布局的数据在布局器中占位
                                              int grid = deleteBackup
                                                  .grids[gridsIndex];
                                              int row = (grid - 1) ~/ 4;
                                              int col = (grid - 1) % 4;
                                              screenLayer.setCellOccupied(
                                                  row, col, false);
                                            }
                                          },
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
                                        ),
                                      ),
                                    ],
                                  );
                                  // 映射拖拽
                                  Widget cardWithDrag =
                                      LongPressDraggable<String>(
                                    data: result.deviceId,
                                    // 拖拽时原位置的样子
                                    childWhenDragging: Opacity(
                                      opacity:
                                          result.deviceId == dragingWidgetId
                                              ? 0.5
                                              : 1,
                                      child: Container(
                                        child: cardWithIcon,
                                      ),
                                    ),
                                    // 拖拽时的样子
                                    feedback: cardWidget,
                                    onDragStarted: () {
                                      setState(() {
                                        Log.i('触发拖拽开始');
                                        dragingWidgetId = result.deviceId;
                                        curLayout =
                                            layoutModel.getLayoutsByDevice(
                                                result.deviceId);
                                        curscreenLayout =
                                            layoutModel.getLayoutsByPageIndex(
                                                curPageIndex);
                                        backupLayout = [...curscreenLayout];
                                      });
                                    },
                                    onDragUpdate: (details) {
                                      // 计算出拖拽中卡片的位置
                                      dragSumX += details.delta.dx;
                                      dragSumY += details.delta.dy;
                                      Log.i('锚点', details.delta);
                                      List<Layout> curScreenLayouts =
                                          layoutModel.getLayoutsByPageIndex(
                                              curPageIndex);
                                      // 填充
                                      List<Layout> fillNullLayoutList =
                                          layoutModel.fillNullLayoutList(
                                              curScreenLayouts, curPageIndex);
                                      // 排序
                                      List<Layout> sortedLayoutList =
                                          Layout.sortLayoutList(
                                              fillNullLayoutList);
                                      if (curLayout.grids ==
                                          [5, 6, 7, 8, 9, 10, 11, 12]) {
                                        if (dragSumY > 50) {
                                          // 源
                                          Layout source = sortedLayoutList
                                              .firstWhere((item) =>
                                                  item.deviceId ==
                                                  dragingWidgetId);

                                          // 目标
                                          Layout target = Layout(
                                            uuid.v4(),
                                            DeviceEntityTypeInP4.Default,
                                            CardType.Big,
                                            curPageIndex,
                                            [9, 10, 11, 12, 13, 14, 15, 16],
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
                                          );

                                          layoutModel.swapPosition(
                                              source, target);
                                        } else if (dragSumX < -50) {
                                          // 源
                                          Layout source = sortedLayoutList
                                              .firstWhere((item) =>
                                                  item.deviceId ==
                                                  dragingWidgetId);

                                          // 目标
                                          Layout target = Layout(
                                            uuid.v4(),
                                            DeviceEntityTypeInP4.Default,
                                            CardType.Big,
                                            curPageIndex,
                                            [1, 2, 3, 4, 5, 6, 7, 8],
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
                                          );

                                          layoutModel.swapPosition(
                                              source, target);
                                        }
                                      } else if (curLayout.grids ==
                                          [5, 6, 9, 10]) {
                                      } else if (curLayout.grids ==
                                          [3, 4, 11, 12]) {}
                                      ;
                                    },
                                    onDragEnd: (detail) {
                                      Log.i('拖拽结束');
                                      setState(() {
                                        dragSumX = 0;
                                        dragSumY = 0;
                                        dragingWidgetId = '';
                                      });
                                    },
                                    onDraggableCanceled: (_, __) {},
                                    child: DragTarget<String>(
                                      builder: (context, candidateData,
                                          rejectedData) {
                                        return Opacity(
                                          opacity:
                                              result.deviceId == dragingWidgetId
                                                  ? 0.5
                                                  : 1,
                                          child: Container(
                                            child: cardWithIcon,
                                          ),
                                        );
                                      },
                                      onAccept: (data) {
                                        Log.i('拖拽结束');
                                        setState(() {
                                          dragSumX = 0;
                                          dragSumY = 0;
                                          dragingWidgetId = '';
                                        });
                                      },
                                      onLeave: (data) {},
                                      onWillAccept: (data) {
                                        // 计算被移动多少格,滑动1格以上算滑动
                                        double absX = dragSumX.abs();
                                        double absY = dragSumY.abs();
                                        if (absX < 50 && absY < 50) {
                                          return false;
                                        } else {
                                          List<Layout> curScreenLayouts =
                                              layoutModel.getLayoutsByPageIndex(
                                                  curPageIndex);
                                          // 填充
                                          List<Layout> fillNullLayoutList =
                                              layoutModel.fillNullLayoutList(
                                                  curScreenLayouts,
                                                  curPageIndex);
                                          // 排序
                                          List<Layout> sortedLayoutList =
                                              Layout.sortLayoutList(
                                                  fillNullLayoutList);
                                          // 源
                                          Layout source = sortedLayoutList
                                              .firstWhere((item) =>
                                                  item.deviceId ==
                                                  dragingWidgetId);

                                          // 目标
                                          Layout target = sortedLayoutList
                                              .firstWhere((item) =>
                                                  item.deviceId ==
                                                  result.deviceId);

                                          layoutModel.swapPosition(
                                              source, target);
                                          return true;
                                        }
                                      },
                                    ),
                                  );
                                  // 映射占位
                                  Widget cardWithPosition =
                                      StaggeredGridTile.fit(
                                          crossAxisCellCount: sizeMap[
                                              result.cardType]!['cross']!,
                                          child: cardWithDrag);
                                  // 扔进pageview里
                                  _screens.add(
                                    UnconstrainedBox(
                                      child: Container(
                                        width: 480,
                                        height: 480,
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 32, 20, 34),
                                        child: StaggeredGrid.count(
                                          crossAxisCount: 4,
                                          mainAxisSpacing: 20,
                                          crossAxisSpacing: 20,
                                          axisDirection: AxisDirection.down,
                                          children: [cardWithPosition],
                                        ),
                                      ),
                                    ),
                                  );
                                  // 跳到最后一页
                                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                                    _pageController.animateToPage(maxPage + 1,
                                        duration:
                                        const Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  });
                                } else {
                                  // 屏幕没占满又放的下,重构该页
                                  // 拿到当前页的layout
                                  logger.i('屏幕没占满又放的下');
                                  List<Layout> layoutsInCurPage = layoutModel
                                      .getLayoutsByPageIndex(curPageIndex);
                                  result.grids = fillCells;
                                  result.pageIndex = curPageIndex;
                                  layoutsInCurPage.add(result);
                                  List<Layout> sortedLayoutList =
                                      Layout.sortLayoutList(layoutsInCurPage);
                                  List<Widget> curScreenWidgetList = [];
                                  // 根据队列顺序插入该屏页面
                                  for (Layout layoutAfterSort
                                      in sortedLayoutList) {
                                    // 映射出对应的Card
                                    layoutAfterSort.data.disabled = true;
                                    layoutAfterSort.data.disableOnOff = false;
                                    layoutAfterSort.data.context = context;
                                    Widget cardWidget = buildMap[layoutAfterSort
                                            .type]![layoutAfterSort.cardType]!(
                                        layoutAfterSort.data);
                                    // 映射布局占格
                                    Widget cardWithPosition =
                                        StaggeredGridTile.fit(
                                      crossAxisCellCount: sizeMap[
                                          layoutAfterSort.cardType]!['cross']!,
                                      child:
                                          UnconstrainedBox(child: cardWidget),
                                    );
                                    // 扔进页面里
                                    curScreenWidgetList.add(cardWithPosition);
                                  }
                                  logger.i('映射后的列表', curScreenWidgetList);
                                  // ************插入pageview
                                  _screens[curPageIndex] = UnconstrainedBox(
                                    child: Container(
                                      width: 480,
                                      height: 480,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 32, 20, 34),
                                      child: StaggeredGrid.count(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        axisDirection: AxisDirection.down,
                                        children: [...curScreenWidgetList],
                                      ),
                                    ),
                                  );
                                  // ************插入pageview
                                }
                              } else {
                                logger.i('空页直接插入', curPageIndex);
                                // 空页直接插入
                                result.pageIndex = curPageIndex;
                                // 占位
                                List<int> fillCells = screenLayer
                                    .checkAvailability(result.cardType);
                                result.grids = fillCells;
                                result.data.disabled = true;
                                result.data.disableOnOff = false;
                                result.data.context = context;
                                Widget cardWidget =
                                    buildMap[result.type]![result.cardType]!(
                                        result.data);
                                // 映射布局占格
                                Widget cardWithPosition = StaggeredGridTile.fit(
                                  crossAxisCellCount:
                                      sizeMap[result.cardType]!['cross']!,
                                  child: UnconstrainedBox(child: cardWidget),
                                );
                                // 插入pageview
                                _screens.add(
                                  UnconstrainedBox(
                                    child: Container(
                                      width: 480,
                                      height: 480,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 32, 20, 34),
                                      child: StaggeredGrid.count(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        axisDirection: AxisDirection.down,
                                        children: [cardWithPosition],
                                      ),
                                    ),
                                  ),
                                );
                                logger.i('屏幕列表', _screens);
                              }
                              layoutModel.addLayout(result);
                            }
                          }
                        },
                      ),
                      MzButton(
                        width: 168,
                        height: 56,
                        borderRadius: 29,
                        backgroundColor: const Color(0xFF267AFF),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        text: '完成',
                        onPressed: () {
                          layoutModel.setLayouts(layoutModel.layouts);
                          Navigator.pop(context, '自定义返回');
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

  List<Widget> getScreenList(
      double width, double height, LayoutModel layoutModel) {
    // 屏幕页面列表
    List<Widget> screenList = [];
    // 计算出网格的宽高
    double gridWidth = width / 4;
    double gridHeight = height / 4;
    // 最大页数
    int maxPage = layoutModel.getMaxPageIndex();
    for (int page = 0; page <= maxPage; page++) {
      // 收集当前page的widget
      List<Widget> curScreenWidgets = [];
      // 拿到当前页的layout
      List<Layout> curScreenLayouts = layoutModel.getLayoutsByPageIndex(page);
      // 逃避空页
      if (curScreenLayouts.isEmpty) continue;
      // 填充
      List<Layout> fillNullLayoutList =
          layoutModel.fillNullLayoutList(curScreenLayouts, page);
      // 排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(fillNullLayoutList);
      // 映射成widget放进去
      for (Layout layout in sortedLayoutList) {
        layout.data.disabled = true;
        layout.data.disableOnOff = false;
        layout.data.context = context;
        // 映射出对应的Card
        Widget cardWidget =
            buildMap[layout.type]![layout.cardType]!(layout.data);
        if (layout.type == DeviceEntityTypeInP4.DeviceNull) {
          Widget cardWithPosition = StaggeredGridTile.fit(
            crossAxisCellCount: sizeMap[layout.cardType]!['cross']!,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, top: 20),
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return cardWidget;
                },
                onWillAccept: (data) {
                  // 计算被移动多少格,滑动1格以上算滑动
                  double absX = dragSumX.abs();
                  double absY = dragSumY.abs();
                  if (absX < 50 && absY < 50) {
                    return false;
                  } else {
                    layoutModel.swapPosition(
                      sortedLayoutList
                          .firstWhere((item) => item.deviceId == data),
                      sortedLayoutList.firstWhere(
                          (item) => item.deviceId == layout.deviceId),
                    );
                    return true;
                  }
                },
                onAccept: (data) {
                  Log.i('拖拽结束');
                  setState(() {
                    dragSumX = 0;
                    dragSumY = 0;
                    dragingWidgetId = '';
                  });
                },
              ),
            ),
          );
          curScreenWidgets.add(cardWithPosition);
        } else {
          // 映射点击（用于置换）
          Widget cardWithSwap = GestureDetector(
            onTap: () {
              _getDeviceDialog(context, layout);
            },
            child: AbsorbPointer(absorbing: true, child: cardWidget),
          );
          // 映射图标
          Widget cardWithIcon = Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 20),
                child: cardWithSwap,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () async {
                    await layoutModel.deleteLayout(layout.deviceId);
                    // 看看是否删空
                    if (!layoutModel.layouts.map((e) => e.pageIndex).contains(layout.pageIndex)) {
                      layoutModel.handleNullPage(layout.pageIndex);
                    }
                  },
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
                ),
              )
            ],
          );
          // 映射拖拽
          Widget cardWithDrag = LongPressDraggable<String>(
            data: layout.deviceId,
            // 拖拽时原位置的样子
            childWhenDragging: Opacity(
              opacity: layout.deviceId == dragingWidgetId ? 0.5 : 1,
              child: Container(
                child: cardWithIcon,
              ),
            ),
            // 拖拽时的样子
            feedback: cardWidget,
            onDragStarted: () {
              setState(() {
                dragingWidgetId = layout.deviceId;
                curLayout = layoutModel.getLayoutsByDevice(layout.deviceId);
                curscreenLayout =
                    layoutModel.getLayoutsByPageIndex(layout.pageIndex);
                backupLayout = [...curscreenLayout];
              });
            },
            onDragUpdate: (details) {
              // 计算出拖拽中卡片的位置
              dragSumX += details.delta.dx;
              dragSumY += details.delta.dy;
            },
            onDragEnd: (detail) {
              Log.i('拖拽结束');
              setState(() {
                dragSumX = 0;
                dragSumY = 0;
                dragingWidgetId = '';
              });
            },
            onDraggableCanceled: (_, __) {},
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Opacity(
                  opacity: layout.deviceId == dragingWidgetId ? 0.5 : 1,
                  child: Container(
                    child: cardWithIcon,
                  ),
                );
              },
              onAccept: (data) {
                Log.i('拖拽结束');
                setState(() {
                  dragSumX = 0;
                  dragSumY = 0;
                  dragingWidgetId = '';
                });
              },
              onLeave: (data) {},
              onWillAccept: (data) {
                // 计算被移动多少格,滑动1格以上算滑动
                double absX = dragSumX.abs();
                double absY = dragSumY.abs();
                if (absX < 50 && absY < 50) {
                  return false;
                } else {
                  layoutModel.swapPosition(
                    sortedLayoutList
                        .firstWhere((item) => item.deviceId == data),
                    sortedLayoutList
                        .firstWhere((item) => item.deviceId == layout.deviceId),
                  );
                  return true;
                }
              },
            ),
          );
          // 映射占位
          Widget cardWithPosition = StaggeredGridTile.fit(
              crossAxisCellCount: sizeMap[layout.cardType]!['cross']!,
              child: cardWithDrag);
          curScreenWidgets.add(cardWithPosition);
        }
      }
      // 每一页插入屏幕表
      screenList.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 0, 34),
          child: SingleChildScrollView(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              axisDirection: AxisDirection.down,
              children: [...curScreenWidgets],
            ),
          ),
        ),
      );
    }
    // 布局结束，抛出屏幕列表
    return screenList;
  }
}

_getDeviceDialog(BuildContext context, Layout layout) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CardDialog(
        name: layout.data.name,
        type: layout.data.type,
        applianceCode: layout.data.applianceCode,
        modelNumber: layout.data.modelNumber,
        icon: layout.data.icon,
        roomName: layout.data.roomName,
        masterId: layout.data.masterId,
        onlineStatus: layout.data.onlineStatus,
      );
    },
  ).then(
    (value) {
      if (value != null) {
        context.read<LayoutModel>().swapCardType(layout, value);
      }
    },
  );
}