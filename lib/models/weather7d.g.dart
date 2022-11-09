// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather7d.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather7d _$Weather7dFromJson(Map<String, dynamic> json) => Weather7d()
  ..date = json['date'] as String
  ..dayWeatherStatus = json['dayWeatherStatus'] as String
  ..sunrise = json['sunrise'] as String
  ..dayWindDirection = json['dayWindDirection'] as String
  ..nightWindDirection = json['nightWindDirection'] as String
  ..dayWindForce = json['dayWindForce'] as String
  ..sunset = json['sunset'] as String
  ..nightWeatherStatus = json['nightWeatherStatus'] as String
  ..nightLowGrade = json['nightLowGrade'] as String
  ..nightWindForce = json['nightWindForce'] as String
  ..dayHighGrade = json['dayHighGrade'] as String;

Map<String, dynamic> _$Weather7dToJson(Weather7d instance) => <String, dynamic>{
      'date': instance.date,
      'dayWeatherStatus': instance.dayWeatherStatus,
      'sunrise': instance.sunrise,
      'dayWindDirection': instance.dayWindDirection,
      'nightWindDirection': instance.nightWindDirection,
      'dayWindForce': instance.dayWindForce,
      'sunset': instance.sunset,
      'nightWeatherStatus': instance.nightWeatherStatus,
      'nightLowGrade': instance.nightLowGrade,
      'nightWindForce': instance.nightWindForce,
      'dayHighGrade': instance.dayHighGrade,
    };
