// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roomInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomInfo _$RoomInfoFromJson(Map<String, dynamic> json) => RoomInfo()
  ..roomId = json['roomId'] as String
  ..name = json['name'] as String
  ..des = json['des'] as String
  ..icon = json['icon'] as String
  ..isDefault = json['isDefault'] as String;

Map<String, dynamic> _$RoomInfoToJson(RoomInfo instance) => <String, dynamic>{
      'roomId': instance.roomId,
      'name': instance.name,
      'des': instance.des,
      'icon': instance.icon,
      'isDefault': instance.isDefault,
    };
