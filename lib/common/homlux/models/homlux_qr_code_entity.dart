import 'package:json_annotation/json_annotation.dart';

part 'homlux_qr_code_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class HomluxQrCodeEntity {
  final String? qrcode;

  const HomluxQrCodeEntity({
    this.qrcode,
  });

  factory HomluxQrCodeEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxQrCodeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxQrCodeEntityToJson(this);
}
