import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/weather_of_city_entity.g.dart';
import 'package:screen_app/models/location_entity.dart';
import 'package:screen_app/models/weather_entity.dart';

@JsonSerializable()
class WeatherOfCityEntity {
  WeatherOfCityEntity();

  late WeatherEntity weather;
  late LocationEntity location;

  factory WeatherOfCityEntity.fromJson(Map<String, dynamic> json) =>
      $WeatherOfCityEntityFromJson(json);
  Map<String, dynamic> toJson() => $WeatherOfCityEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
