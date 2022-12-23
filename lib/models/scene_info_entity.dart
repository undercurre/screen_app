import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/scene_info_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class SceneInfoEntity {
  SceneInfoEntity();

  late String? subscribeGroup;
  late String? legalDay;
  late String? eventLogical;
  late String? sceneClassify;
  late String? corpus;
  dynamic homegroupId;
  late String? weekly;
  late String? labelId;
  dynamic enable;
  dynamic appId;
  dynamic sceneId;
  late String? brand;
  late String? thirdUpdateTime;
  late String? image;
  late String? sceneGroupId;
  late String? promptStatus;
  late String? cuid;
  late String? airecRecommendId;
  late String? effectiveZone;
  late String? updateTime;
  late String? version;
  dynamic sceneStatus;
  dynamic sceneType;
  late String? createTime;
  late String name;

  factory SceneInfoEntity.fromJson(Map<String, dynamic> json) =>
      $SceneInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => $SceneInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
