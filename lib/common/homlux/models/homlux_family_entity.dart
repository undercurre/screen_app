import 'package:json_annotation/json_annotation.dart';

part 'homlux_family_entity.g.dart';

@JsonSerializable()
class HomluxFamilyEntity {
  final String houseId;
  final String houseName;
  final bool houseCreatorFlag;
  final bool defaultHouseFlag;
  final int roomNum;
  final int deviceNum;
  final int userNum;

  const HomluxFamilyEntity({
    required this.houseId,
    required this.houseName,
    required this.houseCreatorFlag,
    required this.defaultHouseFlag,
    required this.roomNum,
    required this.deviceNum,
    required this.userNum,
  });

  factory HomluxFamilyEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxFamilyEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxFamilyEntityToJson(this);
}
