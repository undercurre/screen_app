import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/scene_list_entity.g.dart';
import 'dart:convert';

import 'package:screen_app/models/scene_info_entity.dart';

@JsonSerializable()
class SceneListEntity {
  SceneListEntity();

  late num total;
  late List<SceneInfoEntity> list;

  factory SceneListEntity.fromJson(Map<String, dynamic> json) =>
      $SceneListEntityFromJson(json);
  Map<String, dynamic> toJson() => $SceneListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
