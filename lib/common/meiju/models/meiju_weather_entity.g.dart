// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meiju_weather_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeiJuWeatherEntity _$MeiJuWeatherEntityFromJson(Map<String, dynamic> json) =>
    MeiJuWeatherEntity(
      weather: json['weather'] == null
          ? null
          : MeiJuWeather.fromJson(json['weather'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : MeiJuLocation.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeiJuWeatherEntityToJson(MeiJuWeatherEntity instance) =>
    <String, dynamic>{
      'weather': instance.weather?.toJson(),
      'location': instance.location?.toJson(),
    };

MeiJuWeather _$WeatherFromJson(Map<String, dynamic> json) => MeiJuWeather(
      wetness: json['wetness'] as String?,
      grade: json['grade'] as String?,
      windForce: json['windForce'] as String?,
      windDirection: json['windDirection'] as String?,
      weatherStatus: json['weatherStatus'] as String?,
      weatherCode: json['weatherCode'] as String?,
      precipitation: json['precipitation'] as String?,
      publicDate: json['publicDate'] as String?,
      aqi: json['aqi'] as String?,
      pmindex: json['pmindex'] as String?,
      pmval: json['pmval'] as String?,
    );

Map<String, dynamic> _$WeatherToJson(MeiJuWeather instance) => <String, dynamic>{
      'wetness': instance.wetness,
      'grade': instance.grade,
      'windForce': instance.windForce,
      'windDirection': instance.windDirection,
      'weatherStatus': instance.weatherStatus,
      'weatherCode': instance.weatherCode,
      'precipitation': instance.precipitation,
      'publicDate': instance.publicDate,
      'aqi': instance.aqi,
      'pmindex': instance.pmindex,
      'pmval': instance.pmval,
    };

MeiJuLocation _$LocationFromJson(Map<String, dynamic> json) => MeiJuLocation(
      provinceName: json['provinceName'] as String?,
      cityName: json['cityName'] as String?,
      coordinate: json['coordinate'] as String?,
      adCode: json['adCode'] as String?,
      fullName: json['fullName'] as String?,
      enName: json['enName'] as String?,
      chName: json['chName'] as String?,
      pyName: json['pyName'] as String?,
      cityNo: json['cityNo'] as String?,
      countryName: json['countryName'] as String?,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$LocationToJson(MeiJuLocation instance) => <String, dynamic>{
      'provinceName': instance.provinceName,
      'cityName': instance.cityName,
      'coordinate': instance.coordinate,
      'adCode': instance.adCode,
      'fullName': instance.fullName,
      'enName': instance.enName,
      'chName': instance.chName,
      'pyName': instance.pyName,
      'cityNo': instance.cityNo,
      'countryName': instance.countryName,
      'version': instance.version,
    };
