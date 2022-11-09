// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User()
  ..accessToken = json['accessToken'] as String
  ..deviceId = json['deviceId'] as String
  ..iotUserId = json['iotUserId'] as String
  ..key = json['key'] as String
  ..openId = json['openId'] as String
  ..seed = json['seed'] as String
  ..sessionId = json['sessionId'] as String
  ..tokenPwd = json['tokenPwd'] as String
  ..uid = json['uid'] as String
  ..expired = json['expired'] as num?
  ..mzAccessToken = json['mzAccessToken'] as String?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
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
      'mzAccessToken': instance.mzAccessToken,
    };
