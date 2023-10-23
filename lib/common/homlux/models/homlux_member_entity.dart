import 'package:json_annotation/json_annotation.dart';

part 'homlux_member_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class HomluxMemberListEntity {
  final int? totalElements;
  final List<HouseUserList>? houseUserList;

  const HomluxMemberListEntity({
    this.totalElements,
    this.houseUserList,
  });

  factory HomluxMemberListEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxMemberEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxMemberEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HouseUserList {
  final String? userId;
  final String? userName;
  final int? userHouseAuth;
  final String? userHouseAuthName;
  final String? headImageUrl;

  const HouseUserList({
    this.userId,
    this.userName,
    this.userHouseAuth,
    this.userHouseAuthName,
    this.headImageUrl,
  });

  factory HouseUserList.fromJson(Map<String, dynamic> json) =>
      _$HouseUserListFromJson(json);

  Map<String, dynamic> toJson() => _$HouseUserListToJson(this);
}
