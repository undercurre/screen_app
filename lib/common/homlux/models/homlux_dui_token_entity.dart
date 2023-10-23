import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/common/homlux/models/homlux_dui_token_entity.g.dart';
import 'dart:convert';

class HomluxDuiTokenEntity {
  int? refreshTokenExpireTime;
  int? accessTokenExpireTime;
  String? accessToken;
  String? refreshToken;

  HomluxDuiTokenEntity();

  factory HomluxDuiTokenEntity.fromJson(Map<String, dynamic> json) => $HomluxDuiTokenEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDuiTokenEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
