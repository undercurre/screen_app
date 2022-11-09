import 'package:json_annotation/json_annotation.dart';
import "weather.dart";
import "location.dart";
part 'weatherOfCity.g.dart';

@JsonSerializable()
class WeatherOfCity {
  WeatherOfCity();

  late Weather weather;
  late Location location;
  
  factory WeatherOfCity.fromJson(Map<String,dynamic> json) => _$WeatherOfCityFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherOfCityToJson(this);
}
