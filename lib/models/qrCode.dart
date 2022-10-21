import 'package:json_annotation/json_annotation.dart';

part 'qrCode.g.dart';

@JsonSerializable()
class QrCode {
  QrCode();

  late num checkType;
  late String deviceId;
  late num effectTimeSecond;
  late num expireTime;
  late String openId;
  late String sessionId;
  late String shortUrl;
  
  factory QrCode.fromJson(Map<String,dynamic> json) => _$QrCodeFromJson(json);
  Map<String, dynamic> toJson() => _$QrCodeToJson(this);
}
