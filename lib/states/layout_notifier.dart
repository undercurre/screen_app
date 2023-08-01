import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/api/api.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/home/device/layout_data.dart';

class LayoutModel extends ChangeNotifier {
  List<Layout> layouts = [];

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
    logger.i('加载model', layoutList);
    if (layoutList != null) {
      layouts = layoutList.map((json) => Layout.fromJson(json)).toList();
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
                name: '时钟', applianceCode: uuid.v4(), roomName: '屏内')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.Weather,
            CardType.Other,
            0,
            [3, 4, 7, 8],
            DataInputCard(
                name: '天气', applianceCode: uuid.v4(), roomName: '屏内')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel1,
            CardType.Small,
            0,
            [9, 10],
            DataInputCard(
                name: '继电器1', applianceCode: uuid.v4(), roomName: '屏内')),
        Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.LocalPanel2,
            CardType.Small,
            0,
            [11, 12],
            DataInputCard(
                name: '继电器2', applianceCode: uuid.v4(), roomName: '屏内')),
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

  Future<void> _removeLayouts() async {
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
    logger.i('layout长度', layouts.length);
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

  // 拖拽换位算法
  void swapPosition(Layout source, rowIndex, columnIndex) {
    List<Layout> curPageLayoutList = getLayoutsByPageIndex(source.pageIndex);
    // 小卡片
    if (source.cardType == CardType.Small) {
      if (columnIndex <= 1) {
        columnIndex = 0;
      } else {
        columnIndex = 2;
      }
      if (rowIndex <= 0) {
        rowIndex = 0;
      }
      if (rowIndex >= 3) {
        rowIndex = 3;
      }
    }
    // 中卡片
    if (source.cardType == CardType.Middle ||
        source.cardType == CardType.Other) {
      if (columnIndex <= 1) {
        columnIndex = 0;
      } else {
        columnIndex = 2;
      }
      if (rowIndex <= 0) {
        rowIndex = 0;
      }
      if (rowIndex >= 2) {
        rowIndex = 2;
      }
    }

    // 大卡片
    if (source.cardType == CardType.Big) {
      columnIndex = 0;

      if (rowIndex <= 0) {
        rowIndex = 0;
      }

      if (curPageLayoutList.any((element) =>
          element.cardType == CardType.Middle ||
          element.cardType == CardType.Other && rowIndex <= 1)) {
        rowIndex = 0;
      }

      if (rowIndex >= 2) {
        rowIndex = 2;
      }
    }

    int zengliang = rowIndex * 4 + columnIndex + 1 - source.grids[0];
    List<int> target = source.grids.map((e) => e + zengliang).toList();
    List<int> targetIndexes = [];

    // 找到目标
    for (int i = 0; i < curPageLayoutList.length; i++) {
      List<int> grids = curPageLayoutList[i].grids;
      if (target.any((element) => grids.contains(element))) {
        targetIndexes.add(i);
      }
    }

    // 对占位进行替换
    if (targetIndexes.isNotEmpty) {
      bool isValid = true;
      for (int i = 0; i < targetIndexes.length; i++) {
        // 再逐个替换掉被置换的占位
        Layout targetLayout = layouts.firstWhere((layout) =>
            layout.deviceId == curPageLayoutList[targetIndexes[i]].deviceId);
        if (targetLayout.grids.length > source.grids.length) {
          isValid = false;
          break;
        }
        targetLayout.grids = targetLayout.grids
            .map((item) => item + source.grids[0] - target[0])
            .cast<int>()
            .toList();
      }
      if (!isValid) return;
    }

    source.grids = target;
    logger.i(
        '处理完成', getLayoutsByPageIndex(source.pageIndex).map((e) => e.grids));

    _saveLayouts();
    notifyListeners();
  }
}
