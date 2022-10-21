// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qrCode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrCode _$QrCodeFromJson(Map<String, dynamic> json) => QrCode()
  ..checkType = json['checkType'] as num
  ..deviceId = json['deviceId'] as String
  ..effectTimeSecond = json['effectTimeSecond'] as num
  ..expireTime = json['expireTime'] as num
  ..openId = json['openId'] as String
  ..sessionId = json['sessionId'] as String
  ..shortUrl = json['shortUrl'] as String;

Map<String, dynamic> _$QrCodeToJson(QrCode instance) => <String, dynamic>{
      'checkType': instance.checkType,
      'deviceId': instance.deviceId,
      'effectTimeSecond': instance.effectTimeSecond,
      'expireTime': instance.expireTime,
      'openId': instance.openId,
      'sessionId': instance.sessionId,
      'shortUrl': instance.shortUrl,
    };
