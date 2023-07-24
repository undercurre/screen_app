import 'package:screen_app/common/homlux/generated/json/base/homlux_json_convert_content.dart';

part 'homlux_scene_entity.g.dart';
// 接口文档地址：http://47.106.94.129:8001/doc.html#/mzaio-scene/%E5%9C%BA%E6%99%AF%E5%86%85%E9%83%A8%E8%B0%83%E7%94%A8%E6%9C%8D%E5%8A%A1/querySceneListByHouseIdUsingPOST_1

class HomluxSceneEntity {
  String? conditionType;
  String? defaultType;
  List<HomluxDeviceActions>? deviceActions;
  List<HomluxDeviceConditions>? deviceConditions;
  HomluxEffectiveTime? effectiveTime;
  String? houseId;
  String? isDefault;
  String? isEnabled;
  int? orderNum;
  String? roomId;
  String? roomName;
  String? sceneIcon;
  String? sceneId;
  String? sceneName;
  List<HomluxTimeConditions>? timeConditions;

  HomluxSceneEntity();

  factory HomluxSceneEntity.fromJson(Map<String, dynamic> json) =>
      _$HomluxSceneEntityFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxSceneEntityToJson(this);
}

class HomluxDeviceActions {
  final List<dynamic>? controlAction;
  final int? delayTime;
  final String? deviceId;
  final String? deviceName;
  final String? devicePic;
  final int? deviceType;
  final String? proType;
  final int? successType;

  const HomluxDeviceActions({
    this.controlAction,
    this.delayTime,
    this.deviceId,
    this.deviceName,
    this.devicePic,
    this.deviceType,
    this.proType,
    this.successType,
  });

  factory HomluxDeviceActions.fromJson(Map<String, dynamic> json) =>
      _$HomluxDeviceActionsFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxDeviceActionsToJson(this);
}

class HomluxDeviceConditions {
  final List<dynamic>? controlEvent;
  final String? deviceId;
  final String? deviceName;
  final String? devicePic;
  final int? deviceType;
  final String? proType;
  final String? productId;

  const HomluxDeviceConditions({
    this.controlEvent,
    this.deviceId,
    this.deviceName,
    this.devicePic,
    this.deviceType,
    this.proType,
    this.productId,
  });

  factory HomluxDeviceConditions.fromJson(Map<String, dynamic> json) =>
      _$HomluxDeviceConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxDeviceConditionsToJson(this);
}

class HomluxEffectiveTime {
  final String? endTime;
  final String? startTime;
  final String? time;
  final String? timePeriod;
  final String? timeType;

  const HomluxEffectiveTime({
    this.endTime,
    this.startTime,
    this.time,
    this.timePeriod,
    this.timeType,
  });

  factory HomluxEffectiveTime.fromJson(Map<String, dynamic> json) =>
      _$HomluxEffectiveTimeFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxEffectiveTimeToJson(this);
}

class HomluxTimeConditions {
  final String? endTime;
  final String? startTime;
  final String? time;
  final String? timePeriod;
  final String? timeType;

  const HomluxTimeConditions({
    this.endTime,
    this.startTime,
    this.time,
    this.timePeriod,
    this.timeType,
  });

  factory HomluxTimeConditions.fromJson(Map<String, dynamic> json) =>
      _$HomluxTimeConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$HomluxTimeConditionsToJson(this);
}
