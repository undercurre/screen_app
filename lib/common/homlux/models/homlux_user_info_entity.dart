part 'homlux_user_info_entity.g.dart';

class HomluxUserInfoEntity {

  final String? headImageUrl;
  final String? mobilePhone;
  final String? name;
  final String? nickName;
  final int? sex;
  final String? userId;
  final String? wxId;

  const HomluxUserInfoEntity({
    this.headImageUrl,
    this.mobilePhone,
    this.name,
    this.nickName,
    this.sex,
    this.userId,
    this.wxId,
  });

  factory HomluxUserInfoEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxUserInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxUserInfoEntityToJson(this);

}