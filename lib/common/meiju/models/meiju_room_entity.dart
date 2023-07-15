import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/models/device_entity.dart';

import 'meiju_room_entity.g.dart';

@JsonSerializable()
class MeiJuRoomEntity {
  MeiJuRoomEntity();

  String? roomId;
  String? id;
  String? name;
  String? des;
  String? icon;
  String? isDefault;
  List<DeviceEntity>? applianceList;

  factory MeiJuRoomEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuRoomEntityFromJson(json);
  Map<String, dynamic> toJson() => $MeiJuRoomEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
