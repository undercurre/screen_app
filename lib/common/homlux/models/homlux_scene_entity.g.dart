// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_scene_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxSceneEntity _$HomluxSceneEntityFromJson(Map<String, dynamic> json) =>
    HomluxSceneEntity(
      conditionType: json['conditionType'] as String?,
      defaultType: json['defaultType'] as String?,
      deviceActions: (json['deviceActions'] as List<dynamic>?)
          ?.map((e) => HomluxDeviceActions.fromJson(e as Map<String, dynamic>))
          .toList(),
      deviceConditions: (json['deviceConditions'] as List<dynamic>?)
          ?.map((e) => HomluxDeviceConditions.fromJson(e as Map<String, dynamic>))
          .toList(),
      effectiveTime: json['effectiveTime'] == null
          ? null
          : HomluxEffectiveTime.fromJson(
              json['effectiveTime'] as Map<String, dynamic>),
      houseId: json['houseId'] as String?,
      isDefault: json['isDefault'] as String?,
      isEnabled: json['isEnabled'] as String?,
      orderNum: json['orderNum'] as int?,
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      sceneIcon: json['sceneIcon'] as String?,
      sceneId: json['sceneId'] as String?,
      sceneName: json['sceneName'] as String?,
      timeConditions: (json['timeConditions'] as List<dynamic>?)
          ?.map((e) => HomluxTimeConditions.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomluxSceneEntityToJson(HomluxSceneEntity instance) =>
    <String, dynamic>{
      'conditionType': instance.conditionType,
      'defaultType': instance.defaultType,
      'deviceActions': instance.deviceActions?.map((e) => e.toJson()).toList(),
      'deviceConditions':
          instance.deviceConditions?.map((e) => e.toJson()).toList(),
      'effectiveTime': instance.effectiveTime?.toJson(),
      'houseId': instance.houseId,
      'isDefault': instance.isDefault,
      'isEnabled': instance.isEnabled,
      'orderNum': instance.orderNum,
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'sceneIcon': instance.sceneIcon,
      'sceneId': instance.sceneId,
      'sceneName': instance.sceneName,
      'timeConditions':
          instance.timeConditions?.map((e) => e.toJson()).toList(),
    };

HomluxDeviceActions _$HomluxDeviceActionsFromJson(Map<String, dynamic> json) =>
    HomluxDeviceActions(
      controlAction: json['controlAction'] as List<dynamic>?,
      delayTime: json['delayTime'] as int?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      devicePic: json['devicePic'] as String?,
      deviceType: json['deviceType'] as int?,
      proType: json['proType'] as String?,
      successType: json['successType'] as int?,
    );

Map<String, dynamic> _$HomluxDeviceActionsToJson(HomluxDeviceActions instance) =>
    <String, dynamic>{
      'controlAction': instance.controlAction,
      'delayTime': instance.delayTime,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'devicePic': instance.devicePic,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
      'successType': instance.successType,
    };

HomluxDeviceConditions _$HomluxDeviceConditionsFromJson(Map<String, dynamic> json) =>
    HomluxDeviceConditions(
      controlEvent: json['controlEvent'] as List<dynamic>?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      devicePic: json['devicePic'] as String?,
      deviceType: json['deviceType'] as int?,
      proType: json['proType'] as String?,
      productId: json['productId'] as String?,
    );

Map<String, dynamic> _$HomluxDeviceConditionsToJson(HomluxDeviceConditions instance) =>
    <String, dynamic>{
      'controlEvent': instance.controlEvent,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'devicePic': instance.devicePic,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
      'productId': instance.productId,
    };

HomluxEffectiveTime _$HomluxEffectiveTimeFromJson(Map<String, dynamic> json) =>
    HomluxEffectiveTime(
      endTime: json['endTime'] as String?,
      startTime: json['startTime'] as String?,
      time: json['time'] as String?,
      timePeriod: json['timePeriod'] as String?,
      timeType: json['timeType'] as String?,
    );

Map<String, dynamic> _$HomluxEffectiveTimeToJson(HomluxEffectiveTime instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'startTime': instance.startTime,
      'time': instance.time,
      'timePeriod': instance.timePeriod,
      'timeType': instance.timeType,
    };

HomluxTimeConditions _$HomluxTimeConditionsFromJson(Map<String, dynamic> json) =>
    HomluxTimeConditions(
      endTime: json['endTime'] as String?,
      startTime: json['startTime'] as String?,
      time: json['time'] as String?,
      timePeriod: json['timePeriod'] as String?,
      timeType: json['timeType'] as String?,
    );

Map<String, dynamic> _$HomluxTimeConditionsToJson(HomluxTimeConditions instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'startTime': instance.startTime,
      'time': instance.time,
      'timePeriod': instance.timePeriod,
      'timeType': instance.timeType,
    };
