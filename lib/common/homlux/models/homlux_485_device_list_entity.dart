
import 'dart:convert';

import 'package:screen_app/common/homlux/models/homlux_485_device_list_entity.g.dart';

import '../../../generated/json/base/json_field.dart';

@JsonSerializable()
class Homlux485DeviceListEntity {
	Homlux485DeviceListNameValuePairs? nameValuePairs;

	Homlux485DeviceListEntity();

	factory Homlux485DeviceListEntity.fromJson(Map<String, dynamic> json) => $Homlux485DeviceListEntityFromJson(json);

	Map<String, dynamic> toJson() => $Homlux485DeviceListEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class Homlux485DeviceListNameValuePairs {
	@JSONField(name: "AirConditionList")
	List<Homlux485DeviceListNameValuePairsAirConditionList>? airConditionList;
	@JSONField(name: "FreshAirList")
	List<Homlux485DeviceListNameValuePairsFreshAirList>? freshAirList;
	@JSONField(name: "FloorHotList")
	List<Homlux485DeviceListNameValuePairsFloorHotList>? floorHotList;

	Homlux485DeviceListNameValuePairs();

	factory Homlux485DeviceListNameValuePairs.fromJson(Map<String, dynamic> json) => $Homlux485DeviceListNameValuePairsFromJson(json);

	Map<String, dynamic> toJson() => $Homlux485DeviceListNameValuePairsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class Homlux485DeviceListNameValuePairsAirConditionList {
	@JSONField(name: "CurrTemperature")
	String? currTemperature;
	@JSONField(name: "OnOff")
	String? onOff;
	String? errorCode;
	String? inSideAddress;
	String? onlineState;
	String? outSideAddress;
	String? temperature;
	String? windSpeed;
	String? workModel;

	Homlux485DeviceListNameValuePairsAirConditionList();

	factory Homlux485DeviceListNameValuePairsAirConditionList.fromJson(Map<String, dynamic> json) => $Homlux485DeviceListNameValuePairsAirConditionListFromJson(json);

	Map<String, dynamic> toJson() => $Homlux485DeviceListNameValuePairsAirConditionListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class Homlux485DeviceListNameValuePairsFreshAirList {
	@JSONField(name: "OnOff")
	String? onOff;
	String? errorCode;
	String? inSideAddress;
	String? onlineState;
	String? outSideAddress;
	String? windSpeed;
	String? workModel;

	Homlux485DeviceListNameValuePairsFreshAirList();

	factory Homlux485DeviceListNameValuePairsFreshAirList.fromJson(Map<String, dynamic> json) => $Homlux485DeviceListNameValuePairsFreshAirListFromJson(json);

	Map<String, dynamic> toJson() => $Homlux485DeviceListNameValuePairsFreshAirListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class Homlux485DeviceListNameValuePairsFloorHotList {
	@JSONField(name: "CurrTemperature")
	String? currTemperature;
	@JSONField(name: "OnOff")
	String? onOff;
	String? errorCode;
	String? frostProtection;
	String? inSideAddress;
	String? onlineState;
	String? outSideAddress;
	String? temperature;

	Homlux485DeviceListNameValuePairsFloorHotList();

	factory Homlux485DeviceListNameValuePairsFloorHotList.fromJson(Map<String, dynamic> json) => $Homlux485DeviceListNameValuePairsFloorHotListFromJson(json);

	Map<String, dynamic> toJson() => $Homlux485DeviceListNameValuePairsFloorHotListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}