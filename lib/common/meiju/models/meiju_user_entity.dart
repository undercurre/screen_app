import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_user_entity.g.dart';

@JsonSerializable()
class MeiJuTokenEntity {
  // 此三个参数用户自动登录
  // deviceId、tokenPwd、uid

  late String accessToken;
  late String deviceId;
  late String iotUserId;
  late String key;
  late String openId;
  late String seed;
  late String sessionId;
  late String tokenPwd;
  late String uid;
  String? mzAccessToken; // 美智登录token
  int? expired;
  int? pwdExpired;

  MeiJuTokenEntity();

  factory MeiJuTokenEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuTokenEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuTokenEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}
