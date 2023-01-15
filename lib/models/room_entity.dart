import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/room_entity.g.dart';
import 'package:screen_app/models/device_entity.dart';

@JsonSerializable()
class RoomEntity {
  RoomEntity();

  String? roomId;
  String? id;
  late String name;
  late String des;
  late String icon;
  late String isDefault;
  late List<DeviceEntity> applianceList;

  factory RoomEntity.fromJson(Map<String, dynamic> json) =>
      $RoomEntityFromJson(json);
  Map<String, dynamic> toJson() => $RoomEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
