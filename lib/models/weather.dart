import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather {
  Weather();

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
  
  factory Weather.fromJson(Map<String,dynamic> json) => _$WeatherFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}
