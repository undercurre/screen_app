import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/models/home_entity.dart';
import 'package:screen_app/generated/json/home_list_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class HomeListEntity {
  HomeListEntity();

  late List<HomeEntity> homeList;

  factory HomeListEntity.fromJson(Map<String, dynamic> json) =>
      $HomeListEntityFromJson(json);
  Map<String, dynamic> toJson() => $HomeListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
