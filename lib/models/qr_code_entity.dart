import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/qr_code_entity.g.dart';

@JsonSerializable()
class QrCodeEntity {
  QrCodeEntity();

  late int checkType;
  late String deviceId;
  late int effectTimeSecond;
  late int expireTime;
  late String openId;
  late String sessionId;
  late String shortUrl;

  factory QrCodeEntity.fromJson(Map<String, dynamic> json) =>
      $QrCodeEntityFromJson(json);
  Map<String, dynamic> toJson() => $QrCodeEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
