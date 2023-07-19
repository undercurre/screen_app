import 'package:json_annotation/json_annotation.dart';

part 'meiju_weather_entity.g.dart';

class MeiJuWeatherEntity {
  final Weather? weather;
  final Location? location;

  const MeiJuWeatherEntity({
    this.weather,
    this.location,
  });

  factory MeiJuWeatherEntity.fromJson(Map<String, dynamic> json) =>
      _$MeiJuWeatherEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuWeatherEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Weather {
  final String? wetness;
  final String? grade;
  final String? windForce;
  final String? windDirection;
  final String? weatherStatus;
  final String? weatherCode;
  final String? precipitation;
  final String? publicDate;
  final String? aqi;
  final String? pmindex;
  final String? pmval;

  const Weather({
    this.wetness,
    this.grade,
    this.windForce,
    this.windDirection,
    this.weatherStatus,
    this.weatherCode,
    this.precipitation,
    this.publicDate,
    this.aqi,
    this.pmindex,
    this.pmval,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Location {
  final String? provinceName;
  final String? cityName;
  final String? coordinate;
  final String? adCode;
  final String? fullName;
  final String? enName;
  final String? chName;
  final String? pyName;
  final String? cityNo;
  final String? countryName;
  final String? version;

  const Location({
    this.provinceName,
    this.cityName,
    this.coordinate,
    this.adCode,
    this.fullName,
    this.enName,
    this.chName,
    this.pyName,
    this.cityNo,
    this.countryName,
    this.version,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
