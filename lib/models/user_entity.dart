import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/user_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class UserEntity {
  String? accessToken;
  String? deviceId;
  String? iotUserId;
  String? key;
  String? openId;
  String? seed;
  String? sessionId;
  String? tokenPwd;
  String? uid;
  String? mzAccessToken;
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
