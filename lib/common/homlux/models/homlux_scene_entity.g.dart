// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homlux_scene_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomluxSceneEntity _$HomluxSceneEntityFromJson(Map<String, dynamic> json) {
      var entity = HomluxSceneEntity();
      entity.deviceActions = homluxJsonConvert.convertListNotNull(json['deviceActions']);
      entity.deviceConditions = homluxJsonConvert.convertListNotNull(json['deviceConditions']);
      entity.effectiveTime = homluxJsonConvert.convert(json['effectiveTime']);
      entity.houseId = homluxJsonConvert.convert(json['houseId']);
      entity.defaultType = homluxJsonConvert.convert(json['defaultType']);
      entity.conditionType = homluxJsonConvert.convert(json['conditionType']);
      entity.isDefault = homluxJsonConvert.convert(json['isDefault']);
      entity.isEnabled = homluxJsonConvert.convert(json['isEnabled']);
      entity.orderNum = homluxJsonConvert.convert(json['orderNum']);
      entity.roomId = homluxJsonConvert.convert(json['roomId']);
      entity.roomName = homluxJsonConvert.convert(json['roomName']);
      entity.sceneIcon = homluxJsonConvert.convert(json['sceneIcon']);
      entity.sceneId = homluxJsonConvert.convert(json['sceneId']);
      entity.sceneName = homluxJsonConvert.convert(json['sceneName']);
      entity.updateStamp = homluxJsonConvert.convert(json['updateStamp']);
      entity.timeConditions = homluxJsonConvert.convertListNotNull<HomluxTimeConditions>(json['timeConditions']);
      return entity;
}


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
      'updateStamp': instance.updateStamp,
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
