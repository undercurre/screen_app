import 'package:json_annotation/json_annotation.dart';

part 'homlux_user_config_info.g.dart';

@JsonSerializable()
class HomluxUserConfigInfo {
  final String? businessValue;

  const HomluxUserConfigInfo({
    this.businessValue,
  });

  factory HomluxUserConfigInfo.fromJson(Map<String, dynamic> json) =>
      _$HomluxUserConfigInfoFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxUserConfigInfoToJson(this);
}
