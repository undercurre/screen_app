import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_home_info_entity.dart';
import 'meiju_home_list_info_entity.g.dart';

@JsonSerializable()
class MeiJuHomeInfoListEntity {
  MeiJuHomeInfoListEntity();

  List<MeiJuHomeInfoEntity>? homeList;

  factory MeiJuHomeInfoListEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuHomeInfoListEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuHomeInfoListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
