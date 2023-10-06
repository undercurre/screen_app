import 'dart:convert';

import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/device/card_type_config.dart';

import '../../../common/api/api.dart';
import '../../../common/logcat_helper.dart';
import 'grid_container.dart';

class Layout {
  String deviceId;
  DeviceEntityTypeInP4 type;
  CardType cardType;
  int pageIndex;
  List<int> grids;
  DataInputCard data;
  bool disabled;

  Layout(this.deviceId, this.type, this.cardType, this.pageIndex, this.grids,
      this.data,
      {this.disabled = false});

  Layout clone() {
    return Layout(
      deviceId,
      type,
      cardType,
      pageIndex,
      grids,
      data,
      disabled: disabled,
    );
  }

  factory Layout.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final grids = (map['grids'] as List<dynamic>).cast<int>();
    final dataJson = map['data'] as Map<String, dynamic>;
    final data = DataInputCard.fromJson(dataJson);
    return Layout(
      map['deviceId'] as String,
      _parseDeviceEntityTypeInP4(map['type'] as String),
      _parseCardType(map['cardType'] as String),
      map['pageIndex'] as int,
      grids,
      data,
      disabled: map['disabled'] as bool ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'type': _deviceEntityTypeInP4ToString(type),
      'cardType': _cardTypeToString(cardType),
      'pageIndex': pageIndex,
      'grids': grids,
      'data': data.toJson(),
      'disabled': disabled,
    };
  }

  static CardType _parseCardType(String value) {
    return CardType.values.firstWhere(
      (type) =>
          type.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => CardType.Other,
    );
  }

  static String _cardTypeToString(CardType cardType) {
    return cardType.toString().split('.').last.toLowerCase();
  }

  static DeviceEntityTypeInP4 _parseDeviceEntityTypeInP4(String value) {
    return DeviceEntityTypeInP4.values.firstWhere(
      (type) =>
          type.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => DeviceEntityTypeInP4.Default,
    );
  }

  static String _deviceEntityTypeInP4ToString(DeviceEntityTypeInP4 type) {
    return type.toString().split('.').last.toLowerCase();
  }

  static List<Layout> sortLayoutList(List<Layout> layoutList) {
    layoutList.sort((a, b) {
      // 按页面先后
      final pageIndexComparison = a.pageIndex.compareTo(b.pageIndex);

      if (pageIndexComparison != 0) {
        return pageIndexComparison;
      }

      // 按卡片大小
      // final gridsComparison = a.grids.length.compareTo(b.grids.length);
      //
      // if (gridsComparison != 0) {
      //   return gridsComparison;
      // }

      //
      for (int i = 0; i < a.grids.length && i < b.grids.length; i++) {
        final gridComparison = a.grids[i].compareTo(b.grids[i]);

        if (gridComparison != 0) {
          return gridComparison;
        }
      }

      return 0;
    });

    return layoutList;
  }

  static List<Layout> filledLayout(List<Layout> layouts) {
    if (layouts.isEmpty) return [];
    List<Layout> clone = List<Layout>.from(layouts);
    Log.i('克隆', clone.map((e) => e.grids));
    clone.removeWhere((element) => element.cardType == CardType.Null);
    List<Layout> newList = [...clone];
    Screen screenLayer = Screen();
    // 拿到当前页的layout
    for (int layIndex = 0; layIndex < clone.length; layIndex++) {
      // 取出当前布局的grids
      for (int gridsIndex = 0;
          gridsIndex < clone[layIndex].grids.length;
          gridsIndex++) {
        // 把已经布局的数据在布局器中占位
        int grid = clone[layIndex].grids[gridsIndex];
        int row = (grid - 1) ~/ 4;
        int col = (grid - 1) % 4;
        screenLayer.setCellOccupied(row, col, true);
      }
    }

    // 尝试占位
    List<int> fillCells = screenLayer.checkAvailability(CardType.Null);

    if (fillCells.isNotEmpty) {
      for (int gridsIndex = 0; gridsIndex < fillCells.length; gridsIndex++) {
        // 把已经布局的数据在布局器中占位
        int grid = fillCells[gridsIndex];
        int row = (grid - 1) ~/ 4;
        int col = (grid - 1) % 4;
        screenLayer.setCellOccupied(row, col, true);
      }
      // 填充
      newList.add(Layout(
          uuid.v4(),
          DeviceEntityTypeInP4.DeviceNull,
          CardType.Null,
          layouts[0].pageIndex,
          fillCells,
          DataInputCard(
              name: '',
              type: '',
              applianceCode: '',
              roomName: '',
              masterId: '',
              modelNumber: '',
              isOnline: '',
              onlineStatus: '')));
    } else {
      // 填满
      return newList;
    }

    while (fillCells.isNotEmpty) {
      fillCells = screenLayer.checkAvailability(CardType.Null);
      for (int gridsIndex = 0; gridsIndex < fillCells.length; gridsIndex++) {
        // 把已经布局的数据在布局器中占位
        int grid = fillCells[gridsIndex];
        int row = (grid - 1) ~/ 4;
        int col = (grid - 1) % 4;
        screenLayer.setCellOccupied(row, col, true);
      }
      if (fillCells.isNotEmpty) {
        // 填充
        newList.add(
          Layout(
            uuid.v4(),
            DeviceEntityTypeInP4.DeviceNull,
            CardType.Null,
            layouts[0].pageIndex,
            fillCells,
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
    }
    Log.i('最后新表', newList.map((e) => e.grids));
    return newList;
  }

  static List<Layout> flexLayout(List<Layout> layouts) {
    List<Layout> valid = layouts.where((element) => element.cardType != CardType.Null).toList();
    Log.i('要flex的合法数据', valid.map((e) => e.grids));
    List<Layout> newList = [];
    Screen screenLayer = Screen();
    for(int i = 0; i < valid.length; i++) {
      List<int> fillCells = screenLayer.checkAvailability(valid[i].cardType);
      if (fillCells.isNotEmpty) {
        valid[i].grids = fillCells;
        newList.add(valid[i]);
        for (int gridsIndex = 0; gridsIndex < fillCells.length; gridsIndex++) {
          // 把已经布局的数据在布局器中占位
          int grid = fillCells[gridsIndex];
          int row = (grid - 1) ~/ 4;
          int col = (grid - 1) % 4;
          screenLayer.setCellOccupied(row, col, true);
        }
      }
    }
    return filledLayout(newList);
  }
}
