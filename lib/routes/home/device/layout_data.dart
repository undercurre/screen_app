import 'dart:convert';

import 'grid_container.dart';

class Layout {
  String deviceId;
  String type;
  CardType cardType;
  int pageIndex;
  double left;
  double top;
  dynamic data;

  Layout(this.deviceId, this.type, this.cardType, this.pageIndex, this.left, this.top, this.data);

  Layout clone() {
    return Layout(
      deviceId,
      type,
      cardType,
      pageIndex,
      left,
      top,
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
      map['left'] as double,
      map['top'] as double,
      map['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'type': type,
      'cardType': _cardTypeToString(cardType),
      'pageIndex': pageIndex,
      'left': left,
      'top': top,
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
}