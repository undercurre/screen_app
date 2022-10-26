import 'package:json_annotation/json_annotation.dart';

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
  late String roomCount;
  late String applianceCount;
  late String memberCount;
  String? members;
  late num unread;
  
  factory HomeList.fromJson(Map<String,dynamic> json) => _$HomeListFromJson(json);
  Map<String, dynamic> toJson() => _$HomeListToJson(this);
}
