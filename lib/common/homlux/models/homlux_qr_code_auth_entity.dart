import 'package:json_annotation/json_annotation.dart';

part 'homlux_qr_code_auth_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class HomluxQrCodeAuthEntity {
  final int? authorizeStatus;
  final String? refreshToken;
  final String? token;

  const HomluxQrCodeAuthEntity({
    this.authorizeStatus,
    this.refreshToken,
    this.token,
  });

  factory HomluxQrCodeAuthEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxQrCodeAuthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxQrCodeAuthEntityToJson(this);
}
