import 'dart:convert';

import 'homlux_panel_associate_scene_entity.g.dart';

class HomluxPanelAssociateSceneEntity {
	String? deviceId;
	String? modelName;
	List<HomluxPanelAssociateSceneEntitySceneList>? sceneList;

	HomluxPanelAssociateSceneEntity();

	factory HomluxPanelAssociateSceneEntity.fromJson(Map<String, dynamic> json) => $HomluxPanelAssociateSceneEntityEntityFromJson(json);

	Map<String, dynamic> toJson() => $HomluxPanelAssociateSceneEntityEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(toJson());
	}
}

class HomluxPanelAssociateSceneEntitySceneList {
	String? sceneIcon;
	String? sceneId;
	String? sceneName;

	HomluxPanelAssociateSceneEntitySceneList();

	factory HomluxPanelAssociateSceneEntitySceneList.fromJson(Map<String, dynamic> json) => $HomluxPanelAssociateSceneEntitySceneListFromJson(json);

	Map<String, dynamic> toJson() => $HomluxPanelAssociateSceneEntitySceneListToJson(this);

	@override
	String toString() {
		return jsonEncode(toJson());
	}

}