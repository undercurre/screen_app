// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessToken.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessToken _$AccessTokenFromJson(Map<String, dynamic> json) => AccessToken()
  ..accessToken = json['accessToken'] as String
  ..deviceId = json['deviceId'] as String
  ..iotUserId = json['iotUserId'] as String
  ..key = json['key'] as String
  ..openId = json['openId'] as String
  ..seed = json['seed'] as String
  ..sessionId = json['sessionId'] as String
  ..tokenPwd = json['tokenPwd'] as String
  ..uid = json['uid'] as String
  ..expired = json['expired'] as num?;

Map<String, dynamic> _$AccessTokenToJson(AccessToken instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'deviceId': instance.deviceId,
      'iotUserId': instance.iotUserId,
      'key': instance.key,
      'openId': instance.openId,
      'seed': instance.seed,
      'sessionId': instance.sessionId,
      'tokenPwd': instance.tokenPwd,
      'uid': instance.uid,
      'expired': instance.expired,
    };
