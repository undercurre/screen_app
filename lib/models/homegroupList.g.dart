// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homegroupList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomegroupList _$HomegroupListFromJson(Map<String, dynamic> json) =>
    HomegroupList()
      ..homeList = (json['homeList'] as List<dynamic>)
          .map((e) => HomeInfo.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$HomegroupListToJson(HomegroupList instance) =>
    <String, dynamic>{
      'homeList': instance.homeList,
    };
