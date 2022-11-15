// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather()
  ..wetness = json['wetness'] as String
  ..grade = json['grade'] as String
  ..windForce = json['windForce'] as String
  ..windDirection = json['windDirection'] as String
  ..weatherStatus = json['weatherStatus'] as String
  ..weatherCode = json['weatherCode'] as String
  ..precipitation = json['precipitation'] as String
  ..publicDate = json['publicDate'] as String
  ..date = json['date'] as String
  ..aqi = json['aqi'] as String
  ..pmindex = json['pmindex'] as String
  ..pmval = json['pmval'] as String;

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'wetness': instance.wetness,
      'grade': instance.grade,
      'windForce': instance.windForce,
      'windDirection': instance.windDirection,
      'weatherStatus': instance.weatherStatus,
      'weatherCode': instance.weatherCode,
      'precipitation': instance.precipitation,
      'publicDate': instance.publicDate,
      'date': instance.date,
      'aqi': instance.aqi,
      'pmindex': instance.pmindex,
      'pmval': instance.pmval,
    };
