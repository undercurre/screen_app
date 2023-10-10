import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/widgets/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/logcat_helper.dart';
import '../routes/home/device/layout_data.dart';

class LayoutModel extends ChangeNotifier {
  List<Layout> layouts = [];

  Future<void> setLayouts(List<Layout> newLayouts) async {
    layouts = newLayouts;
    await _saveLayouts();
    notifyListeners();
  }

  // 初始化时从本地读取布局数据
  LayoutModel() {
    loadLayouts();
  }

  Future<void> loadLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutList = prefs.getStringList('layouts');
    if (layoutList != null) {
      try {
        layouts = layoutList.map((json) => Layout.fromJson(json)).toList();
      } catch (e) {
        Log.i('layout缓存加载失败', e);
        removeLayouts();
        await Future.delayed(const Duration(seconds: 2));
        loadLayouts();
      }
    } else {
      // 初次使用,展示默认布局
      setLayouts([
        Layout(
            'clock',
            DeviceEntityTypeInP4.Clock,
            CardType.Other,
            0,
            [1, 2, 5, 6],
            DataInputCard(
                name: '时钟',
                applianceCode: 'clock',
                roomName: '屏内',
                isOnline: '',
                type: 'clock',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'weather',
            DeviceEntityTypeInP4.Weather,
            CardType.Other,
            0,
            [3, 4, 7, 8],
            DataInputCard(
                name: '天气',
                applianceCode: 'weather',
                roomName: '屏内',
                isOnline: '',
                type: 'weather',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel1',
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '灯1',
                applianceCode: 'localPanel1',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel1',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            'localPanel2',
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '灯2',
                applianceCode: 'localPanel2',
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel2',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [13, 14],
            DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: '')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            0,
            [15, 16],
            DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: ''))
      ]);
      _saveLayouts();
    }
    notifyListeners();
  }

  Future<void> _saveLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutList =
        layouts.map((layout) => jsonEncode(layout.toJson())).toList();
    await prefs.setStringList('layouts', layoutList);
  }

  Future<void> removeLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('layouts');
    layouts.clear(); // 清除内存
    notifyListeners();
  }

  // 用于将新的布局对象添加到 layouts 列表中，并通知监听者数据发生了变化。
  void addLayout(Layout layout) {
    if (hasLayoutWithDeviceId(layout.deviceId)) {
      return; // 已存在具有相同 deviceId 的布局对象，不进行更新
    }
    layouts.add(layout);
    _saveLayouts();
    notifyListeners();
  }

  // 方法用于更新现有的布局对象, 根据 deviceId 和 pageIndex 查找到对应的布局，并进行更新。
  void updateLayout(Layout layout) {
    final index = layouts.indexWhere((item) =>
        item.deviceId == layout.deviceId && item.pageIndex == layout.pageIndex);
    if (index != -1) {
      layouts[index] = layout;
      _saveLayouts();
      notifyListeners();
    }
  }

  // 用于根据设备ID获取相关的布局对象列表。
  Layout getLayoutsByDevice(String deviceId) {
    return layouts.firstWhere(
      (item) => item.deviceId == deviceId,
      orElse: () => Layout(
        '-1',
        DeviceEntityTypeInP4.DeviceNull,
        CardType.Null,
        -1,
        [],
        DataInputCard(
            name: '',
            type: '',
            applianceCode: '',
            roomName: '',
            masterId: '',
            modelNumber: '',
            isOnline: '',
            onlineStatus: ''),
      ),
    );
  }

  // 用于根据页面索引获取相关的布局对象列表
  List<Layout> getLayoutsByPageIndex(int pageIndex) {
    return layouts.where((item) => item.pageIndex == pageIndex).toList();
  }

  void handleNullPage(int nullPageIndex) {
    if (layouts.isEmpty) {
      setLayouts([]);
    }

    for (int i = 0; i < layouts.length; i++) {
      if (layouts[i].pageIndex > nullPageIndex) {
        layouts[i].pageIndex--;
      }
    }

    _saveLayouts();
    notifyListeners();
  }

  // 用于删除指定 deviceId 和 pageIndex 的布局对象。
  Future<void> deleteLayout(String deviceId) async {
    // 获取到provider中当前id的Layout数据
    Layout curLayout = getLayoutsByDevice(deviceId);
    // 获取当前布局的pageId
    int curPageIndex = curLayout.pageIndex;
    layouts.removeWhere((item) => item.deviceId == deviceId);
    // 检查该页还有没有非空卡/非待定区/其他卡片
    bool hasNotNullCard = layouts.any((element) =>
        element.cardType != CardType.Null && element.pageIndex == curPageIndex);
    // 如果没有其他卡片也就是说这一页因为这次删除而将变成一个空页
    if (!hasNotNullCard) {
      // 删除所有剩下的该页布局数据（剩下的都是待定区）
      layouts.removeWhere((element) => element.pageIndex == curPageIndex);
      // 把layouts的剩余布局数据的pageIndex重排一下
      handleNullPage(curPageIndex);
    } else {
      // 如果还有其他卡片，对该页布局重新编排并填充待定区（flexLayout将抛回重新编排后这一整页的数据）
      List<Layout> curPageLayoutsAfterFill =
          Layout.flexLayout(getLayoutsByPageIndex(curPageIndex));
      // 删掉这一页所有的数据
      layouts.removeWhere((element) => element.pageIndex == curPageIndex);
      // 重新插入这一页再编排后的数据
      for (int o = 0; o < curPageLayoutsAfterFill.length; o++) {
        addLayout(curPageLayoutsAfterFill[o]);
      }
      await _saveLayouts();
      notifyListeners();
    }
  }

  // 找到布局页数
  int getMaxPageIndex() {
    int maxPageIndex = -1;
    for (var layout in layouts) {
      if (layout.pageIndex > maxPageIndex) {
        maxPageIndex = layout.pageIndex;
      }
    }
    return maxPageIndex;
  }

  // 检查布局是否已经存在
  bool hasLayoutWithDeviceId(String deviceId) {
    return layouts.any((layout) => layout.deviceId == deviceId);
  }

  // 根据 deviceId 获取当前 pageIndex 中剩余的布局对象列表
  List<Layout> getRemainingLayoutsByDeviceAndPageIndex(
      String deviceId, int pageIndex) {
    return layouts
        .where((item) =>
            item.deviceId == deviceId &&
            item.pageIndex == pageIndex &&
            item != getLayoutsByDevice(deviceId))
        .toList();
  }

  // 根据pageIndex判断该页是否已经储存满
  bool isFillPage(int pageIndex) {
    int itemsPerPage = 16;
    List<Layout> layoutsOnPage = layouts
        .where((element) =>
            element.pageIndex == pageIndex && element.cardType != CardType.Null)
        .toList();
    List<int> gridFilledOnPage = [];
    layoutsOnPage.forEach((element) {
      gridFilledOnPage.addAll(element.grids);
    });
    Log.i('$pageIndex页的grids', gridFilledOnPage);
    return gridFilledOnPage.length < itemsPerPage;
  }

  // 根据CardType判断第几页有适合的空位
  LayoutPosition getFlexiblePage(CardType cardType) {
    int maxPage = getMaxPageIndex();
    Log.i('最大页数', maxPage);
    Screen screenLayer = Screen();
    for (int i = 0; i <= maxPage; i++) {
      if (isFillPage(i)) {
        Log.i('有空位', i);
        // 该页有空位

        // 获取该页的layouts
        List<Layout> layoutsInCurPage = layouts
            .where((element) =>
                element.pageIndex == i && element.cardType != CardType.Null)
            .toList();
        for (int j = 0; j < layoutsInCurPage.length; j++) {
          for (int k = 0; k < layoutsInCurPage[j].grids.length; k++) {
            int row = (layoutsInCurPage[j].grids[k] - 1) ~/ 4;
            int col = (layoutsInCurPage[j].grids[k] - 1) % 4;
            screenLayer.setCellOccupied(row, col, true);
          }
        }
        // 尝试填充
        List<int> fillCells = screenLayer.checkAvailability(cardType);
        Log.i('尝试位置$i页$fillCells');
        if (fillCells.isNotEmpty) {
          // 有合适的位置
          Log.i('输出合适的位置$i页$fillCells');
          return LayoutPosition(pageIndex: i, grids: fillCells);
        }
        screenLayer.resetGrid();
      }
    }

    return LayoutPosition(pageIndex: -1, grids: []);
  }

  List<Layout> fillNullLayoutList(List<Layout> layoutList, int pageIndex) {
    // 深复制一份
    List<Layout> cloneList = deepCopy(layoutList);
    if (isFillPage(pageIndex)) {
      // 该页有空位

      Screen screenLayer = Screen();
      for (int j = 0; j < layoutList.length; j++) {
        for (int k = 0; k < layoutList[j].grids.length; k++) {
          int row = (layoutList[j].grids[k] - 1) ~/ 4;
          int col = (layoutList[j].grids[k] - 1) % 4;
          screenLayer.setCellOccupied(row, col, true);
        }
      }
      int filledCount = screenLayer.getOccupiedGridIndices().length;
      // 尝试填充
      for (int n = 0; n <= ((16 - filledCount) / 2); n++) {
        List<int> fillCells = screenLayer.checkAvailability(CardType.Small);
        for (int o = 0; o < fillCells.length; o++) {
          int row = (fillCells[o] - 1) ~/ 4;
          int col = (fillCells[o] - 1) % 4;
          screenLayer.setCellOccupied(row, col, true);
        }
        if (fillCells.isNotEmpty) {
          // 有合适的位置
          cloneList.add(
            Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceNull,
              CardType.Small,
              pageIndex,
              fillCells,
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
        }
      }
      screenLayer.resetGrid();
    }
    return cloneList;
  }

  // 拖拽换位算法
  void swapPosition(
      String sourceId, String targetId, int pageIndex, bool isLeft) {
    // 取到当前页的卡片
    List<Layout> curPageLayout = getLayoutsByPageIndex(pageIndex);
    // 排序
    List<Layout> sortedLayout = Layout.sortLayoutList(curPageLayout);
    // 找到被拖拽的下标
    int sourceIndex =
        sortedLayout.indexWhere((element) => element.deviceId == sourceId);
    if (sourceIndex == -1) return;
    Layout source = sortedLayout.removeAt(sourceIndex);
    // 找到target下标
    int targetIndex =
        sortedLayout.indexWhere((element) => element.deviceId == targetId);
    if (targetIndex == -1) return;
    if (isLeft) {
      sortedLayout.insert(targetIndex, source);
    } else {
      sortedLayout.insert(targetIndex + 1, source);
    }
    // 已经进行新排序
    // 取到现在的卡片类型顺序
    List<CardType> cardTypeSort = sortedLayout.map((e) => e.cardType).toList();
    // 占位
    Screen screenLayer = Screen();
    for (int k = 0; k < cardTypeSort.length; k++) {
      List<int> fillCells = screenLayer.checkAvailability(cardTypeSort[k]);
      for (int gridsIndex = 0; gridsIndex < fillCells.length; gridsIndex++) {
        // 把已经布局的数据在布局器中占位
        int grid = fillCells[gridsIndex];
        int row = (grid - 1) ~/ 4;
        int col = (grid - 1) % 4;
        screenLayer.setCellOccupied(row, col, true);
      }
      sortedLayout[k].grids = fillCells;
    }

    Log.i('排序$sourceIndex到$targetIndex后', layouts.map((e) => e.grids).toList());

    _saveLayouts();
    notifyListeners();
  }

  // 卡片大小替换
  Future<void> swapCardType(Layout layout, CardType targetType) async {
    if (layout.cardType == targetType) {
      return;
    }
    layout.cardType = targetType;
    // 更换grid
    // 准备screenLayer
    Screen screenLayer = Screen();
    // 拿到当前页的布局, 并做好新占位前的screenLayer占位
    List<Layout> curLayouts = getLayoutsByPageIndex(layout.pageIndex);
    if (curLayouts.isNotEmpty) {
      for (int layoutInCurPageIndex = 0;
          layoutInCurPageIndex < curLayouts.length;
          layoutInCurPageIndex++) {
        if (curLayouts[layoutInCurPageIndex].deviceId != layout.deviceId &&
            curLayouts[layoutInCurPageIndex].cardType != CardType.Null) {
          // 取出当前布局的grids
          for (int gridsIndex = 0;
              gridsIndex < curLayouts[layoutInCurPageIndex].grids.length;
              gridsIndex++) {
            // 把已经布局的数据在布局器中占位
            int grid = curLayouts[layoutInCurPageIndex].grids[gridsIndex];
            int row = (grid - 1) ~/ 4;
            int col = (grid - 1) % 4;
            screenLayer.setCellOccupied(row, col, true);
          }
        }
      }
    }
    // 尝试新占位
    List<int> fillCells = screenLayer.checkAvailability(targetType);
    if (fillCells.isNotEmpty) {
      // 新占位成功
      layout.grids = fillCells;
      // 回补空缺
      List<Layout> curPageLayoutsAfterUpt =
          getLayoutsByPageIndex(layout.pageIndex);
      Log.i('更新后的占位', curPageLayoutsAfterUpt.map((e) => e.grids));
      List<Layout> curPageLayouts = Layout.flexLayout(curPageLayoutsAfterUpt);
      curLayouts.forEach((element) async {
        if (element.cardType == CardType.Null) {
          await deleteLayout(element.deviceId);
        }
      });
      for (int k = 0; k < curPageLayouts.length; k++) {
        if (curPageLayouts[k].cardType == CardType.Null) {
          layouts.add(Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceNull,
              CardType.Null,
              layout.pageIndex,
              curPageLayouts[k].grids,
              DataInputCard(
                  name: '',
                  type: '',
                  applianceCode: '',
                  roomName: '',
                  masterId: '',
                  modelNumber: '',
                  isOnline: '',
                  onlineStatus: '')));
        }
      }
    } else {
      // 新占位失败，转到最后一页
      screenLayer.resetGrid();
      // 取最大页数
      int maxPage = getMaxPageIndex();
      // 最大页数重复
      List<Layout> maxLayouts = getLayoutsByPageIndex(maxPage);
      if (maxLayouts.isNotEmpty) {
        for (int layoutInMaxPageIndex = 0;
            layoutInMaxPageIndex < maxLayouts.length;
            layoutInMaxPageIndex++) {
          if (maxLayouts[layoutInMaxPageIndex].deviceId != layout.deviceId &&
              maxLayouts[layoutInMaxPageIndex].cardType != CardType.Null) {
            // 取出当前布局的grids
            for (int gridsIndexInMaxPage = 0;
                gridsIndexInMaxPage <
                    curLayouts[layoutInMaxPageIndex].grids.length;
                gridsIndexInMaxPage++) {
              // 把已经布局的数据在布局器中占位
              int grid =
                  maxLayouts[layoutInMaxPageIndex].grids[gridsIndexInMaxPage];
              int row = (grid - 1) ~/ 4;
              int col = (grid - 1) % 4;
              screenLayer.setCellOccupied(row, col, true);
            }
          }
        }
      }
      List<int> fillCellsInMaxPage = screenLayer.checkAvailability(targetType);
      if (fillCellsInMaxPage.isNotEmpty) {
        // 新占位成功
        // 回补空缺
        List<Layout> curLayoutsAfterDel =
            getLayoutsByPageIndex(layout.pageIndex)
                .where((element) => element.deviceId != layout.deviceId)
                .toList();
        List<Layout> backFilled = Layout.flexLayout(curLayoutsAfterDel);
        curLayoutsAfterDel.forEach((element) async {
          if (element.cardType == CardType.Null) {
            await deleteLayout(element.deviceId);
          }
        });
        for (int k = 0; k < backFilled.length; k++) {
          if (backFilled[k].cardType == CardType.Null) {
            layouts.add(Layout(
                uuid.v4(),
                DeviceEntityTypeInP4.DeviceNull,
                CardType.Null,
                layout.pageIndex,
                backFilled[k].grids,
                DataInputCard(
                    name: '',
                    type: '',
                    applianceCode: '',
                    roomName: '',
                    masterId: '',
                    modelNumber: '',
                    isOnline: '',
                    onlineStatus: '')));
          }
        }
        layout.pageIndex = maxPage;
        layout.grids = fillCellsInMaxPage;
        List<Layout> maxPageLayoutAfterAdd =
            getLayoutsByPageIndex(layout.pageIndex);
        List<Layout> backAdded = Layout.flexLayout(maxPageLayoutAfterAdd);
        maxPageLayoutAfterAdd.forEach((element) async {
          if (element.cardType == CardType.Null) {
            await deleteLayout(element.deviceId);
          }
        });
        for (int k = 0; k < backAdded.length; k++) {
          if (backAdded[k].cardType == CardType.Null) {
            addLayout(Layout(
                uuid.v4(),
                DeviceEntityTypeInP4.DeviceNull,
                CardType.Null,
                maxPage + 1,
                backAdded[k].grids,
                DataInputCard(
                    name: '',
                    type: '',
                    applianceCode: '',
                    roomName: '',
                    masterId: '',
                    modelNumber: '',
                    isOnline: '',
                    onlineStatus: '')));
          }
        }
      } else {
        // 最后一页也没有空间了，开一页新的
        screenLayer.resetGrid();
        await deleteLayout(layout.deviceId);
        // 回补空缺
        List<Layout> curLayoutsAfterDel =
            getLayoutsByPageIndex(layout.pageIndex);
        List<Layout> backFilled = Layout.flexLayout(curLayoutsAfterDel);
        curLayoutsAfterDel.forEach((element) async {
          if (element.cardType == CardType.Null) {
            await deleteLayout(element.deviceId);
          }
        });
        for (int k = 0; k < backFilled.length; k++) {
          if (backFilled[k].cardType == CardType.Null) {
            layouts.add(
              Layout(
                uuid.v4(),
                DeviceEntityTypeInP4.DeviceNull,
                CardType.Null,
                layout.pageIndex,
                backFilled[k].grids,
                DataInputCard(
                  name: '',
                  type: '',
                  applianceCode: '',
                  roomName: '',
                  masterId: '',
                  modelNumber: '',
                  isOnline: '',
                  onlineStatus: '',
                ),
              ),
            );
          }
        }
        // 新增目标
        List<int> fillCellsNew = screenLayer.checkAvailability(targetType);
        Layout newLayout = Layout(layout.deviceId, layout.type, targetType,
            maxPage + 1, fillCellsNew, layout.data);
        addLayout(newLayout);
        List<Layout> backAdded = Layout.filledLayout([newLayout]);
        for (int k = 0; k < backAdded.length; k++) {
          if (backAdded[k].cardType == CardType.Null) {
            addLayout(Layout(
                uuid.v4(),
                DeviceEntityTypeInP4.DeviceNull,
                CardType.Null,
                maxPage + 1,
                backAdded[k].grids,
                DataInputCard(
                    name: '',
                    type: '',
                    applianceCode: '',
                    roomName: '',
                    masterId: '',
                    modelNumber: '',
                    isOnline: '',
                    onlineStatus: '')));
          }
        }
      }
    }
    _saveLayouts();
    notifyListeners();
  }

  void removeNullCardByPage(int pageIndex) async {
    layouts.removeWhere((element) =>
        element.cardType == CardType.Null && element.pageIndex == pageIndex);
  }

  static removeLayoutStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('layouts');
  }
}

