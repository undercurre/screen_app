import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/qr_code_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class QrCodeEntity {
  QrCodeEntity();

  late num checkType;
  late String deviceId;
  late num effectTimeSecond;
  late num expireTime;
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
