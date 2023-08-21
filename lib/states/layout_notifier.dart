import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
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

  void setLayouts(List<Layout> newLayouts) {
    layouts = newLayouts;
    _saveLayouts();
    notifyListeners();
  }

  // 初始化时从本地读取布局数据
  LayoutModel() {
    _loadLayouts();
  }

  Future<void> _loadLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutList = prefs.getStringList('layouts');
    if (layoutList != null) {
      layouts = layoutList.map((json) => Layout.fromJson(json)).toList();
      // 安全过滤
      for (int i = 0; i < layouts.length; i ++) {
        // 找到数组中的最小值
        int minValue = layouts[i].grids.reduce((min, current) => min < current ? min : current);

        // 计算最小值与1的差距
        int difference = 1 - minValue;

        // 将最小值变为1，其他的值增加相同的差距
        layouts[i].grids = layouts[i].grids.map((number) => number + difference).toList();
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
                isOnline: '')),
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
                isOnline: '')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '继电器1',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '继电器2',
                applianceCode: uuid.v4(),
                roomName: '屏内',
                isOnline: '')),
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
          cloneList.add(Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceNull,
              CardType.Small,
              pageIndex,
              fillCells,
              DataInputCard(
                  name: '', applianceCode: '', roomName: '', isOnline: '')));
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
    // 避免越界

    List<Layout> curPageLayoutList = getLayoutsByPageIndex(source.pageIndex);
    List<int> targetIndexes = [];

    if (isOver(source.cardType, target)) {
      return;
    }

    int lengthSum = 0;
    // 找到目标
    for (int i = 0; i < curPageLayoutList.length; i++) {
      List<int> grids = curPageLayoutList[i].grids;
      if (target.any((element) => grids.contains(element))) {
        targetIndexes.add(i);
        lengthSum += grids.length;
      }
    }
    // 目标违规
    if (lengthSum != target.length) {
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

  void handleNullPage() {
    List<int> pagesList = layouts.map((e) => e.pageIndex).toList();
    for (int i = 0; i < pagesList.length; i ++) {
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
      [1,2],
      [3,4],
      [5,6],
      [7,8],
      [9,10],
      [11,12],
      [13,14],
      [15,16]
    ];
    if (!isTargetInValidList(valid, target)) {
      return true;
    }
  }

  if (cardType == CardType.Middle || cardType == CardType.Other) {
    List<List<int>> valid = [
      [1,2,5,6],
      [3,4,7,8],
      [5,6,9,10],
      [7,8,11,12],
      [9,10,13,14],
      [11,12,15,16]
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