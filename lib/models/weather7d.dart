import 'package:json_annotation/json_annotation.dart';

part 'weather7d.g.dart';

@JsonSerializable()
class Weather7d {
  Weather7d();

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
  
  factory Weather7d.fromJson(Map<String,dynamic> json) => _$Weather7dFromJson(json);
  Map<String, dynamic> toJson() => _$Weather7dToJson(this);
}
