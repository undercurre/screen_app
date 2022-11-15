import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  Location();

  late String provinceName;
  late String cityName;
  late String coordinate;
  late String fullName;
  late String enName;
  late String chName;
  late String pyName;
  late String cityNo;
  late String countryName;
  
  factory Location.fromJson(Map<String,dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
