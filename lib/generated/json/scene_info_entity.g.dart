import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/scene_info_entity.dart';

SceneInfoEntity $SceneInfoEntityFromJson(Map<String, dynamic> json) {
	final SceneInfoEntity sceneInfoEntity = SceneInfoEntity();
	final dynamic subscribeGroup = jsonConvert.convert<dynamic>(json['subscribeGroup']);
	if (subscribeGroup != null) {
		sceneInfoEntity.subscribeGroup = subscribeGroup;
	}
	final dynamic legalDay = jsonConvert.convert<dynamic>(json['legalDay']);
	if (legalDay != null) {
		sceneInfoEntity.legalDay = legalDay;
	}
	final dynamic eventLogical = jsonConvert.convert<dynamic>(json['eventLogical']);
	if (eventLogical != null) {
		sceneInfoEntity.eventLogical = eventLogical;
	}
	final dynamic sceneClassify = jsonConvert.convert<dynamic>(json['sceneClassify']);
	if (sceneClassify != null) {
		sceneInfoEntity.sceneClassify = sceneClassify;
	}
	final dynamic corpus = jsonConvert.convert<dynamic>(json['corpus']);
	if (corpus != null) {
		sceneInfoEntity.corpus = corpus;
	}
	final dynamic homegroupId = jsonConvert.convert<dynamic>(json['homegroupId']);
	if (homegroupId != null) {
		sceneInfoEntity.homegroupId = homegroupId;
	}
	final dynamic weekly = jsonConvert.convert<dynamic>(json['weekly']);
	if (weekly != null) {
		sceneInfoEntity.weekly = weekly;
	}
	final dynamic labelId = jsonConvert.convert<dynamic>(json['labelId']);
	if (labelId != null) {
		sceneInfoEntity.labelId = labelId;
	}
	final dynamic enable = jsonConvert.convert<dynamic>(json['enable']);
	if (enable != null) {
		sceneInfoEntity.enable = enable;
	}
	final dynamic appId = jsonConvert.convert<dynamic>(json['appId']);
	if (appId != null) {
		sceneInfoEntity.appId = appId;
	}
	final dynamic sceneId = jsonConvert.convert<dynamic>(json['sceneId']);
	if (sceneId != null) {
		sceneInfoEntity.sceneId = sceneId;
	}
	final dynamic brand = jsonConvert.convert<dynamic>(json['brand']);
	if (brand != null) {
		sceneInfoEntity.brand = brand;
	}
	final dynamic thirdUpdateTime = jsonConvert.convert<dynamic>(json['thirdUpdateTime']);
	if (thirdUpdateTime != null) {
		sceneInfoEntity.thirdUpdateTime = thirdUpdateTime;
	}
	final dynamic image = jsonConvert.convert<dynamic>(json['image']);
	if (image != null) {
		sceneInfoEntity.image = image;
	}
	final dynamic sceneGroupId = jsonConvert.convert<dynamic>(json['sceneGroupId']);
	if (sceneGroupId != null) {
		sceneInfoEntity.sceneGroupId = sceneGroupId;
	}
	final dynamic promptStatus = jsonConvert.convert<dynamic>(json['promptStatus']);
	if (promptStatus != null) {
		sceneInfoEntity.promptStatus = promptStatus;
	}
	final dynamic cuid = jsonConvert.convert<dynamic>(json['cuid']);
	if (cuid != null) {
		sceneInfoEntity.cuid = cuid;
	}
	final dynamic airecRecommendId = jsonConvert.convert<dynamic>(json['airecRecommendId']);
	if (airecRecommendId != null) {
		sceneInfoEntity.airecRecommendId = airecRecommendId;
	}
	final dynamic effectiveZone = jsonConvert.convert<dynamic>(json['effectiveZone']);
	if (effectiveZone != null) {
		sceneInfoEntity.effectiveZone = effectiveZone;
	}
	final dynamic updateTime = jsonConvert.convert<dynamic>(json['updateTime']);
	if (updateTime != null) {
		sceneInfoEntity.updateTime = updateTime;
	}
	final dynamic version = jsonConvert.convert<dynamic>(json['version']);
	if (version != null) {
		sceneInfoEntity.version = version;
	}
	final dynamic sceneStatus = jsonConvert.convert<dynamic>(json['sceneStatus']);
	if (sceneStatus != null) {
		sceneInfoEntity.sceneStatus = sceneStatus;
	}
	final dynamic sceneType = jsonConvert.convert<dynamic>(json['sceneType']);
	if (sceneType != null) {
		sceneInfoEntity.sceneType = sceneType;
	}
	final dynamic createTime = jsonConvert.convert<dynamic>(json['createTime']);
	if (createTime != null) {
		sceneInfoEntity.createTime = createTime;
	}
	final dynamic name = jsonConvert.convert<dynamic>(json['name']);
	if (name != null) {
		sceneInfoEntity.name = name;
	}
	final dynamic roomId = jsonConvert.convert<dynamic>(json['roomId']);
	if (name != null) {
		sceneInfoEntity.roomId = roomId;
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
	data['roomId'] = entity.roomId;
	return data;
}