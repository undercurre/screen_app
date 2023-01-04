import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/profile_entity.g.dart';
import 'package:screen_app/models/user_entity.dart';
import 'package:screen_app/models/home_entity.dart';
import 'package:screen_app/models/room_entity.dart';

@JsonSerializable()
class ProfileEntity {
  ProfileEntity();

  UserEntity? user;
  HomeEntity? homeInfo;
  RoomEntity? roomInfo;
  String? deviceId;
  String? deviceSn;

  factory ProfileEntity.fromJson(Map<String, dynamic> json) =>
      $ProfileEntityFromJson(json);
  Map<String, dynamic> toJson() => $ProfileEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
