import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/weather7d_entity.g.dart';

@JsonSerializable()
class Weather7dEntity {
  Weather7dEntity();

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

  factory Weather7dEntity.fromJson(Map<String, dynamic> json) =>
      $Weather7dEntityFromJson(json);
  Map<String, dynamic> toJson() => $Weather7dEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
