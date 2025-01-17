import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_dialog_scene.dart';
import 'package:screen_app/states/page_change_notifier.dart';
import 'package:screen_app/widgets/keep_alive_wrapper.dart';

import '../../../channel/index.dart';
import '../../../common/adapter/select_room_data_adapter.dart';
import '../../../common/gateway_platform.dart';
import '../../../common/global.dart';
import '../../../common/homlux/models/homlux_room_list_entity.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/models/meiju_room_entity.dart';
import '../../../common/system.dart';
import '../../../common/utils.dart';
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
  // pageview的Controller
  PageController _pageController = PageController();

  // 存储pageview的页面
  List<Widget> _screens = [];

  // 当前拖拽的卡片id
  String dragingWidgetId = '';

  // 正在运行的标记
  bool loadingMark = false;

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
    final pageCounterModel = Provider.of<PageCounter>(context);

    // 滑动控制重置，实现进入自定义就是在首页的最后位置
    _pageController = PageController(initialPage: pageCounterModel.currentPage);

    // 处理布局信息
    if (mounted) {
      getScreenList(layoutModel, pageCounterModel);
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
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          height: MediaQuery.of(context).size.height,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              pageCounterModel.currentPage = index;
            },
            itemCount: _screens.length,
            itemBuilder: (BuildContext context, int index) {
              return KeepAliveWrapper(child: _screens[index]);
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
                        backgroundColor:
                            layoutModel.layouts.length >= 16 ? const Color(0xFF818C98).withOpacity(0.6) : const Color(0xFF818C98),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        text: '添加(${layoutModel.layouts.where((element) => element.cardType != CardType.Null).toList().length})',
                        textColor: layoutModel.layouts.where((element) => element.cardType != CardType.Null).toList().length >= 10000
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                        onPressed: () async {
                          addDevice(layoutModel, pageCounterModel);
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
                          // Log.i('现有布局', layoutModel.layouts.map((e) => '${e.deviceId}${e.cardType}${e.type}'));
                          // layoutModel.removeLayouts();
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

  void getScreenList(LayoutModel layoutModel, PageCounter pageCounterModel) {
    // 每次渲染需要重新把存储器情况
    _screens = [];
    // 取得最大页数
    int maxPage = layoutModel.getMaxPageIndex();
    // 逐页渲染
    for (int page = 0; page <= maxPage; page++) {
      // 收集当前page的widget
      List<Widget> curScreenWidgets = [];
      // 拿到当前页的layout
      List<Layout> curScreenLayouts = layoutModel.getLayoutsByPageIndex(page);
      // 逃避空页
      if (curScreenLayouts.isEmpty) continue;
      // 排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(curScreenLayouts);
      // 映射成widget放进去
      for (Layout layout in sortedLayoutList) {
        layout.data.disabled = true;
        layout.data.disableOnOff = false;
        layout.data.context = context;
        layout.data.applianceCode = layout.deviceId;
        // 映射出对应的Card
        if (buildMap[layout.type]?[layout.cardType] == null) {
          Log.e("异常布局类型 ${layout.type} ${layout.cardType} ");
          continue;
        }
        Widget cardWidget = buildMap[layout.type]![layout.cardType]!(layout.data);

        // 映射点击（用于置换）
        Widget cardWithSwap = layout.cardType != CardType.Null
            ? GestureDetector(
                onTap: () {
                  layout.type != DeviceEntityTypeInP4.Scene
                      ? _getDeviceDialog(context, layout, pageCounterModel)
                      : _getSceneDialog(context, layout, pageCounterModel);
                },
                child: AbsorbPointer(absorbing: true, child: cardWidget),
              )
            : cardWidget;
        // 映射图标(删除)
        Widget cardWithIcon = Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 20),
              child: cardWithSwap,
            ),
            if (layout.cardType != CardType.Null)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () async {
                    if (loadingMark) {
                      TipsUtils.toast(content: "正在执行上一个删除操作", duration: 1000);
                      return;
                    }
                    loadingMark = true;
                    await layoutModel.deleteAndFlexLayout(layout.deviceId);
                    loadingMark = false;
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
        Widget cardWithDrag = layout.cardType != CardType.Null
            ? LongPressDraggable<String>(
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
                  });
                },
                onDragEnd: (detail) {
                  setState(() {
                    dragingWidgetId = '';
                  });
                },
                onDraggableCanceled: (_, __) {
                  setState(() {
                    dragingWidgetId = '';
                  });
                },
                child: Stack(
                  children: [
                    Opacity(
                      opacity: layout.deviceId == dragingWidgetId ? 0.5 : 1,
                      child: cardWithIcon,
                    ),
                    if (dragingWidgetId.isNotEmpty)
                      Positioned(
                        top: 20,
                        left: 0,
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                                width: sizeMap[layout.cardType]!['cross']! / 2 * 105,
                                height: sizeMap[layout.cardType]!['main']! * 96,
                                color: Colors.transparent);
                          },
                          onAccept: (data) {
                            Log.i('$data拖拽结束左', layout.deviceId);
                            // 被拖拽的
                            layoutModel.swapPosition(data, layout.deviceId, layout.pageIndex, true);
                          },
                        ),
                      ),
                    if (dragingWidgetId.isNotEmpty)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                                width: sizeMap[layout.cardType]!['cross']! / 2 * 105,
                                height: sizeMap[layout.cardType]!['main']! * 96,
                                color: Colors.transparent);
                          },
                          onAccept: (data) {
                            Log.i('$data拖拽结束右', layout.deviceId);
                            // 被拖拽的
                            layoutModel.swapPosition(data, layout.deviceId, layout.pageIndex, false);
                          },
                        ),
                      ),
                  ],
                ),
              )
            : cardWithIcon;
        // 映射占位
        Widget cardWithPosition = StaggeredGridTile.fit(crossAxisCellCount: sizeMap[layout.cardType]!['cross']!, child: cardWithDrag);
        curScreenWidgets.add(cardWithPosition);
      }
      // 每一页插入屏幕表
      _screens.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 0, 34),
          child: SingleChildScrollView(
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              axisDirection: AxisDirection.down,
              children: curScreenWidgets,
            ),
          ),
        ),
      );
    }
  }

  Future<void> addDevice(LayoutModel layoutModel, PageCounter pageCounterModel) async {
    // 卡片渲染数量限制
    if (layoutModel.layouts.where((element) => element.cardType != CardType.Null).toList().length < 10000) {
      // 获取选择设备页返回的数据
      final result = await Navigator.pushNamed(context, 'AddDevice');
      if (result != null) {
        // 处理回调的增加信息
        result as Layout;
        result.data.disabled = true;
        result.data.context = context;
        result.data.disableOnOff = false;
        result.data.applianceCode = result.deviceId;
        // 尝试增加到当前页

        // 初始化布局占位器
        Screen screenLayer = Screen();
        // 拿到当前页的layout
        List<Layout> layoutsInCurPage = layoutModel.getLayoutsByPageIndex(pageCounterModel.currentPage);
        if (layoutsInCurPage.isNotEmpty) {
          // 非空页
          for (int layoutInCurPageIndex = 0; layoutInCurPageIndex < layoutsInCurPage.length; layoutInCurPageIndex++) {
            // 不填充待定区占位
            if (layoutsInCurPage[layoutInCurPageIndex].cardType == CardType.Null) continue;
            // 取出当前布局的grids
            for (int gridsIndex = 0; gridsIndex < layoutsInCurPage[layoutInCurPageIndex].grids.length; gridsIndex++) {
              // 把已经布局的有效数据在布局器中占位
              int grid = layoutsInCurPage[layoutInCurPageIndex].grids[gridsIndex];
              int row = (grid - 1) ~/ 4;
              int col = (grid - 1) % 4;
              screenLayer.setCellOccupied(row, col, true);
            }
          }
          // 尝试占位
          List<int> fillCells = screenLayer.checkAvailability(result.cardType);
          // 占位不成功->当前页没有适合位置/当前页已满
          if (fillCells.isEmpty) {
            int maxPage = layoutModel.getMaxPageIndex();
            // 找到现有所有页面中有合适空位的一页
            LayoutPosition proFlexiblePage = layoutModel.getFlexiblePage(result.cardType);
            if (proFlexiblePage.pageIndex > -1) {
              result.pageIndex = proFlexiblePage.pageIndex;
              result.grids = proFlexiblePage.grids;
              // 找到并删掉空缺
              List<Layout> daiding = layoutModel.layouts
                  .where((element) =>
                      element.pageIndex == result.pageIndex &&
                      element.cardType == CardType.Null &&
                      result.grids.any((res) => element.grids.contains(res)))
                  .toList();
              layoutModel.deleteLayoutList(daiding.map((e) => e.deviceId).toList());
              layoutModel.addLayout(result);
              Log.i('此时合适一页页码为${proFlexiblePage.pageIndex}');
              // 跳到这个找到合适位置的页数
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                _pageController.animateToPage(proFlexiblePage.pageIndex, duration: const Duration(milliseconds: 300), curve: Curves.ease);
              });
              pageCounterModel.currentPage = proFlexiblePage.pageIndex;
            } else {
              // 找不到合适的一页就放到新增的最后一页
              // 清空布局器
              screenLayer.resetGrid();
              // 占位
              List<int> fillCells = screenLayer.checkAvailability(result.cardType);
              result.pageIndex = maxPage + 1;
              result.grids = fillCells;
              // 填充待定区
              List<Layout> curPageLayoutsInLast = Layout.filledLayout([result]);
              for (int o = 0; o < curPageLayoutsInLast.length; o++) {
                layoutModel.addLayout(curPageLayoutsInLast[o]);
              }
              Log.i('此时最后一页页码为${maxPage + 1}');
              // 跳到新增的最后一页
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                _pageController.animateToPage(maxPage + 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
              });
              pageCounterModel.currentPage = maxPage + 1;
            }
          } else {
            // 该页有合适的位置
            result.grids = fillCells;
            result.pageIndex = pageCounterModel.currentPage;
            // 找到响应的待定区
            List<Layout> hasThisNullCardList = layoutsInCurPage
                .where((element) => element.grids.every((element) => fillCells.contains(element)) && element.cardType == CardType.Null)
                .toList();
            if (hasThisNullCardList.isNotEmpty) {
              layoutModel.deleteLayoutList(hasThisNullCardList.map((e) => e.deviceId).toList());
              layoutModel.addLayout(result);
            }
          }
        } else {
          // 空页直接插入
          result.pageIndex = pageCounterModel.currentPage;
          // 占位
          List<int> fillCells = screenLayer.checkAvailability(result.cardType);
          result.grids = fillCells;
          // 填充待定区
          List<Layout> curPageLayoutsInNullPage = Layout.filledLayout([result]);
          for (int o = 0; o < curPageLayoutsInNullPage.length; o++) {
            layoutModel.addLayout(curPageLayoutsInNullPage[o]);
          }
        }
      }
    }
  }

  _getDeviceDialog(BuildContext context, Layout layout, PageCounter pageCounterModel) {
    Map<CardType, int> initPageNumMap = {
      CardType.Small: 0,
      CardType.Middle: 1,
      CardType.Big: 2,
    };

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
          sn8: layout.data.sn8,
          initPageNum: initPageNumMap[layout.cardType],
        );
      },
    ).then(
      (value) async {
        if (value != null) {
          int zhuandaoPage = await context.read<LayoutModel>().swapCardType(layout, value);
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _pageController.animateToPage(zhuandaoPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
          });
          pageCounterModel.currentPage = zhuandaoPage;
        }
      },
    );
  }

  _getSceneDialog(BuildContext context, Layout layout, PageCounter pageCounterModel) {
    Map<CardType, int> initPageNumMap = {
      CardType.Small: 0,
      CardType.Middle: 1,
      CardType.Big: 2,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CardDialogScene(
          name: layout.data.name,
          sceneId: layout.data.sceneId ?? '0000',
          icon: layout.data.icon,
          initPageNum: initPageNumMap[layout.cardType],
        );
      },
    ).then(
      (value) async {
        if (value != null) {
          int zhuandaoPage = await context.read<LayoutModel>().swapCardType(layout, value);
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _pageController.animateToPage(zhuandaoPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
          });
          pageCounterModel.currentPage = zhuandaoPage;
        }
      },
    );
  }
}
