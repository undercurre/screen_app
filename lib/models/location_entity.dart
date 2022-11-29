import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/location_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class LocationEntity {
  LocationEntity();

  late String provinceName;
  late String cityName;
  late String coordinate;
  late String fullName;
  late String enName;
  late String chName;
  late String pyName;
  late String cityNo;
  late String countryName;

  factory LocationEntity.fromJson(Map<String, dynamic> json) =>
      $LocationEntityFromJson(json);
  Map<String, dynamic> toJson() => $LocationEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
