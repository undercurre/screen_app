import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/scene_info_entity.dart';

SceneInfoEntity $SceneInfoEntityFromJson(Map<String, dynamic> json) {
  final SceneInfoEntity sceneInfoEntity = SceneInfoEntity();
  final dynamic? appId = jsonConvert.convert<dynamic>(json['appId']);
  if (appId != null) {
    sceneInfoEntity.appId = appId;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    sceneInfoEntity.image = image;
  }
  final String? eventLogical =
      jsonConvert.convert<String>(json['eventLogical']);
  if (eventLogical != null) {
    sceneInfoEntity.eventLogical = eventLogical;
  }
  final String? updateTime = jsonConvert.convert<String>(json['updateTime']);
  if (updateTime != null) {
    sceneInfoEntity.updateTime = updateTime;
  }
  final num? homegroupId = jsonConvert.convert<num>(json['homegroupId']);
  if (homegroupId != null) {
    sceneInfoEntity.homegroupId = homegroupId;
  }
  final String? version = jsonConvert.convert<String>(json['version']);
  if (version != null) {
    sceneInfoEntity.version = version;
  }
  final String? weekly = jsonConvert.convert<String>(json['weekly']);
  if (weekly != null) {
    sceneInfoEntity.weekly = weekly;
  }
  final num? sceneType = jsonConvert.convert<num>(json['sceneType']);
  if (sceneType != null) {
    sceneInfoEntity.sceneType = sceneType;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    sceneInfoEntity.createTime = createTime;
  }
  final num? enable = jsonConvert.convert<num>(json['enable']);
  if (enable != null) {
    sceneInfoEntity.enable = enable;
  }
  final num? sceneId = jsonConvert.convert<num>(json['sceneId']);
  if (sceneId != null) {
    sceneInfoEntity.sceneId = sceneId;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    sceneInfoEntity.name = name;
  }
  return sceneInfoEntity;
}

Map<String, dynamic> $SceneInfoEntityToJson(SceneInfoEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['appId'] = entity.appId;
  data['image'] = entity.image;
  data['eventLogical'] = entity.eventLogical;
  data['updateTime'] = entity.updateTime;
  data['homegroupId'] = entity.homegroupId;
  data['version'] = entity.version;
  data['weekly'] = entity.weekly;
  data['sceneType'] = entity.sceneType;
  data['createTime'] = entity.createTime;
  data['enable'] = entity.enable;
  data['sceneId'] = entity.sceneId;
  data['name'] = entity.name;
  return data;
}
