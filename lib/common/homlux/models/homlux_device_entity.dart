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

	HomluxDeviceEntity();

	factory HomluxDeviceEntity.fromJson(Map<String, dynamic> json) => $HomluxDeviceEntityFromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
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
		return jsonEncode(this);
	}
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList {
	@JSONField(name: "1")
	HomluxDeviceMzgdPropertyDTOList1? x1;
	@JSONField(name: "2")
	HomluxDeviceMzgdPropertyDTOList2? x2;
	@JSONField(name: "3")
	HomluxDeviceMzgdPropertyDTOList3? x3;
	@JSONField(name: "4")
	HomluxDeviceMzgdPropertyDTOList4? x4;

	HomluxDeviceMzgdPropertyDTOList();

	factory HomluxDeviceMzgdPropertyDTOList.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOListFromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList1 {
	@JSONField(name: "ButtonScene")
	int? buttonScene;
	@JSONField(name: "ButtonMode")
	int? buttonMode;
	@JSONField(name: "OnOff")
	int? onOff;
	@JSONField(name: "StartUpOnOff")
	int? startUpOnOff;
	@JSONField(name: "ColorTemp")
	int? colorTemp;
	@JSONField(name: "Level")
	int? level;
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

	HomluxDeviceMzgdPropertyDTOList1();

	factory HomluxDeviceMzgdPropertyDTOList1.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList1FromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList1ToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList2 {
	@JSONField(name: "ButtonScene")
	int? buttonScene;
	@JSONField(name: "ButtonMode")
	int? buttonMode;
	@JSONField(name: "OnOff")
	int? onOff;
	@JSONField(name: "StartUpOnOff")
	int? startUpOnOff;
	@JSONField(name: "ColorTemp")
	int? colorTemp;
	@JSONField(name: "Level")
	int? level;
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

	HomluxDeviceMzgdPropertyDTOList2();

	factory HomluxDeviceMzgdPropertyDTOList2.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList2FromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList2ToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList3 {
	@JSONField(name: "ButtonScene")
	int? buttonScene;
	@JSONField(name: "ButtonMode")
	int? buttonMode;
	@JSONField(name: "OnOff")
	int? onOff;
	@JSONField(name: "StartUpOnOff")
	int? startUpOnOff;
	@JSONField(name: "ColorTemp")
	int? colorTemp;
	@JSONField(name: "Level")
	int? level;
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

	HomluxDeviceMzgdPropertyDTOList3();

	factory HomluxDeviceMzgdPropertyDTOList3.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList3FromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList3ToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class HomluxDeviceMzgdPropertyDTOList4 {
	@JSONField(name: "ButtonScene")
	int? buttonScene;
	@JSONField(name: "ButtonMode")
	int? buttonMode;
	@JSONField(name: "OnOff")
	int? onOff;
	@JSONField(name: "StartUpOnOff")
	int? startUpOnOff;
	@JSONField(name: "ColorTemp")
	int? colorTemp;
	@JSONField(name: "Level")
	int? level;
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

	HomluxDeviceMzgdPropertyDTOList4();

	factory HomluxDeviceMzgdPropertyDTOList4.fromJson(Map<String, dynamic> json) => $HomluxDeviceMzgdPropertyDTOList4FromJson(json);

	Map<String, dynamic> toJson() => $HomluxDeviceMzgdPropertyDTOList4ToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}