import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_weather7d_entity.g.dart';

@JsonSerializable()
class MeiJuWeather7dEntity {
  MeiJuWeather7dEntity();

  late String date;
  late String dayWeatherStatus;
  late String sunrise;
  late String dayWindDirection;
  late String nightWindDirection;
  late String dayWindForce;
  late String sunset;
  late String nightWeatherStatus;
  late String nightLowGrade;
  late String nightWindForce;
  late String dayHighGrade;

  factory MeiJuWeather7dEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuWeather7dEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuWeather7dEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
