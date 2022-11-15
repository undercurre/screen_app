// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location()
  ..provinceName = json['provinceName'] as String
  ..cityName = json['cityName'] as String
  ..coordinate = json['coordinate'] as String
  ..fullName = json['fullName'] as String
  ..enName = json['enName'] as String
  ..chName = json['chName'] as String
  ..pyName = json['pyName'] as String
  ..cityNo = json['cityNo'] as String
  ..countryName = json['countryName'] as String;

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'provinceName': instance.provinceName,
      'cityName': instance.cityName,
      'coordinate': instance.coordinate,
      'fullName': instance.fullName,
      'enName': instance.enName,
      'chName': instance.chName,
      'pyName': instance.pyName,
      'cityNo': instance.cityNo,
      'countryName': instance.countryName,
    };
