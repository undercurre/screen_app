part of 'homlux_user_info_entity.dart';

HomluxUserInfoEntity _$HomluxUserInfoEntityFromJson(Map<String, dynamic> json) {
  HomluxUserInfoEntity entity = HomluxUserInfoEntity(
    headImageUrl: json['headImageUrl'],
    mobilePhone: json['mobilePhone'],
    name: json['name'],
    nickName: json['nickName'],
    sex: json['sex'],
    userId: json['userId'],
    wxId: json['wxId'],
  );
  return entity;
}

Map<String, dynamic> _$HomluxUserInfoEntityToJson(HomluxUserInfoEntity entity) {
  return {
    'headImageUrl': entity.headImageUrl,
    'mobilePhone': entity.mobilePhone,
    'name': entity.name,
    'nickName': entity.nickName,
    'sex': entity.sex,
    'userId': entity.userId,
    'wxId': entity.wxId,
  };
}
