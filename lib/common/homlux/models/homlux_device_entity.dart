import 'dart:core';
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

	HomluxDeviceMzgdPropertyDTOList();

	factory HomluxDeviceMzgdPropertyDTOList.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOListFromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListToJson(this);

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

	factory HomluxDeviceMzgdPropertyDTOListCurtain.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOListCurtainFromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListCurtainToJson(this);

	@override
	String toString() {
		return jsonEncode(toJson());
	}
}