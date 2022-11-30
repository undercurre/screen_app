import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/device_p_d_m_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class DevicePDMEntity {

	String? linkageModel;
	int? nightBrightValue;
	int? brightValueMax;
	int? timeOff;
	int? sunupTimeHour;
	int? mildColorTemperatureValue;
	int? sunsetTimeHour;
	int? colorTemperatureValueMin;
	int? brightValue;
	int? readBrightValue;
	int? sunsetTimeMinute;
	int? nightColorTemperatureValue;
	bool? power;
	bool? sunsetRunState;
	int? filmColorTemperatureValue;
	int? colorTemperatureValue;
	int? colorTemperatureValueMax;
	int? readColorTemperatureValue;
	bool? sunupRunState;
	int? mildBrightValue;
	bool? sunup;
	int? lifeColorTemperatureValue;
	int? sunupTimeMinute;
	String? screenModel;
	int? filmBrightValue;
	int? dimTime;
	int? lifeBrightValue;
	bool? sunset;
	int? brightValueMin;
  
  DevicePDMEntity();

  factory DevicePDMEntity.fromJson(Map<String, dynamic> json) => $DevicePDMEntityFromJson(json);

  Map<String, dynamic> toJson() => $DevicePDMEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}