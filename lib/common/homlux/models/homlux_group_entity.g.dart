// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxGroupEntity _$HomluxGroupEntityFromJson(Map<String, dynamic> json) =>
    HomluxGroupEntity(
      groupName: json['groupName'] as String?,
      groupPic: json['groupPic'] as String?,
      groupId: json['groupId'] as String?,
      roomName: json['roomName'] as String?,
      roomId: json['roomId'] as String?,
      deviceType: json['deviceType'] as int?,
      proType: json['proType'] as String?,
      orderNum: json['orderNum'] as int?,
      groupDeviceList: (json['groupDeviceList'] as List<dynamic>?)
          ?.map((e) => GroupDeviceList.fromJson(e as Map<String, dynamic>))
          .toList(),
      controlAction: (json['controlAction'] as List<dynamic>?)
          ?.map((e) => ControlAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      colorTempRangeMap: json['colorTempRangeMap'] == null
          ? null
          : ColorTempRangeMap.fromJson(
              json['colorTempRangeMap'] as Map<String, dynamic>),
      onLineStatus: json['onLineStatus'] as int?,
      houseId: json['houseId'] as String?,
    );

Map<String, dynamic> _$HomluxGroupEntityToJson(HomluxGroupEntity instance) =>
    <String, dynamic>{
      'groupName': instance.groupName,
      'groupPic': instance.groupPic,
      'groupId': instance.groupId,
      'roomName': instance.roomName,
      'roomId': instance.roomId,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
      'orderNum': instance.orderNum,
      'groupDeviceList': instance.groupDeviceList,
      'controlAction': instance.controlAction,
      'colorTempRangeMap': instance.colorTempRangeMap,
      'onLineStatus': instance.onLineStatus,
      'houseId': instance.houseId,
    };

GroupDeviceList _$GroupDeviceListFromJson(Map<String, dynamic> json) =>
    GroupDeviceList(
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      devicePic: json['devicePic'] as String?,
      deviceType: json['deviceType'] as int?,
      proType: json['proType'] as String?,
      onLineStatus: json['onLineStatus'] as int?,
    );

Map<String, dynamic> _$GroupDeviceListToJson(GroupDeviceList instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'devicePic': instance.devicePic,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
      'onLineStatus': instance.onLineStatus,
    };

ControlAction _$ControlActionFromJson(Map<String, dynamic> json) =>
    ControlAction(
      power: json['power'] as int?,
      brightness: json['brightness'] as int?,
      colorTemperature: json['colorTemperature'] as int?,
    );

Map<String, dynamic> _$ControlActionToJson(ControlAction instance) =>
    <String, dynamic>{
      'power': instance.power,
      'brightness': instance.brightness,
      'colorTemperature': instance.colorTemperature,
    };

ColorTempRangeMap _$ColorTempRangeMapFromJson(Map<String, dynamic> json) =>
    ColorTempRangeMap(
      minColorTemp: json['minColorTemp'] as int?,
      maxColorTemp: json['maxColorTemp'] as int?,
    );

Map<String, dynamic> _$ColorTempRangeMapToJson(ColorTempRangeMap instance) =>
    <String, dynamic>{
      'minColorTemp': instance.minColorTemp,
      'maxColorTemp': instance.maxColorTemp,
    };
