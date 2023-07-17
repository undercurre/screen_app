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
          ?.map((e) => DeviceActions.fromJson(e as Map<String, dynamic>))
          .toList(),
      deviceConditions: (json['deviceConditions'] as List<dynamic>?)
          ?.map((e) => DeviceConditions.fromJson(e as Map<String, dynamic>))
          .toList(),
      houseId: json['houseId'] as String?,
      isDefault: json['isDefault'] as String?,
      orderNum: json['orderNum'] as int?,
      roomId: json['roomId'] as String?,
      sceneIcon: json['sceneIcon'] as String?,
      sceneId: json['sceneId'] as String?,
      sceneName: json['sceneName'] as String?,
    );

Map<String, dynamic> _$HomluxSceneEntityToJson(HomluxSceneEntity instance) =>
    <String, dynamic>{
      'conditionType': instance.conditionType,
      'defaultType': instance.defaultType,
      'deviceActions': instance.deviceActions,
      'deviceConditions': instance.deviceConditions,
      'houseId': instance.houseId,
      'isDefault': instance.isDefault,
      'orderNum': instance.orderNum,
      'roomId': instance.roomId,
      'sceneIcon': instance.sceneIcon,
      'sceneId': instance.sceneId,
      'sceneName': instance.sceneName,
    };

DeviceActions _$DeviceActionsFromJson(Map<String, dynamic> json) =>
    DeviceActions(
      controlAction: json['controlAction'] as List<dynamic>?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      devicePic: json['devicePic'] as String?,
      deviceType: json['deviceType'] as String?,
      proType: json['proType'] as String?,
      successType: json['successType'] as int?,
    );

Map<String, dynamic> _$DeviceActionsToJson(DeviceActions instance) =>
    <String, dynamic>{
      'controlAction': instance.controlAction,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'devicePic': instance.devicePic,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
      'successType': instance.successType,
    };

DeviceConditions _$DeviceConditionsFromJson(Map<String, dynamic> json) =>
    DeviceConditions(
      controlEvent: json['controlEvent'] as List<dynamic>?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      devicePic: json['devicePic'] as String?,
      deviceType: json['deviceType'] as String?,
      proType: json['proType'] as String?,
    );

Map<String, dynamic> _$DeviceConditionsToJson(DeviceConditions instance) =>
    <String, dynamic>{
      'controlEvent': instance.controlEvent,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'devicePic': instance.devicePic,
      'deviceType': instance.deviceType,
      'proType': instance.proType,
    };
