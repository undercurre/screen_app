import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:screen_app/widgets/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/logcat_helper.dart';
import '../routes/home/device/layout_data.dart';

class LayoutModel extends ChangeNotifier {
  List<Layout> layouts = [];
  int go2Refresh = 0;

  void refresh() {
    go2Refresh++;
    notifyListeners();
  }

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
            uuid.v4(),
            DeviceEntityTypeInP4.Clock,
            CardType.Other,
            0,
            [1, 2, 5, 6],
            DataInputCard(
                name: '时钟',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '',
                type: 'clock',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.Weather,
            CardType.Other,
            0,
            [3, 4, 7, 8],
            DataInputCard(
                name: '天气',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '',
                type: 'weather',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '灯1',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel1',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '灯2',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '',
                type: 'localPanel2',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1')),
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

  // 用于删除指定 deviceId 和 pageIndex 的布局对象。
  void deleteLayout(String deviceId, int pageIndex) {
    layouts.removeWhere(
        (item) => item.deviceId == deviceId && item.pageIndex == pageIndex);
    _saveLayouts();
    notifyListeners();
  }

  // 用于根据设备ID获取相关的布局对象列表。
  Layout getLayoutsByDevice(String deviceId) {
    return layouts.firstWhere((item) => item.deviceId == deviceId);
  }

  // 用于根据页面索引获取相关的布局对象列表
  List<Layout> getLayoutsByPageIndex(int pageIndex) {
    return layouts.where((item) => item.pageIndex == pageIndex).toList();
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
    List<Layout> layoutsOnPage =
        layouts.where((element) => element.pageIndex == pageIndex).toList();
    List<int> gridFilledOnPage = [];
    layoutsOnPage.forEach((element) {
      gridFilledOnPage.addAll(element.grids);
    });
    return gridFilledOnPage.length < itemsPerPage;
  }

  // 根据CardType判断第几页有适合的空位
  LayoutPosition getFlexiblePage(CardType cardType) {
    int maxPage = getMaxPageIndex();
    for (int i = 0; i <= maxPage; i++) {
      if (isFillPage(i)) {
        // 该页有空位

        // 获取该页的layouts
        List<Layout> layoutsInCurPage =
            layouts.where((element) => element.pageIndex == i).toList();
        Screen screenLayer = Screen();
        for (int j = 0; j < layoutsInCurPage.length; j++) {
          for (int k = 0; k < layoutsInCurPage[j].grids.length; k++) {
            int row = (layoutsInCurPage[j].grids[k] - 1) ~/ 4;
            int col = (layoutsInCurPage[j].grids[k] - 1) % 4;
            screenLayer.setCellOccupied(row, col, true);
          }
        }
        // 尝试填充
        List<int> fillCells = screenLayer.checkAvailability(cardType);
        if (fillCells.isNotEmpty) {
          // 有合适的位置
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
  void swapPosition(Layout source, Layout targetOne) {
    int distance = targetOne.grids[0] - source.grids[0];
    List<int> target = source.grids.map((e) => e + distance).toList();
    Log.i('原位置${source.grids}到目标${target}', distance);
    // 避免越界

    List<Layout> curPageLayoutList = getLayoutsByPageIndex(source.pageIndex);
    List<Layout> fillNulls =
        fillNullLayoutList(curPageLayoutList, source.pageIndex);
    List<int> targetIndexes = [];

    if (isOver(source.cardType, target)) {
      Log.i('目标越界');
      if (source.cardType == CardType.Big && distance.abs() > 8) {
        distance = distance > 0 ? 8 : -8;
        target = source.grids.map((e) => e + distance).toList();
      } else if (source.cardType == CardType.Big && distance < -4) {
        distance = -8;
        target = source.grids.map((e) => e + distance).toList();
      } else {
        return;
      }
      Log.i('目标变更${target}', distance);
    }

    int lengthSum = 0;
    // 找到目标
    for (int i = 0; i < fillNulls.length; i++) {
      List<int> grids = fillNulls[i].grids;
      if (grids != source.grids) {
        if (target.any((element) => grids.contains(element))) {
          if (i < curPageLayoutList.length &&
              curPageLayoutList
                  .any((element) =>
              element.deviceId == fillNulls[i].deviceId)) {
            targetIndexes.add(i);
          }
          lengthSum += grids.length;
        }
      }
    }

    // 如果元素移动到有自身的格子
    if (findDuplicates(source.grids, target).isNotEmpty) {
      lengthSum += findDuplicates(source.grids, target).length;
      Log.i('元素移动到有自身的格子', findDuplicates(source.grids, target));
    }

    // 目标违规
    if (lengthSum != target.length && lengthSum != 0) {
      Log.i('目标违规', lengthSum);
      return;
    }

    // 对占位进行替换
    if (targetIndexes.isNotEmpty) {
      bool isValid = true;
      for (int i = 0; i < targetIndexes.length; i++) {
        // 再逐个替换掉被置换的占位
        Layout targetLayout = layouts.firstWhere((layout) =>
            layout.deviceId == curPageLayoutList[targetIndexes[i]].deviceId);
        if (targetLayout.grids.length > source.grids.length) {
          // 只能大替换小
          isValid = false;
          break;
        }
        List<int> newGrids = targetLayout.grids
            .map((item) => item + source.grids[0] - target[0])
            .cast<int>()
            .toList();
        if (isOver(targetLayout.cardType, newGrids)) {
          isValid = false;
          break;
        }
        // 检查目标位置是否已在某元素中
        targetLayout.grids = newGrids;
      }
      if (!isValid) return;
    }
    // 进行源到目标动作
    source.grids = target;

    // _saveLayouts();
    notifyListeners();
  }

  // 卡片大小替换
  void swapCardType(Layout layout, CardType targetType) {
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
        if (curLayouts[layoutInCurPageIndex].deviceId != layout.deviceId) {
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
    if (fillCells.isEmpty) {
      // 新占位成功
      layout.grids = fillCells;
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
          if (maxLayouts[layoutInMaxPageIndex].deviceId != layout.deviceId) {
            // 取出当前布局的grids
            for (int gridsIndexInMaxPage = 0;
                gridsIndexInMaxPage < curLayouts[layoutInMaxPageIndex].grids.length;
                gridsIndexInMaxPage ++) {
              // 把已经布局的数据在布局器中占位
              int grid = maxLayouts[layoutInMaxPageIndex].grids[gridsIndexInMaxPage];
              int row = (grid - 1) ~/ 4;
              int col = (grid - 1) % 4;
              screenLayer.setCellOccupied(row, col, true);
            }
          }
        }
      }
      List<int> fillCellsInMaxPage = screenLayer.checkAvailability(targetType);
      if (fillCellsInMaxPage.isEmpty) {
        // 新占位成功
        layout.pageIndex = maxPage;
        layout.grids = fillCells;
      } else {
        // 最后一页也没有空间了，开一页新的
        screenLayer.resetGrid();
        deleteLayout(layout.deviceId, layout.pageIndex);
        List<int> fillCellsNew = screenLayer.checkAvailability(targetType);
        Layout newLayout = Layout(layout.deviceId, layout.type, targetType,
            maxPage + 1, fillCellsNew, layout.data);
        addLayout(newLayout);
      }
    }
    _saveLayouts();
    notifyListeners();
  }

  void handleNullPage() {
    List<int> pagesList = layouts.map((e) => e.pageIndex).toList();
    for (int i = 0; i < pagesList.length; i++) {
      for (var element in layouts) {
        if (element.pageIndex == pagesList[i]) {
          element.pageIndex = i;
        }
      }
    }
    _saveLayouts();
    notifyListeners();
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