class LayoutPosition {
  int pageIndex;
  List<int> grids;

  LayoutPosition({
    required this.pageIndex,
    required this.grids,
  });
}

List<Layout> deepCopy(List<Layout> original) {
  List<Layout> copy = [];
  for (var element in original) {
    copy.add(element);
  }
  return copy;
}

bool listsEqual(List<int> list1, List<int> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (var i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}

bool isTargetInValidList(List<List<int>> valid, List<int> target) {
  for (var list in valid) {
    if (listsEqual(list, target)) {
      return true;
    }
  }
  return false;
}

bool isOver(CardType cardType, List<int> target) {
  if (cardType == CardType.Small) {
    List<List<int>> valid = [
      [1, 2],
      [3, 4],
      [5, 6],
      [7, 8],
      [9, 10],
      [11, 12],
      [13, 14],
      [15, 16]
    ];
    if (!isTargetInValidList(valid, target)) {
      return true;
    }
  }

  if (cardType == CardType.Middle || cardType == CardType.Other) {
    List<List<int>> valid = [
      [1, 2, 5, 6],
      [3, 4, 7, 8],
      [5, 6, 9, 10],
      [7, 8, 11, 12],
      [9, 10, 13, 14],
      [11, 12, 15, 16]
    ];
    if (!isTargetInValidList(valid, target)) {
      return true;
    }
  }

  if (cardType == CardType.Big) {
    List<List<int>> valid = [
      [1, 2, 3, 4, 5, 6, 7, 8],
      [5, 6, 7, 8, 9, 10, 11, 12],
      [9, 10, 11, 12, 13, 14, 15, 16]
    ];
    if (!isTargetInValidList(valid, target)) {
      return true;
    }
  }

  return false;
}
