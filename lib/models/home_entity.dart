import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/home_entity.g.dart';
import 'package:screen_app/models/room_entity.dart';

@JsonSerializable()
class HomeEntity {
  late String homegroupId;
  late String number;
  late String roleId;
  late String isDefault;
  late String name;
  late String nickname;
  late String des;
  late String address;
  late String profilePicUrl;
  late String coordinate;

  @JSONField(name: "areaid")
  late String areaId;
  late String createTime;
  late String createUserUid;
  late String roomCount;
  late String applianceCount;
  late String memberCount;
  dynamic members;
  late int unread;
  List<RoomEntity>? roomList;

  HomeEntity();

  factory HomeEntity.fromJson(Map<String, dynamic> json) =>
      $HomeEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomeEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
