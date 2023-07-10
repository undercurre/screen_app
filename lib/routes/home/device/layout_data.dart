import 'dart:convert';

import 'package:screen_app/common/global.dart';

import 'grid_container.dart';

class Layout {
  String deviceId;
  String type;
  CardType cardType;
  int pageIndex;
  List<int> grids;
  dynamic data;

  Layout(this.deviceId, this.type, this.cardType, this.pageIndex, this.grids, this.data);

  Layout clone() {
    return Layout(
      deviceId,
      type,
      cardType,
      pageIndex,
      grids,
      data,
    );
  }

  factory Layout.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return Layout(
      map['deviceId'] as String,
      map['type'] as String,
      _parseCardType(map['cardType'] as String),
      map['pageIndex'] as int,
      map['grids'] as List<int>,
      map['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'type': type,
      'cardType': _cardTypeToString(cardType),
      'pageIndex': pageIndex,
      'grids': grids,
      'data': data,
    };
  }

  static CardType _parseCardType(String value) {
    return CardType.values.firstWhere(
          (type) => type.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => CardType.Other,
    );
  }

  static String _cardTypeToString(CardType cardType) {
    return cardType.toString().split('.').last.toLowerCase();
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
      for (int i = 0; i < a.grids.length  && i < b.grids.length; i++) {
        final gridComparison = a.grids[i].compareTo(b.grids[i]);

        if (gridComparison != 0) {
          return gridComparison;
        }
      }

      return 0;
    });

    return layoutList;
  }
}