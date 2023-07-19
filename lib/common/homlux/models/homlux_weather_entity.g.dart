// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_weather_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxWeatherEntity _$HomluxWeatherEntityFromJson(Map<String, dynamic> json) =>
    HomluxWeatherEntity(
      condition: json['condition'] as String?,
      icon: json['icon'] as String?,
      locationName: json['locationName'] as String?,
      temperature: json['temperature'] as String?,
    );

Map<String, dynamic> _$HomluxWeatherEntityToJson(
        HomluxWeatherEntity instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'icon': instance.icon,
      'locationName': instance.locationName,
      'temperature': instance.temperature,
    };
