import 'dart:core';

import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/common/homlux/models/homlux_device_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class HomluxDeviceEntity {
  String? deviceName;
  String? pic;
  String? deviceId;
  String? roomName;
  String? roomId;
  String? gatewayName;
  String? gatewayId;
  String? version;
  int? deviceType;
  String? proType;
  List<HomluxDeviceSwitchInfoDTOList>? switchInfoDTOList;
  HomluxDeviceMzgdPropertyDTOList? mzgdPropertyDTOList;
  dynamic methodList;
  int? onLineStatus;
  int? orderNum;
  String? sn;
  String? lightRelId;
  String? productId;
  int? updateStamp;
  int? authStatus;

  HomluxDeviceEntity();

  factory HomluxDeviceEntity.fromJson(Map<String, dynamic> json) => $HomluxDeviceEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceSwitchInfoDTOList {
  String? switchId;
  String? panelId;
  String? switchName;
  String? houseId;
  String? roomId;
  String? roomName;
  String? pic;
  String? switchRelId;
  int? orderNum;
  String? lightRelId;

  HomluxDeviceSwitchInfoDTOList();

  factory HomluxDeviceSwitchInfoDTOList.fromJson(Map<String, dynamic> json) => $HomluxDeviceSwitchInfoDTOListFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceSwitchInfoDTOListToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList {
  @JSONField(name: "wallSwitch1")
  HomluxDeviceMzgdPropertyDTOList1? x1;
  @JSONField(name: "wallSwitch2")
  HomluxDeviceMzgdPropertyDTOList2? x2;
  @JSONField(name: "wallSwitch3")
  HomluxDeviceMzgdPropertyDTOList3? x3;
  @JSONField(name: "wallSwitch4")
  HomluxDeviceMzgdPropertyDTOList4? x4;
  @JSONField(name: "light")
  HomluxDeviceMzgdPropertyDTOListLight? light;
  @JSONField(name: "curtain")
  HomluxDeviceMzgdPropertyDTOListCurtain? curtain;
  @JSONField(name: "bathHeat")
  HomluxDeviceMzgdPropertyDTOListBathHeat? bathHeat;
  @JSONField(name: "airConditioner")
  HomluxDeviceMzgdPropertyDTOListAirCondition? airCondition;
  @JSONField(name: "clothesDryingRack")
  HomluxDeviceMzgdPropertyDTOListClothesDryingRack? clothesDryingRack;
  @JSONField(name: "freshAir")
  HomluxDeviceMzgdPropertyDTOListFreshAir? freshAir;
  @JSONField(name: "airConditioner")
  HomluxDeviceMzgdPropertyDTOListAir? air485Conditioner;
  @JSONField(name: "floorHeating")
  HomluxDeviceMzgdPropertyDTOListFloorHeating? floorHeating;


  HomluxDeviceMzgdPropertyDTOList();

  factory HomluxDeviceMzgdPropertyDTOList.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOListFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class HomluxDeviceMzgdPropertyDTOListFloorHeating {

  int? mode;
  int? power;
  int? OnOff;
  int? windSpeed;
  int? currentTemperature;
  int? targetTemperature;

  HomluxDeviceMzgdPropertyDTOListFloorHeating();

  factory HomluxDeviceMzgdPropertyDTOListFloorHeating.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListFloorHeatingFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListFloorHeatingToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}

class HomluxDeviceMzgdPropertyDTOListAir {

  int? mode;
  int? power;
  int? OnOff;
  int? windSpeed;
  int? currentTemperature;
  int? targetTemperature;

  HomluxDeviceMzgdPropertyDTOListAir();

  factory HomluxDeviceMzgdPropertyDTOListAir.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListAirFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListAirToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}

class HomluxDeviceMzgdPropertyDTOListFreshAir {

  int? mode;
  int? power;
  int? OnOff;
  int? windSpeed;

  HomluxDeviceMzgdPropertyDTOListFreshAir();

  factory HomluxDeviceMzgdPropertyDTOListFreshAir.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListFreshAirFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListFreshAirToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList1 {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;

  HomluxDeviceMzgdPropertyDTOList1();

  factory HomluxDeviceMzgdPropertyDTOList1.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList1FromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList1ToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList2 {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;

  HomluxDeviceMzgdPropertyDTOList2();

  factory HomluxDeviceMzgdPropertyDTOList2.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList2FromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList2ToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList3 {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;

  HomluxDeviceMzgdPropertyDTOList3();

  factory HomluxDeviceMzgdPropertyDTOList3.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList3FromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList3ToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList4 {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;

  HomluxDeviceMzgdPropertyDTOList4();

  factory HomluxDeviceMzgdPropertyDTOList4.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList4FromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList4ToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class HomluxColorTempRange {
  int? maxColorTemp;
  int? minColorTemp;

  HomluxColorTempRange();

  factory HomluxColorTempRange.fromJson(Map<String, dynamic> json) => $HomluxColorTempRangeFromJson(json);

  Map<String, dynamic> toJson() => $HomluxColorTempRangeToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOListLight {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;
  @JSONField(name: "colorTempRange")
  HomluxColorTempRange? colorTempRange;

  HomluxDeviceMzgdPropertyDTOListLight();

  factory HomluxDeviceMzgdPropertyDTOListLight.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOListLightFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListLightToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOListCurtain {
  @JSONField(name: "buttonScene")
  int? buttonScene;
  @JSONField(name: "buttonMode")
  int? buttonMode;
  @JSONField(name: "power")
  int? power;
  @JSONField(name: "StartUpOnOff")
  int? startUpOnOff;
  @JSONField(name: "colorTemperature")
  int? colorTemperature;
  @JSONField(name: "brightness")
  int? brightness;
  @JSONField(name: "Duration")
  int? duration;
  @JSONField(name: "BcReportTime")
  int? bcReportTime;
  @JSONField(name: "DelayClose")
  int? delayClose;
  @JSONField(name: "curtain_position")
  String? curtainPosition;
  @JSONField(name: "curtain_status")
  String? curtainStatus;
  @JSONField(name: "curtain_direction")
  String? curtainDirection;
  @JSONField(name: "power")
  String? wifiLightPower;
  @JSONField(name: "delay_light_off")
  String? wifiLightDelayOff;
  @JSONField(name: "scene_light")
  String? wifiLightScene;

  HomluxDeviceMzgdPropertyDTOListCurtain();

  factory HomluxDeviceMzgdPropertyDTOListCurtain.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListCurtainFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListCurtainToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOListBathHeat {
  @JSONField(name: "delay_enable")
  String? delayEnable;

  @JSONField(name: "dehumidity_trigger")
  String? dehumidityTrigger;

  @JSONField(name: "night_light_brightness")
  String? nightLightBrightness;

  @JSONField(name: "digit_led_enable")
  String? digitLedEnable;

  @JSONField(name: "mode")
  String? mode;

  @JSONField(name: "current_temperature")
  String? currentTemperature;

  @JSONField(name: "radar_induction_enable")
  String? radarInductionEnable;

  @JSONField(name: "heating_direction")
  String? heatingDirection;

  @JSONField(name: "delay_time")
  String? delayTime;

  @JSONField(name: "anion_enable")
  String? anionEnable;

  @JSONField(name: "light_mode")
  String? lightMode;

  @JSONField(name: "bath_temperature")
  String? bathTemperature;

  @JSONField(name: "subpacket_type")
  String? subpacketType;

  @JSONField(name: "radar_induction_closing_time")
  String? radarInductionClosingTime;

  @JSONField(name: "bath_direction")
  String? bathDirection;

  @JSONField(name: "drying_time")
  String? dryingTime;

  @JSONField(name: "main_light_brightness")
  String? mainLightBrightness;

  @JSONField(name: "function_led_enable")
  String? functionLedEnable;

  @JSONField(name: "drying_direction")
  String? dryingDirection;

  @JSONField(name: "bath_heating_time")
  String? bathHeatingTime;

  @JSONField(name: "version")
  String? version;

  @JSONField(name: "heating_temperature")
  String? heatingTemperature;

  @JSONField(name: "smelly_trigger")
  String? smellyTrigger;

  @JSONField(name: "blowing_direction")
  String? blowingDirection;

  @JSONField(name: "current_radar_status")
  String? currentRadarStatus;

  @JSONField(name: "blowing_speed")
  String? blowingSpeed;

  @JSONField(name: "wifi_led_enable")
  String? wifiLedEnable;

  HomluxDeviceMzgdPropertyDTOListBathHeat({
    this.delayEnable,
    this.dehumidityTrigger,
    this.nightLightBrightness,
    this.digitLedEnable,
    this.mode,
    this.currentTemperature,
    this.radarInductionEnable,
    this.heatingDirection,
    this.delayTime,
    this.anionEnable,
    this.lightMode,
    this.bathTemperature,
    this.subpacketType,
    this.radarInductionClosingTime,
    this.bathDirection,
    this.dryingTime,
    this.mainLightBrightness,
    this.functionLedEnable,
    this.dryingDirection,
    this.bathHeatingTime,
    this.version,
    this.heatingTemperature,
    this.smellyTrigger,
    this.blowingDirection,
    this.currentRadarStatus,
    this.blowingSpeed,
    this.wifiLedEnable,
  });

  factory HomluxDeviceMzgdPropertyDTOListBathHeat.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListBathHeatFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListBathHeatToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOListAirCondition {
  @JSONField(name: "small_temperature")
  double? smallTemperature;

  @JSONField(name: "indoor_temperature")
  double? indoorTemperature;

  @JSONField(name: "wind_swing_lr_under")
  String? windSwingLrUnder;

  @JSONField(name: "wind_swing_lr")
  String? windSwingLr;

  @JSONField(name: "power_on_time_value")
  int? powerOnTimeValue;

  @JSONField(name: "power_off_time_value")
  int? powerOffTimeValue;

  @JSONField(name: "kick_quilt")
  String? kickQuilt;

  @JSONField(name: "dust_full_time")
  int? dustFullTime;

  @JSONField(name: "mode")
  String? mode;

  @JSONField(name: "eco")
  String? eco;

  @JSONField(name: "purifier")
  String? purifier;

  @JSONField(name: "natural_wind")
  String? naturalWind;

  @JSONField(name: "fault_tag")
  int? faultTag;

  @JSONField(name: "pmv")
  double? pmv;

  @JSONField(name: "temperature")
  int? temperature;

  @JSONField(name: "arom_old")
  int? aromOld;

  @JSONField(name: "comfort_sleep")
  String? comfortSleep;

  @JSONField(name: "wind_speed")
  int? windSpeed;

  @JSONField(name: "power")
  int? power;

  @JSONField(name: "ptc")
  String? ptc;

  @JSONField(name: "prevent_cold")
  String? preventCold;

  @JSONField(name: "power_on_timer")
  String? powerOnTimer;

  @JSONField(name: "analysis_value")
  String? analysisValue;

  @JSONField(name: "screen_display_now")
  String? screenDisplayNow;

  @JSONField(name: "dry")
  String? dry;

  @JSONField(name: "version")
  int? version;

  @JSONField(name: "wind_swing_ud")
  String? windSwingUd;

  @JSONField(name: "power_saving")
  String? powerSaving;

  @JSONField(name: "strong_wind")
  String? strongWind;

  @JSONField(name: "fresh_filter_time_use")
  int? freshFilterTimeUse;

  @JSONField(name: "power_off_timer")
  String? powerOffTimer;

  @JSONField(name: "error_code")
  int? errorCode;


  HomluxDeviceMzgdPropertyDTOListAirCondition({
    this.smallTemperature,
    this.indoorTemperature,
    this.windSwingLrUnder,
    this.windSwingLr,
    this.powerOnTimeValue,
    this.powerOffTimeValue,
    this.kickQuilt,
    this.dustFullTime,
    this.mode,
    this.eco,
    this.purifier,
    this.naturalWind,
    this.faultTag,
    this.pmv,
    this.temperature,
    this.aromOld,
    this.comfortSleep,
    this.windSpeed,
    this.power,
    this.ptc,
    this.preventCold,
    this.powerOnTimer,
    this.analysisValue,
    this.screenDisplayNow,
    this.dry,
    this.version,
    this.windSwingUd,
    this.powerSaving,
    this.strongWind,
    this.freshFilterTimeUse,
    this.powerOffTimer,
    this.errorCode,
  });

  factory HomluxDeviceMzgdPropertyDTOListAirCondition.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListAirConditionFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListAirConditionToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOListClothesDryingRack {
  @JSONField(name: 'timing_to_top')
  int? timingToTop;

  @JSONField(name: 'custom_height')
  int? customHeight;

  @JSONField(name: 'body_induction')
  String? bodyInduction;

  @JSONField(name: 'light_brightness')
  int? lightBrightness;

  @JSONField(name: 'version')
  int? version;

  @JSONField(name: 'sw_version')
  String? swVersion;

  @JSONField(name: 'timing_light_off')
  int? timingLightOff;

  @JSONField(name: 'custom_timing')
  int? customTiming;

  @JSONField(name: 'deviceSubType')
  int? deviceSubType;

  @JSONField(name: 'dry_mode')
  String? dryMode;

  @JSONField(name: 'light')
  String? light;

  @JSONField(name: 'laundry')
  String? laundry;

  @JSONField(name: 'error_code')
  int? errorCode;

  @JSONField(name: 'height_resetting')
  String? heightResetting;

  @JSONField(name: 'offline_voice_function')
  String? offlineVoiceFunction;

  @JSONField(name: 'time_after_nobody')
  int? timeAfterNobody;

  @JSONField(name: 'sterilize')
  String? sterilize;

  @JSONField(name: 'updown')
  String? updown;

  @JSONField(name: 'set_light_off')
  String? setLightOff;

  @JSONField(name: 'location_status')
  String? locationStatus;

  @JSONField(name: 'set_to_top')
  String? setToTop;

  @JSONField(name: 'remaining_time')
  RemainingTime? remainingTime;

  HomluxDeviceMzgdPropertyDTOListClothesDryingRack({
    this.timingToTop,
    this.customHeight,
    this.bodyInduction,
    this.lightBrightness,
    this.version,
    this.swVersion,
    this.timingLightOff,
    this.customTiming,
    this.deviceSubType,
    this.dryMode,
    this.light,
    this.laundry,
    this.errorCode,
    this.heightResetting,
    this.offlineVoiceFunction,
    this.timeAfterNobody,
    this.sterilize,
    this.updown,
    this.setLightOff,
    this.locationStatus,
    this.setToTop,
    this.remainingTime
  });

  factory HomluxDeviceMzgdPropertyDTOListClothesDryingRack.fromJson(Map<String, dynamic> json) =>
      $HomluxDeviceMzgdPropertyDTOListClothesDryingRackFromJson(json);

  Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListClothesDryingRackToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class RemainingTime {
  @JSONField(name: 'ptc_drying_remaining_time')
  int? ptcDryingRemainingTime;

  @JSONField(name: 'sterilize_remaining_time')
  int? sterilizeRemainingTime;

  @JSONField(name: 'air_drying_remaining_time')
  int? airDryingRemainingTime;

  RemainingTime({
     this.ptcDryingRemainingTime,
     this.sterilizeRemainingTime,
     this.airDryingRemainingTime,
  });

  factory RemainingTime.fromJson(Map<String, dynamic> json) => $RemainingTimeFromJson(json);

  Map<String, dynamic> toJson() => $RemainingTimeToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
