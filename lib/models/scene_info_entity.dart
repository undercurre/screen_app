import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/scene_info_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class SceneInfoEntity {
  SceneInfoEntity();

  dynamic appId;
  late String image;
  late String eventLogical;
  late String updateTime;
  late num homegroupId;
  late String version;
  late String weekly;
  late num sceneType;
  late String createTime;
  late num enable;
  late num sceneId;
  late String name;

  factory SceneInfoEntity.fromJson(Map<String, dynamic> json) =>
      $SceneInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => $SceneInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
