import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'meiju_qr_code_entity.g.dart';

@JsonSerializable()
class MeiJuQrCodeEntity {
  MeiJuQrCodeEntity();

  int? checkType;
  String? deviceId;
  int? effectTimeSecond;
  int? expireTime;
  String? openId;
  String? sessionId;
  String? shortUrl;

  factory MeiJuQrCodeEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuQrCodeEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuQrCodeEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
