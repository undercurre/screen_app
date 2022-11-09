// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weatherOfCity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherOfCity _$WeatherOfCityFromJson(Map<String, dynamic> json) =>
    WeatherOfCity()
      ..weather = Weather.fromJson(json['weather'] as Map<String, dynamic>)
      ..location = Location.fromJson(json['location'] as Map<String, dynamic>);

Map<String, dynamic> _$WeatherOfCityToJson(WeatherOfCity instance) =>
    <String, dynamic>{
      'weather': instance.weather,
      'location': instance.location,
    };
