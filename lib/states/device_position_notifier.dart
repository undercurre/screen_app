import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/home/device/layout_data.dart';

class LayoutModel extends ChangeNotifier {
  List<Layout> layouts = [];

  void setLayouts(List<Layout> newLayouts) {
    layouts = newLayouts;
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
    }
    notifyListeners();
  }

  Future<void> _saveLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutList =
        layouts.map((layout) => jsonEncode(layout.toJson())).toList();
    await prefs.setStringList('layouts', layoutList);
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
}
