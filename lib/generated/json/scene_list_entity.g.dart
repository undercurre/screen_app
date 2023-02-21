import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/scene_list_entity.dart';
import 'package:screen_app/models/scene_info_entity.dart';


SceneListEntity $SceneListEntityFromJson(Map<String, dynamic> json) {
	final SceneListEntity sceneListEntity = SceneListEntity();
	final num? total = jsonConvert.convert<num>(json['total']);
	if (total != null) {
		sceneListEntity.total = total;
	}
	final List<SceneInfoEntity>? list = jsonConvert.convertListNotNull<SceneInfoEntity>(json['list']);
	if (list != null) {
		sceneListEntity.list = list;
	}
	return sceneListEntity;
}

Map<String, dynamic> $SceneListEntityToJson(SceneListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['total'] = entity.total;
	data['list'] =  entity.list.map((v) => v.toJson()).toList();
	return data;
}