// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_refresh_token_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxRefreshTokenEntity _$HomluxRefreshTokenEntityFromJson(
        Map<String, dynamic> json) =>
    HomluxRefreshTokenEntity(
      refreshToken: json['refreshToken'] as String?,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$HomluxRefreshTokenEntityToJson(
        HomluxRefreshTokenEntity instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
      'token': instance.token,
    };
