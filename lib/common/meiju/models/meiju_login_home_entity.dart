import 'dart:convert';

import 'package:screen_app/models/room_entity.dart';

import '../generated/json/base/meiju_json_convert_content.dart';

part 'meiju_login_home_entity.g.dart';

class MeiJuLoginHomeEntity {
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
  String? areaId;
  String? createTime;
  String? createUserUid;
  String? roomCount;
  String? applianceCount;
  String? memberCount;
  dynamic members;
  int unread=1;
  List<RoomEntity>? roomList;

  MeiJuLoginHomeEntity();

  factory MeiJuLoginHomeEntity.fromJson(Map<String, dynamic> json) =>
      _$MeiJuLoginHomeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MeiJuLoginHomeEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

}
