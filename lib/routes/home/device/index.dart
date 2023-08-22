import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/card/edit.dart';

import '../../../common/api/api.dart';
import '../../../common/global.dart';
import '../../../common/logcat_helper.dart';
import '../../../states/layout_notifier.dart';
import 'card_type_config.dart';
import 'grid_container.dart';
import 'layout_data.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final PageController _pageController = PageController();
  List<Widget> _screens = [];

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
    // 处理布局信息
    final layoutModel = Provider.of<LayoutModel>(context);
    if (mounted) {
      _screens = getScreenList(layoutModel);
    }
    // logger.i('屏幕页面数量', _screens.length);
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index) {},
      children: _screens,
    );
  }

  List<Widget> getScreenList(LayoutModel layoutModel) {
    // 屏幕页面列表
    List<Widget> screenList = [];
    // 当前页面的widgets
    List<Widget> curScreenWidgetList = [];
    // 当前要布局的页面
    int pageCount = 0;
    // 已经被排布的页面数量
    int hadPageCount = layoutModel.getMaxPageIndex();
    // 初始化布局占位器
    Screen screenLayer = Screen();

    if (layoutModel.layouts.isEmpty) {
      screenList.add(const Center(child: EditCardWidget()));
      return screenList;
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
        if (editCardFillCells.isNotEmpty && editCardFillCells[0] > sumGrid.reduce(max)) {
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
              ),
            ),
          );
        } else {
          isCanAdd = false;
        }
      }
      // 填充
      List<Layout> fillNullLayoutList =
          layoutModel.fillNullLayoutList(curScreenLayouts, pageCount);
      // 映射排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(fillNullLayoutList);
      // 根据队列顺序插入该屏页面
      for (Layout layoutAfterSort in sortedLayoutList) {
        // 映射出对应的Card
        layoutAfterSort.data.disabled = false;
        Widget cardWidget =
            buildMap[layoutAfterSort.type]![layoutAfterSort.cardType]!(
                layoutAfterSort.data);
        // 映射布局占格
        Widget cardWithPosition = StaggeredGridTile.fit(
            crossAxisCellCount: sizeMap[layoutAfterSort.cardType]!['cross']!,
            child: UnconstrainedBox(child: cardWidget));
        // 扔进页面里
        curScreenWidgetList.add(cardWithPosition);
      }
      // ************单页构造

      // ************插入pageview
      screenList.add(
        UnconstrainedBox(
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
                children: [...curScreenWidgetList],
              ),
            ),
          ),
        ),
      );
      // ************插入pageview

      if (!isCanAdd) {
        screenList.add(const Center(child: EditCardWidget()));
      }

      // 每一页处理前重置布局器
      screenLayer.resetGrid();
      // 每一页处理前情况当前页Widget存储器
      curScreenWidgetList = [];
    }
    return screenList;
  }
}
