import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';

part 'meiju_scene_list_entity.g.dart';

class MeiJuSceneListEntity {
  List<MeiJuSceneEntity>? list;

  MeiJuSceneListEntity();

  factory MeiJuSceneListEntity.fromJson(Map<String, dynamic> json) =>
      _$MeiJuSceneListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuSceneListEntityToJson(this);
}

class MeiJuSceneEntity {
  final String? sceneId;
  final String? name;
  final String? image;
  final int? sceneType;
  final int? sceneStatus;
  final String? location;
  final String? weather;
  final String? enable;
  final String? triggerType;

  final String? startTime;
  final String? weekly;
  final String? timeZone;
  final String? templateCode;
  final String? eventLogical;
  final String? airecommendId;
  final String? template;
  final int? pushType;
  final String? pushTitle;
  final String? pushContent;
  final String? version;
  final String? cuid;
  final String? createTime;
  final String? updateTime;

  const MeiJuSceneEntity({
    this.sceneId,
    this.name,
    this.image,
    this.sceneType,
    this.sceneStatus,
    this.location,
    this.weather,
    this.enable,
    this.triggerType,
    this.startTime,
    this.weekly,
    this.timeZone,
    this.templateCode,
    this.eventLogical,
    this.airecommendId,
    this.template,
    this.pushType,
    this.pushTitle,
    this.pushContent,
    this.version,
    this.cuid,
    this.createTime,
    this.updateTime,
  });

  factory MeiJuSceneEntity.fromJson(Map<String, dynamic> json) =>
      _$MeiJuSceneEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuSceneEntityToJson(this);
}
