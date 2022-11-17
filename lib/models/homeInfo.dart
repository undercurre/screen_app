import 'package:json_annotation/json_annotation.dart';
import "roomInfo.dart";
part 'homeInfo.g.dart';

@JsonSerializable()
class HomeInfo {
  HomeInfo();

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
  late String areaid;
  late String createTime;
  late String createUserUid;
  String? roomCount;
  String? applianceCount;
  String? memberCount;
  String? members;
  List<RoomInfo>? roomList;
  num? unread;
  
  factory HomeInfo.fromJson(Map<String,dynamic> json) => _$HomeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$HomeInfoToJson(this);
}
