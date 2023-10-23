
import '../generated/json/base/homlux_json_convert_content.dart';
import 'homlux_panel_associate_scene_entity.dart';

HomluxPanelAssociateSceneEntity $HomluxPanelAssociateSceneEntityEntityFromJson(Map<String, dynamic> json) {
	final HomluxPanelAssociateSceneEntity homluxPanelAssociateSceneEntityEntity = HomluxPanelAssociateSceneEntity();
	final String? deviceId = homluxJsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		homluxPanelAssociateSceneEntityEntity.deviceId = deviceId;
	}
	final String? modelName = homluxJsonConvert.convert<String>(json['modelName']);
	if (modelName != null) {
		homluxPanelAssociateSceneEntityEntity.modelName = modelName;
	}
	final List<HomluxPanelAssociateSceneEntitySceneList>? sceneList = homluxJsonConvert.convertListNotNull<HomluxPanelAssociateSceneEntitySceneList>(json['sceneList']);
	if (sceneList != null) {
		homluxPanelAssociateSceneEntityEntity.sceneList = sceneList;
	}
	return homluxPanelAssociateSceneEntityEntity;
}

Map<String, dynamic> $HomluxPanelAssociateSceneEntityEntityToJson(HomluxPanelAssociateSceneEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['deviceId'] = entity.deviceId;
	data['modelName'] = entity.modelName;
	data['sceneList'] =  entity.sceneList?.map((v) => v.toJson()).toList();
	return data;
}

HomluxPanelAssociateSceneEntitySceneList $HomluxPanelAssociateSceneEntitySceneListFromJson(Map<String, dynamic> json) {
	final HomluxPanelAssociateSceneEntitySceneList homluxPanelAssociateSceneEntitySceneList = HomluxPanelAssociateSceneEntitySceneList();
	final String? sceneIcon = homluxJsonConvert.convert<String>(json['sceneIcon']);
	if (sceneIcon != null) {
		homluxPanelAssociateSceneEntitySceneList.sceneIcon = sceneIcon;
	}
	final String? sceneId = homluxJsonConvert.convert<String>(json['sceneId']);
	if (sceneId != null) {
		homluxPanelAssociateSceneEntitySceneList.sceneId = sceneId;
	}
	final String? sceneName = homluxJsonConvert.convert<String>(json['sceneName']);
	if (sceneName != null) {
		homluxPanelAssociateSceneEntitySceneList.sceneName = sceneName;
	}
	return homluxPanelAssociateSceneEntitySceneList;
}

Map<String, dynamic> $HomluxPanelAssociateSceneEntitySceneListToJson(HomluxPanelAssociateSceneEntitySceneList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['sceneIcon'] = entity.sceneIcon;
	data['sceneId'] = entity.sceneId;
	data['sceneName'] = entity.sceneName;
	return data;
}