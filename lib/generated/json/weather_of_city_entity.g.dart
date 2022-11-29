import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/weather_of_city_entity.dart';
import 'package:screen_app/models/weather_entity.dart';

import 'package:screen_app/models/location_entity.dart';

WeatherOfCityEntity $WeatherOfCityEntityFromJson(Map<String, dynamic> json) {
  final WeatherOfCityEntity weatherOfCityEntity = WeatherOfCityEntity();
  final WeatherEntity? weather =
      jsonConvert.convert<WeatherEntity>(json['weather']);
  if (weather != null) {
    weatherOfCityEntity.weather = weather;
  }
  final LocationEntity? location =
      jsonConvert.convert<LocationEntity>(json['location']);
  if (location != null) {
    weatherOfCityEntity.location = location;
  }
  return weatherOfCityEntity;
}

Map<String, dynamic> $WeatherOfCityEntityToJson(WeatherOfCityEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['weather'] = entity.weather.toJson();
  data['location'] = entity.location.toJson();
  return data;
}
