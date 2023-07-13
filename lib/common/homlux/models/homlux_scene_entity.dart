import 'package:json_annotation/json_annotation.dart';

part 'homlux_scene_entity.g.dart';

@JsonSerializable()
class HomluxSceneEntity {
  final String? conditionType;
  final String? defaultType;
  final List<DeviceActions>? deviceActions;
  final List<DeviceConditions>? deviceConditions;
  final String? houseId;
  final String? isDefault;
  final int? orderNum;
  final String? roomId;
  final String? sceneIcon;
  final String? sceneId;
  final String? sceneName;

  const HomluxSceneEntity({
    this.conditionType,
    this.defaultType,
    this.deviceActions,
    this.deviceConditions,
    this.houseId,
    this.isDefault,
    this.orderNum,
    this.roomId,
    this.sceneIcon,
    this.sceneId,
    this.sceneName,
  });

  factory HomluxSceneEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxSceneEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxSceneEntityToJson(this);
}

@JsonSerializable()
class DeviceActions {
  final List<dynamic>? controlAction;
  final String? deviceId;
  final String? deviceName;
  final String? devicePic;
  final String? deviceType;
  final String? proType;
  final int? successType;

  const DeviceActions({
    this.controlAction,
    this.deviceId,
    this.deviceName,
    this.devicePic,
    this.deviceType,
    this.proType,
    this.successType,
  });

  factory DeviceActions.fromJson(Map<String, dynamic> json) =>
      _$DeviceActionsFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceActionsToJson(this);
}

@JsonSerializable()
class DeviceConditions {
  final List<dynamic>? controlEvent;
  final String? deviceId;
  final String? deviceName;
  final String? devicePic;
  final String? deviceType;
  final String? proType;

  const DeviceConditions({
    this.controlEvent,
    this.deviceId,
    this.deviceName,
    this.devicePic,
    this.deviceType,
    this.proType,
  });

  factory DeviceConditions.fromJson(Map<String, dynamic> json) =>
      _$DeviceConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceConditionsToJson(this);
}
