
import '../generated/json/base/meiju_json_convert_content.dart';

part 'meiju_panel_scene_bind_list_entity.g.dart';

class MeiJuPanelSceneBindListEntity {
  MeiJuPanelSceneBindListEntity();

  List<MeiJuPanelSceneBindItemEntity>? list;

  factory MeiJuPanelSceneBindListEntity.fromJson(Map<String, dynamic> json) => _$MeiJuPanelSceneBindListFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuPanelSceneBindListToJson(this);
}

class MeiJuPanelSceneBindItemEntity {
  MeiJuPanelSceneBindItemEntity();
  int? sceneId;
  int? applianceCode;
  int? endpoint;

  factory MeiJuPanelSceneBindItemEntity.fromJson(Map<String, dynamic> json) => _$MeiJuPanelSceneBindItemFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuPanelSceneBindItemToJson(this);
}