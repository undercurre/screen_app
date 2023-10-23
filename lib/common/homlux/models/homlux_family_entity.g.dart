// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_family_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxFamilyEntity _$HomluxFamilyEntityFromJson(Map<String, dynamic> json) =>
    HomluxFamilyEntity(
      houseId: json['houseId'] as String,
      houseName: json['houseName'] as String,
      houseCreatorFlag: json['houseCreatorFlag'] as bool,
      defaultHouseFlag: json['defaultHouseFlag'] as bool,
      roomNum: json['roomNum'] as int,
      deviceNum: json['deviceNum'] as int,
      userNum: json['userNum'] as int,
    );

Map<String, dynamic> _$HomluxFamilyEntityToJson(HomluxFamilyEntity instance) =>
    <String, dynamic>{
      'houseId': instance.houseId,
      'houseName': instance.houseName,
      'houseCreatorFlag': instance.houseCreatorFlag,
      'defaultHouseFlag': instance.defaultHouseFlag,
      'roomNum': instance.roomNum,
      'deviceNum': instance.deviceNum,
      'userNum': instance.userNum,
    };
