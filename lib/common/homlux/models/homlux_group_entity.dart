import 'package:json_annotation/json_annotation.dart';

part 'homlux_group_entity.g.dart';

@JsonSerializable()
class HomluxGroupEntity {
  final String? groupName;
  final String? groupPic;
  final String? groupId;
  final String? roomName;
  final String? roomId;
  final int? deviceType;
  final String? proType;
  final int? orderNum;
  final List<GroupDeviceList>? groupDeviceList;
  final List<ControlAction>? controlAction;
  final ColorTempRangeMap? colorTempRangeMap;
  final int? onLineStatus;
  final String? houseId;
  final int? updateStamp;

  const HomluxGroupEntity({
    this.groupName,
    this.groupPic,
    this.groupId,
    this.roomName,
    this.roomId,
    this.deviceType,
    this.proType,
    this.orderNum,
    this.groupDeviceList,
    this.controlAction,
    this.colorTempRangeMap,
    this.onLineStatus,
    this.houseId,
    this.updateStamp
  });

  factory HomluxGroupEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxGroupEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxGroupEntityToJson(this);
}

@JsonSerializable()
class GroupDeviceList {
  final String? deviceId;
  final String? deviceName;
  final String? devicePic;
  final int? deviceType;
  final String? proType;
  final int? onLineStatus;

  const GroupDeviceList({
    this.deviceId,
    this.deviceName,
    this.devicePic,
    this.deviceType,
    this.proType,
    this.onLineStatus,
  });

  factory GroupDeviceList.fromJson(Map<String, dynamic> json) =>
      _$GroupDeviceListFromJson(json);

  Map<String, dynamic> toJson() => _$GroupDeviceListToJson(this);
}

@JsonSerializable()
class ControlAction {
  final int? power;
  final int? brightness;
  final int? colorTemperature;

  const ControlAction({
    this.power,
    this.brightness,
    this.colorTemperature,
  });

  factory ControlAction.fromJson(Map<String, dynamic> json) =>
      _$ControlActionFromJson(json);

  Map<String, dynamic> toJson() => _$ControlActionToJson(this);
}

@JsonSerializable()
class ColorTempRangeMap {
  final int? minColorTemp;
  final int? maxColorTemp;

  const ColorTempRangeMap({
    this.minColorTemp,
    this.maxColorTemp,
  });

  factory ColorTempRangeMap.fromJson(Map<String, dynamic> json) =>
      _$ColorTempRangeMapFromJson(json);

  Map<String, dynamic> toJson() => _$ColorTempRangeMapToJson(this);
}
