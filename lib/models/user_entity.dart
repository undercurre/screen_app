import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/user_entity.g.dart';

@JsonSerializable()
class UserEntity {
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

  UserEntity();

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      $UserEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
