import 'package:json_annotation/json_annotation.dart';
import "roomInfo.dart";
part 'homeList.g.dart';

@JsonSerializable()
class HomeList {
  HomeList();

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
  
  factory HomeList.fromJson(Map<String,dynamic> json) => _$HomeListFromJson(json);
  Map<String, dynamic> toJson() => _$HomeListToJson(this);
}
