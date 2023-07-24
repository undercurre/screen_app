// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meiju_scene_list_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeiJuSceneListEntity _$MeiJuSceneListEntityFromJson(Map<String, dynamic> json) {
      var entity = MeiJuSceneListEntity();
      entity.list = meijuJsonConvert.fromJsonAsT(json['list']);
      return entity;
}

Map<String, dynamic> _$MeiJuSceneListEntityToJson(
        MeiJuSceneListEntity instance) =>

    <String, dynamic>{
      'list': instance.list,
    };

MeiJuSceneEntity _$MeiJuSceneEntityFromJson(Map<String, dynamic> json) =>
    MeiJuSceneEntity(
      sceneId: json['sceneId'].toString() as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      sceneType: json['sceneType'] as int?,
      sceneStatus: json['sceneStatus'] as int?,
      location: json['location'] as String?,
      weather: json['weather'] as String?,
      enable: json['enable'].toString() as String?,
      triggerType: json['triggerType'] as String?,
      startTime: json['startTime'] as String?,
      weekly: json['weekly'] as String?,
      timeZone: json['timeZone'] as String?,
      templateCode: json['templateCode'] as String?,
      eventLogical: json['eventLogical'] as String?,
      airecommendId: json['airecommendId'] as String?,
      template: json['template'] as String?,
      pushType: json['pushType'] as int?,
      pushTitle: json['pushTitle'] as String?,
      pushContent: json['pushContent'] as String?,
      version: json['version'] as String?,
      cuid: json['cuid'].toString() as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );

Map<String, dynamic> _$MeiJuSceneEntityToJson(MeiJuSceneEntity instance) =>
    <String, dynamic>{
      'sceneId': instance.sceneId,
      'name': instance.name,
      'image': instance.image,
      'sceneType': instance.sceneType,
      'sceneStatus': instance.sceneStatus,
      'location': instance.location,
      'weather': instance.weather,
      'enable': instance.enable,
      'triggerType': instance.triggerType,
      'startTime': instance.startTime,
      'weekly': instance.weekly,
      'timeZone': instance.timeZone,
      'templateCode': instance.templateCode,
      'eventLogical': instance.eventLogical,
      'airecommendId': instance.airecommendId,
      'template': instance.template,
      'pushType': instance.pushType,
      'pushTitle': instance.pushTitle,
      'pushContent': instance.pushContent,
      'version': instance.version,
      'cuid': instance.cuid,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
    };
