import 'package:json_annotation/json_annotation.dart';

part 'homlux_family_entity.g.dart';

@JsonSerializable()
class HomluxFamilyEntity {
  final String houseId;
  final String houseName;
  final bool houseCreatorFlag;
  final bool defaultHouseFlag;

  const HomluxFamilyEntity({
    required this.houseId,
    required this.houseName,
    required this.houseCreatorFlag,
    required this.defaultHouseFlag,
  });

  factory HomluxFamilyEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxFamilyEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxFamilyEntityToJson(this);
}
