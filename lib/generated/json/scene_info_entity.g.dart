import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/scene_info_entity.dart';

SceneInfoEntity $SceneInfoEntityFromJson(Map<String, dynamic> json) {
  final SceneInfoEntity sceneInfoEntity = SceneInfoEntity();
  final String? subscribeGroup =
      jsonConvert.convert<String>(json['subscribeGroup']);
  if (subscribeGroup != null) {
    sceneInfoEntity.subscribeGroup = subscribeGroup;
  }
  final String? legalDay = jsonConvert.convert<String>(json['legalDay']);
  if (legalDay != null) {
    sceneInfoEntity.legalDay = legalDay;
  }
  final String? eventLogical =
      jsonConvert.convert<String>(json['eventLogical']);
  if (eventLogical != null) {
    sceneInfoEntity.eventLogical = eventLogical;
  }
  final String? sceneClassify =
      jsonConvert.convert<String>(json['sceneClassify']);
  if (sceneClassify != null) {
    sceneInfoEntity.sceneClassify = sceneClassify;
  }
  final String? corpus = jsonConvert.convert<String>(json['corpus']);
  if (corpus != null) {
    sceneInfoEntity.corpus = corpus;
  }
  final dynamic? homegroupId =
      jsonConvert.convert<dynamic>(json['homegroupId']);
  if (homegroupId != null) {
    sceneInfoEntity.homegroupId = homegroupId;
  }
  final String? weekly = jsonConvert.convert<String>(json['weekly']);
  if (weekly != null) {
    sceneInfoEntity.weekly = weekly;
  }
  final String? labelId = jsonConvert.convert<String>(json['labelId']);
  if (labelId != null) {
    sceneInfoEntity.labelId = labelId;
  }
  final dynamic? enable = jsonConvert.convert<dynamic>(json['enable']);
  if (enable != null) {
    sceneInfoEntity.enable = enable;
  }
  final dynamic? appId = jsonConvert.convert<dynamic>(json['appId']);
  if (appId != null) {
    sceneInfoEntity.appId = appId;
  }
  final dynamic? sceneId = jsonConvert.convert<dynamic>(json['sceneId']);
  if (sceneId != null) {
    sceneInfoEntity.sceneId = sceneId;
  }
  final String? brand = jsonConvert.convert<String>(json['brand']);
  if (brand != null) {
    sceneInfoEntity.brand = brand;
  }
  final String? thirdUpdateTime =
      jsonConvert.convert<String>(json['thirdUpdateTime']);
  if (thirdUpdateTime != null) {
    sceneInfoEntity.thirdUpdateTime = thirdUpdateTime;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    sceneInfoEntity.image = image;
  }
  final String? sceneGroupId =
      jsonConvert.convert<String>(json['sceneGroupId']);
  if (sceneGroupId != null) {
    sceneInfoEntity.sceneGroupId = sceneGroupId;
  }
  final String? promptStatus =
      jsonConvert.convert<String>(json['promptStatus']);
  if (promptStatus != null) {
    sceneInfoEntity.promptStatus = promptStatus;
  }
  final String? cuid = jsonConvert.convert<String>(json['cuid']);
  if (cuid != null) {
    sceneInfoEntity.cuid = cuid;
  }
  final String? airecRecommendId =
      jsonConvert.convert<String>(json['airecRecommendId']);
  if (airecRecommendId != null) {
    sceneInfoEntity.airecRecommendId = airecRecommendId;
  }
  final String? effectiveZone =
      jsonConvert.convert<String>(json['effectiveZone']);
  if (effectiveZone != null) {
    sceneInfoEntity.effectiveZone = effectiveZone;
  }
  final String? updateTime = jsonConvert.convert<String>(json['updateTime']);
  if (updateTime != null) {
    sceneInfoEntity.updateTime = updateTime;
  }
  final String? version = jsonConvert.convert<String>(json['version']);
  if (version != null) {
    sceneInfoEntity.version = version;
  }
  final dynamic? sceneStatus =
      jsonConvert.convert<dynamic>(json['sceneStatus']);
  if (sceneStatus != null) {
    sceneInfoEntity.sceneStatus = sceneStatus;
  }
  final dynamic? sceneType = jsonConvert.convert<dynamic>(json['sceneType']);
  if (sceneType != null) {
    sceneInfoEntity.sceneType = sceneType;
  }
  final String? createTime = jsonConvert.convert<String>(json['createTime']);
  if (createTime != null) {
    sceneInfoEntity.createTime = createTime;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    sceneInfoEntity.name = name;
  }
  return sceneInfoEntity;
}

Map<String, dynamic> $SceneInfoEntityToJson(SceneInfoEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['subscribeGroup'] = entity.subscribeGroup;
  data['legalDay'] = entity.legalDay;
  data['eventLogical'] = entity.eventLogical;
  data['sceneClassify'] = entity.sceneClassify;
  data['corpus'] = entity.corpus;
  data['homegroupId'] = entity.homegroupId;
  data['weekly'] = entity.weekly;
  data['labelId'] = entity.labelId;
  data['enable'] = entity.enable;
  data['appId'] = entity.appId;
  data['sceneId'] = entity.sceneId;
  data['brand'] = entity.brand;
  data['thirdUpdateTime'] = entity.thirdUpdateTime;
  data['image'] = entity.image;
  data['sceneGroupId'] = entity.sceneGroupId;
  data['promptStatus'] = entity.promptStatus;
  data['cuid'] = entity.cuid;
  data['airecRecommendId'] = entity.airecRecommendId;
  data['effectiveZone'] = entity.effectiveZone;
  data['updateTime'] = entity.updateTime;
  data['version'] = entity.version;
  data['sceneStatus'] = entity.sceneStatus;
  data['sceneType'] = entity.sceneType;
  data['createTime'] = entity.createTime;
  data['name'] = entity.name;
  return data;
}
