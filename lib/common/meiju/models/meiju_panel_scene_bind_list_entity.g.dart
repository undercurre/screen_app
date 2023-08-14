part of 'meiju_panel_scene_bind_list_entity.dart';

MeiJuPanelSceneBindItemEntity _$MeiJuPanelSceneBindItemFromJson(Map<String, dynamic> json) {
  final MeiJuPanelSceneBindItemEntity deviceEntity = MeiJuPanelSceneBindItemEntity();
  final int? sceneId = meijuJsonConvert.convert<int>(json['sceneId']);
  if (sceneId != null) {
    deviceEntity.sceneId = sceneId;
  }

  final int? applianceCode = meijuJsonConvert.convert<int>(json['applianceCode']);
  if (applianceCode != null) {
    deviceEntity.applianceCode = applianceCode;
  }

  final int? endpoint = meijuJsonConvert.convert<int>(json['endpoint']);
  if (endpoint != null) {
    deviceEntity.endpoint = endpoint;
  }

  return deviceEntity;
}

Map<String, dynamic> _$MeiJuPanelSceneBindItemToJson(MeiJuPanelSceneBindItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['sceneId'] = entity.sceneId;
  data['applianceCode'] = entity.applianceCode;
  data['endpoint'] = entity.endpoint;
  return data;
}


MeiJuPanelSceneBindListEntity _$MeiJuPanelSceneBindListFromJson(Map<String, dynamic> json) {
  final MeiJuPanelSceneBindListEntity deviceEntity = MeiJuPanelSceneBindListEntity();
  final List<MeiJuPanelSceneBindItemEntity>? items = meijuJsonConvert.convertListNotNull<MeiJuPanelSceneBindItemEntity>(json['list']);
  if (items != null) {
    deviceEntity.list = items;
  }

  return deviceEntity;
}

Map<String, dynamic> _$MeiJuPanelSceneBindListToJson(MeiJuPanelSceneBindListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list?.map((e) => e.toJson()).toList();
  return data;
}