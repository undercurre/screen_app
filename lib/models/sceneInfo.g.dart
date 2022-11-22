// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sceneInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SceneInfo _$SceneInfoFromJson(Map<String, dynamic> json) => SceneInfo()
  ..appId = json['appId']
  ..image = json['image'] as String
  ..eventLogical = json['eventLogical'] as String
  ..updateTime = json['updateTime'] as String
  ..homegroupId = json['homegroupId'] as num
  ..version = json['version'] as String
  ..weekly = json['weekly'] as String
  ..sceneType = json['sceneType'] as num
  ..createTime = json['createTime'] as String
  ..enable = json['enable'] as num
  ..sceneId = json['sceneId'] as num
  ..name = json['name'] as String;

Map<String, dynamic> _$SceneInfoToJson(SceneInfo instance) => <String, dynamic>{
      'appId': instance.appId,
      'image': instance.image,
      'eventLogical': instance.eventLogical,
      'updateTime': instance.updateTime,
      'homegroupId': instance.homegroupId,
      'version': instance.version,
      'weekly': instance.weekly,
      'sceneType': instance.sceneType,
      'createTime': instance.createTime,
      'enable': instance.enable,
      'sceneId': instance.sceneId,
      'name': instance.name,
    };
