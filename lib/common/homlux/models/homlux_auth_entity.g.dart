// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_auth_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxAuthEntity _$HomluxAuthEntityFromJson(Map<String, dynamic> json) {
  var entity = HomluxAuthEntity();
  entity.houseUserAuth = json['houseUserAuth'] as int?;
  entity.houseUserAuth = homluxJsonConvert.convert<int?>(json['houseUserAuth']);
  return entity;
}


Map<String, dynamic> _$HomluxAuthEntityToJson(HomluxAuthEntity instance) =>
    <String, dynamic>{
      'houseUserAuth': instance.houseUserAuth,
    };
