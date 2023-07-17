// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_qr_code_auth_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxQrCodeAuthEntity _$HomluxQrCodeAuthEntityFromJson(
        Map<String, dynamic> json) =>
    HomluxQrCodeAuthEntity(
      authorizeStatus: json['authorizeStatus'] as int?,
      refreshToken: json['refreshToken'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$HomluxQrCodeAuthEntityToJson(
        HomluxQrCodeAuthEntity instance) =>
    <String, dynamic>{
      'authorizeStatus': instance.authorizeStatus,
      'refreshToken': instance.refreshToken,
      'token': instance.token,
    };
