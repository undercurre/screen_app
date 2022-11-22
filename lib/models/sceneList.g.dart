// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sceneList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SceneList _$SceneListFromJson(Map<String, dynamic> json) => SceneList()
  ..total = json['total'] as num
  ..list = (json['list'] as List<dynamic>)
      .map((e) => SceneInfo.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$SceneListToJson(SceneList instance) => <String, dynamic>{
      'total': instance.total,
      'list': instance.list,
    };
