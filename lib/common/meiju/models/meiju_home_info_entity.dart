import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_home_info_entity.g.dart';
import 'meiju_room_entity.dart';

@JsonSerializable()
class MeiJuHomeInfoEntity {
  late String homegroupId;
  String? number;
  String? roleId;
  String? isDefault;
  String? name;
  String? nickname;
  String? des;
  String? address;
  String? profilePicUrl;
  String? coordinate;

  @JSONField(name: "areaid")
  String? areaId;
  String? createTime;
  String? createUserUid;
  String? roomCount;
  String? applianceCount;
  String? memberCount;
  dynamic members;
  int? unread;
  List<MeiJuRoomEntity>? roomList;

  MeiJuHomeInfoEntity();

  factory MeiJuHomeInfoEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuHomeInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuHomeInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
