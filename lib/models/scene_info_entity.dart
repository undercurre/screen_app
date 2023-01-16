import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/scene_info_entity.g.dart';

@JsonSerializable()
class SceneInfoEntity {
  SceneInfoEntity();

  dynamic subscribeGroup;
  dynamic legalDay;
  dynamic eventLogical;
  dynamic sceneClassify;
  dynamic corpus;
  dynamic homegroupId;
  dynamic weekly;
  dynamic labelId;
  dynamic enable;
  dynamic appId;
  dynamic sceneId;
  dynamic brand;
  dynamic thirdUpdateTime;
  dynamic image;
  dynamic sceneGroupId;
  dynamic promptStatus;
  dynamic cuid;
  dynamic airecRecommendId;
  dynamic effectiveZone;
  dynamic updateTime;
  dynamic version;
  dynamic sceneStatus;
  dynamic sceneType;
  dynamic createTime;
  dynamic name;

  factory SceneInfoEntity.fromJson(Map<String, dynamic> json) =>
      $SceneInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => $SceneInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
