import 'package:json_annotation/json_annotation.dart';

part 'homlux_refresh_token_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class HomluxRefreshTokenEntity {
  final String? refreshToken;
  final String? token;

  const HomluxRefreshTokenEntity({
    this.refreshToken,
    this.token,
  });

  factory HomluxRefreshTokenEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxRefreshTokenEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxRefreshTokenEntityToJson(this);
}
