import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_home_entity.dart';
import 'meiju_home_list_entity.g.dart';

@JsonSerializable()
class MeiJuHomeListEntity {
  MeiJuHomeListEntity();

  List<MeiJuHomeEntity>? homeList;

  factory MeiJuHomeListEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuHomeListEntityFromJson(json);
  Map<String, dynamic> toJson() => $MeiJuHomeListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
