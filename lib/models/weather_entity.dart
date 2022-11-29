import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/weather_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class WeatherEntity {
  WeatherEntity();

  late String wetness;
  late String grade;
  late String windForce;
  late String windDirection;
  late String weatherStatus;
  late String weatherCode;
  late String precipitation;
  late String publicDate;
  late String date;
  late String aqi;
  late String pmindex;
  late String pmval;

  factory WeatherEntity.fromJson(Map<String, dynamic> json) =>
      $WeatherEntityFromJson(json);
  Map<String, dynamic> toJson() => $WeatherEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
