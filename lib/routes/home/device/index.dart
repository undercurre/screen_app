import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/card/edit.dart';

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
    _screens = getScreenList(layoutModel.layouts);
    logger.i('屏幕页面数量', _screens.length);
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      onPageChanged: (index) {},
      children: _screens,
    );
  }

  List<Widget> getScreenList(List<Layout> layout) {
    // 使用provider
    final layoutModel = Provider.of<LayoutModel>(context);
    logger.i('布局数量', layoutModel.layouts.length);
    // 屏幕页面列表
    List<Widget> screenList = [];
    // 当前页面的widgets
    List<Widget> curScreenWidgetList = [];
    // 当前要布局的页面
    int pageCount = 0;
    // 已经被排布的页面数量
    int hadPageCount = layoutModel.getMaxPageIndex();
    // 没有被排进过页面的元素
    List<Layout> hadNotInList = [];
    // 排进过页面的元素
    List<Layout> hadInList = [];
    // 用于存储已经被完成占位的未排位数据，每一页处理前要重置为空
    List<Layout> completeList = [];
    // 初始化布局占位器
    Screen screenLayer = Screen();

    if (layoutModel.layouts.isEmpty) {
      screenList.add(const Center(child: EditCardWidget()));
      return screenList;
    }

    // 准备元素队列
    for (var element in layout) {
      // 先把拿到的布局数据分成已布局好的和没布局好的，没布局好的pageIndex是-1
      if (element.pageIndex == -1) {
        hadNotInList.add(element);
      } else {
        if (hadPageCount < element.pageIndex) hadPageCount = element.pageIndex;
        hadInList.add(element);
      }
    }
    logger.i('有多少未布局数据', hadNotInList.length);
    // 虚拟布局计算: 占位——>映射单页——>插入pageview
    // 先处理到现有最大页码
    logger.i('要处理$hadPageCount页');
    for (; pageCount <= hadPageCount; pageCount++) {
      logger.i('当前处理页码', pageCount);
      // 先排除掉已经被排布的格子

      // ************布局
      // 先获取当前页的布局
      List<Layout> layoutsInCurPage =
          layoutModel.getLayoutsByPageIndex(pageCount);
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
        // 查询是否已经用持久化的数据就填满了这一页
        List<int> arrHasPosition = screenLayer.getOccupiedGridIndices();
        if (arrHasPosition.length == 16) {
          logger.i('屏幕被占满');
        } else {
          // 屏幕没占满，开始尝试使用hadNotInList（未排位元素队列中的元素）进行占位)
          for (var hadNotElement in hadNotInList) {
            // 尝试占位
            List<int> fillCells =
                screenLayer.checkAvailability(hadNotElement.cardType);
            // 分析占位结果
            if (fillCells.isNotEmpty) {
              // 占位成功
              // 重置该布局数据
              // 把当前页码放进去
              hadNotElement.pageIndex = pageCount;
              // 把网格布局放进去
              hadNotElement.grids = fillCells;
              // 更新持久化
              layoutModel.updateLayout(hadNotElement);
              // 存入完成布局数组
              completeList.add(hadNotElement);
            } else {
              // 占位失败
              // 查询占位是否填满屏幕
              List<int> arrHasPosition = screenLayer.getOccupiedGridIndices();
              if (arrHasPosition.length == 16) {
                logger.i('屏幕被占满');
                // 退出占位尝试循环
                break;
              } else {
                // 屏幕没占满，该元素不符合剩余的空间
              }
            }
          }
        }
      }
      // ************布局

      // ************单页构造
      // 映射排序
      List<Layout> sortedLayoutList =
          Layout.sortLayoutList(layoutModel.getLayoutsByPageIndex(pageCount));
      // 根据队列顺序插入该屏页面
      for (Layout layoutAfterSort in sortedLayoutList) {
        // 映射出对应的Card
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

      // 删除hadNotInList中已经完成的布局数据
      hadNotInList.removeWhere((element) => completeList.contains(element));

      // 最后一页且没有剩余元素时尝试添加editCard
      bool isCanAdd = true;
      if (pageCount == hadPageCount && hadNotInList.isEmpty) {
        List<int> editCardFillCells =
            screenLayer.checkAvailability(CardType.Edit);
        // 当占位成功
        if (editCardFillCells.isNotEmpty) {
          Widget editCardWithPosition = const StaggeredGridTile.count(
              crossAxisCellCount: 4,
              mainAxisCellCount: 1,
              child: EditCardWidget());
          curScreenWidgetList.add(editCardWithPosition);
        } else {
          isCanAdd = false;
        }
      }

      // ************插入pageview
      screenList.add(
        UnconstrainedBox(
          child: Container(
            width: 480,
            height: 480,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              axisDirection: AxisDirection.down,
              children: [...curScreenWidgetList],
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
      // 用于存储已经被完成占位的未排位数据，每一页处理前要重置为空
      completeList = [];
    }
    // 把剩余的未排元素生成新页面
    while (hadNotInList.isNotEmpty) {
      for (var hadNotElement in hadNotInList) {
        // 尝试占位
        List<int> fillCells =
            screenLayer.checkAvailability(hadNotElement.cardType);
        // 当占位成功
        if (fillCells.isNotEmpty) {
          // 加入完成列表，待剔除时使用
          completeList.add(hadNotElement);
          // 在布局器中设置相应的占位
          for (var item in fillCells) {
            Map<String, int> mark = screenLayer.getGridCoordinates(item);
            screenLayer.setCellOccupied(mark['row']!, mark['col']!, true);
          }
          // 把当前页码放进去
          hadNotElement.pageIndex = pageCount;
          // 把网格布局放进去
          hadNotElement.grids = fillCells;
          // 把更新好的布局加入provider
          layoutModel.addLayout(hadNotElement);
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
      // 根据占位排好队列
      List<Layout> sortedLayoutList =
          Layout.sortLayoutList(layoutModel.getLayoutsByPageIndex(pageCount));
      // 根据队列顺序插入该屏页面
      for (Layout layoutAfterSort in sortedLayoutList) {
        // 映射出对应的Card
        Widget cardWidget =
            buildMap[layoutAfterSort.type]![layoutAfterSort.cardType]!(
                layoutAfterSort.data);
        Widget cardWithPosition = StaggeredGridTile.fit(
            crossAxisCellCount: sizeMap[layoutAfterSort.cardType]!['cross']!,
            child: UnconstrainedBox(child: cardWidget));
        // 扔进页面里
        curScreenWidgetList.add(cardWithPosition);
      }
      hadNotInList.removeWhere((element) => completeList.contains(element));
      // 该屏完成插入pageview队列
      if (completeList.isNotEmpty) {
        // 变量——editCard是否能成功加入当前屏幕
        bool isCanAdd = true;
        if (hadNotInList.isEmpty) {
          // 元素被排布完毕，检验当前屏幕是否能够插入editCard
          List<int> editCardFillCells =
              screenLayer.checkAvailability(CardType.Edit);
          // 当占位成功
          if (editCardFillCells.isNotEmpty) {
            Widget editCardWithPosition = const StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 4,
                child: EditCardWidget());
            curScreenWidgetList.add(editCardWithPosition);
          } else {
            isCanAdd = false;
          }
        }
        // 生成页面Widget插入渲染流程
        screenList.add(
          UnconstrainedBox(
            child: Container(
              width: 480,
              height: 480,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                axisDirection: AxisDirection.down,
                children: [...curScreenWidgetList],
              ),
            ),
          ),
        );
        if (!isCanAdd) {
          screenList.add(const Center(child: EditCardWidget()));
        }
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
