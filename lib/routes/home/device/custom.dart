import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../common/global.dart';
import '../../../states/device_position_notifier.dart';
import '../../../widgets/card/main/big_device_light.dart';
import '../../../widgets/card/main/middle_device.dart';
import '../../../widgets/card/main/small_device.dart';
import '../../../widgets/mz_buttion.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  final PageController _pageController = PageController();
  List<Widget> _screens = [];
  late Layout curLayout;
  String dargingWidgetId = '';
  List<Layout> curscreenLayout = [];
  double dragSumX = 0;
  double dragSumY = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      // 排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(curScreenLayouts);
      // 映射成widget放进去
      for (Layout layout in sortedLayoutList) {
        // 映射出对应的Card
        Widget cardWidget =
            buildMap[layout.cardType]![layout.type]!(layout.data);
        logger.i('映射出的widget', cardWidget);
        // 映射图标
        Widget cardWithIcon = Stack(children: [
          cardWidget,
          Positioned(
            right: 0,
            top: 0,
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
          )
        ]);
        // 映射拖拽
        Widget cardWithDrag = LongPressDraggable(
          data: layout.deviceId,
          feedback: cardWidget,
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Container(
              margin: const EdgeInsets.only(top: 20, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ),
          child: cardWithIcon,
          onDragStarted: () {
            setState(() {
              dargingWidgetId = layout.deviceId;
              curLayout = layoutModel.getLayoutsByDevice(layout.deviceId);
              curscreenLayout =
                  layoutModel.getLayoutsByPageIndex(layout.pageIndex);
              dragSumX = curLayout.grids[0] % 4 - 1 == -1 ? (3 * gridWidth) : ((curLayout.grids[0] % 4 - 1) * gridWidth);
              dragSumY = curLayout.grids[0] / 4 * gridHeight;
            });
          },
          onDragEnd: (details) {
          },
          onDragUpdate: (details) {
            // 计算出拖拽中卡片的位置
            dragSumX += details.delta.dx;
            dragSumY += details.delta.dy;
            int columnIndex = dragSumX ~/ gridWidth;
            int rowIndex = dragSumY ~/ gridHeight;
            logger.i('拖拽到$rowIndex行$columnIndex列');
            double offsetX = columnIndex * gridWidth;
            double offsetY = rowIndex * gridHeight;
            double draggableWidth =
                sizeMap[curLayout.cardType]!['cross']! / 2 * 210 / 440 * width;
            double draggableHeight =
                sizeMap[curLayout.cardType]!['main']! * 88 / 392 * height;
            // 边界检查
            double maxOffsetX = width - draggableWidth;
            double maxOffsetY = height - draggableHeight;
            double validOffsetX = min(max(offsetX, 0), maxOffsetX);
            double validOffsetY = min(max(offsetY, 0), maxOffsetY);
            // 加入padding
            validOffsetX += 20;
            validOffsetY += (rowIndex == 0 ? 32 : 10);
          },
          onDragCompleted: () {},
          onDraggableCanceled: (_, __) {},
        );
        // 映射占位
        Widget cardWithPosition = StaggeredGridTile.count(
            crossAxisCellCount: sizeMap[layout.cardType]!['cross']!,
            mainAxisCellCount: sizeMap[layout.cardType]!['main']!,
            child: cardWithDrag);
        curScreenWidgets.add(cardWithPosition);
      }
      // 每一页插入屏幕表
      screenList.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
          child: StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
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
