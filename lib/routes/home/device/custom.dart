import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../common/global.dart';
import '../../../common/logcat_helper.dart';
import '../../../states/layout_notifier.dart';
import '../../../widgets/mz_buttion.dart';
import 'card_type_config.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final PageController _pageController = PageController();
  int curPageIndex = 0;
  List<Widget> _screens = [];
  late Layout curLayout;
  String dargingWidgetId = '';
  List<Layout> curscreenLayout = [];
  double dragSumX = 0;
  double dragSumY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(200, 200), // Set the desired coordinate here
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutModel = Provider.of<LayoutModel>(context);
    // 获取屏幕信息
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    // 处理布局信息
    _screens = getScreenList(screenWidth, screenHeight);
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
            onPageChanged: (index) {
              curPageIndex = index;
            },
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
                        onPressed: () async {
                          final result =
                              await Navigator.pushNamed(context, 'AddDevice');

                          if (result != null) {
                            result as Layout;
                            logger.i('增加卡片', result.deviceId);
                            // 处理回调的增加信息
                            // 尝试增加在当页
                            // 初始化布局占位器
                            Screen screenLayer = Screen();
                            // 拿到当前页的layout
                            List<Layout> layoutsInCurPage =
                                layoutModel.getLayoutsByPageIndex(curPageIndex);
                            logger.i('layouts数量', layoutsInCurPage);
                            if (layoutsInCurPage.isNotEmpty) {
                              // 非空页
                              for (int layoutInCurPageIndex = 0;
                                  layoutInCurPageIndex <
                                      layoutsInCurPage.length;
                                  layoutInCurPageIndex++) {
                                logger.i(
                                    '清点当前页已有布局',
                                    layoutsInCurPage[layoutInCurPageIndex]
                                        .grids);
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
                              logger.i('该页已被占据', arrHasPosition);
                              // 尝试占位
                              List<int> fillCells = screenLayer
                                  .checkAvailability(result.cardType);
                              logger.i('新卡片占位尝试结果', fillCells);
                              if (fillCells.isEmpty) {
                                logger.i('屏幕被占满或放不下');
                                // 屏幕占满或放不下
                                int maxPage = layoutModel.getMaxPageIndex();
                                // 找到有合适空位的一页
                                LayoutPosition proFlexiblePage = layoutModel
                                    .getFlexiblePage(result.cardType);
                                if (proFlexiblePage.pageIndex > -1) {
                                  result.pageIndex = proFlexiblePage.pageIndex;
                                  result.grids = proFlexiblePage.grids;
                                  Log.i('找到了合适的位置',
                                      '${result.pageIndex}页${result.grids}');
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
                                Widget cardWidget =
                                    buildMap[result.type]![result.cardType]!(
                                        result.data);
                                // 映射图标
                                Widget cardWithIcon = GestureDetector(
                                  onTap: () {
                                    logger.i('删除卡片');
                                    layoutModel.deleteLayout(
                                        result.deviceId, result.pageIndex);
                                  },
                                  child: Stack(children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 20),
                                        child: cardWidget),
                                    Positioned(
                                      right: 8,
                                      top: 8,
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
                                  ]),
                                );
                                MediaQueryData mediaQuery =
                                    MediaQuery.of(context);
                                double screenWidth = mediaQuery.size.width;
                                double screenHeight = mediaQuery.size.height;
                                double gridWidth = screenWidth / 4;
                                double gridHeight = screenHeight / 4;
                                // 映射拖拽
                                Widget cardWithDrag = LongPressDraggable(
                                  data: result.deviceId,
                                  feedback: cardWidget,
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: Container(
                                      child: AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: _animation.value,
                                            child: cardWithIcon,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  child: cardWithIcon,
                                  onDragStarted: () {
                                    setState(() {
                                      dargingWidgetId = result.deviceId;
                                      curLayout = layoutModel
                                          .getLayoutsByDevice(result.deviceId);
                                      curscreenLayout =
                                          layoutModel.getLayoutsByPageIndex(
                                              result.pageIndex);
                                      dragSumX =
                                          curLayout.grids[0] % 4 - 1 == -1
                                              ? (3 * gridWidth)
                                              : ((curLayout.grids[0] % 4 - 1) *
                                                  gridWidth);
                                      dragSumY =
                                          curLayout.grids[0] / 4 * gridHeight;
                                    });
                                  },
                                  onDragEnd: (details) {
                                    int columnIndex = dragSumX ~/ gridWidth + 1;
                                    int rowIndex = dragSumY ~/ gridHeight;
                                    layoutModel.swapPosition(
                                        curLayout, rowIndex, columnIndex);
                                  },
                                  onDragUpdate: (details) {
                                    // 计算出拖拽中卡片的位置
                                    dragSumX += details.delta.dx;
                                    dragSumY += details.delta.dy;
                                  },
                                  onDragCompleted: () {},
                                  onDraggableCanceled: (_, __) {},
                                );
                                // 映射占位
                                Widget cardWithPosition = StaggeredGridTile.fit(
                                    crossAxisCellCount:
                                        sizeMap[result.cardType]!['cross']!,
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
                                _pageController.animateToPage(maxPage + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease);
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
                                  logger.i('当前映射card', layoutAfterSort.type);
                                  logger.i(
                                      '当前映射card', layoutAfterSort.cardType);
                                  Widget cardWidget =
                                      buildMap[layoutAfterSort.type]![
                                          layoutAfterSort
                                              .cardType]!(layoutAfterSort.data);
                                  // 映射布局占格
                                  Widget cardWithPosition =
                                      StaggeredGridTile.fit(
                                    crossAxisCellCount: sizeMap[
                                        layoutAfterSort.cardType]!['cross']!,
                                    child: UnconstrainedBox(child: cardWidget),
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
                              Log.i('cardInfo', result.type);
                              Log.i('cardInfo', result.cardType);
                              Log.i('cardData', result.data);
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

  List<Widget> getScreenList(double width, double height) {
    // 使用provider
    final layoutModel = Provider.of<LayoutModel>(context);
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
      // 填充
      List<Layout> fillNullLayoutList =
          layoutModel.fillNullLayoutList(curScreenLayouts, page);
      // 排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(fillNullLayoutList);
      // 映射成widget放进去
      for (Layout layout in sortedLayoutList) {
        // 映射出对应的Card
        Widget cardWidget =
            buildMap[layout.type]![layout.cardType]!(layout.data);
        if (layout.type == DeviceEntityTypeInP4.DeviceNull) {
          Widget cardWithPosition = StaggeredGridTile.fit(
            crossAxisCellCount: sizeMap[layout.cardType]!['cross']!,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, top: 20),
              child: cardWidget,
            ),
          );
          curScreenWidgets.add(cardWithPosition);
        } else {
          // 映射图标
          Widget cardWithIcon = GestureDetector(
            onTap: () {
              layoutModel.deleteLayout(layout.deviceId, layout.pageIndex);
            },
            child: Stack(children: [
              Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: cardWidget),
              Positioned(
                right: 8,
                top: 8,
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
            ]),
          );
          // 映射拖拽
          Widget cardWithDrag = LongPressDraggable(
            data: layout.deviceId,
            feedback: cardWidget,
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: Container(
                child: cardWithIcon,
              ),
            ),
            child: cardWithIcon,
            onDragStarted: () {
              setState(() {
                dargingWidgetId = layout.deviceId;
                curLayout = layoutModel.getLayoutsByDevice(layout.deviceId);
                curscreenLayout =
                    layoutModel.getLayoutsByPageIndex(layout.pageIndex);
                dragSumX = curLayout.grids[0] % 4 - 1 == -1
                    ? (3 * gridWidth)
                    : ((curLayout.grids[0] % 4 - 1) * gridWidth);
                dragSumY = curLayout.grids[0] / 4 * gridHeight;
              });
            },
            onDragEnd: (details) {
              int columnIndex = dragSumX ~/ gridWidth + 1;
              int rowIndex = dragSumY ~/ gridHeight;
              layoutModel.swapPosition(curLayout, rowIndex, columnIndex);
            },
            onDragUpdate: (details) {
              // 计算出拖拽中卡片的位置
              dragSumX += details.delta.dx;
              dragSumY += details.delta.dy;
            },
            onDragCompleted: () {},
            onDraggableCanceled: (_, __) {},
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
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            axisDirection: AxisDirection.down,
            children: [...curScreenWidgets],
          ),
        ),
      );
    }
    // 布局结束，抛出屏幕列表
    return screenList;
  }
}
