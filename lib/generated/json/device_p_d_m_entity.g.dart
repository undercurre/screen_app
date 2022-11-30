import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/device_p_d_m_entity.dart';

DevicePDMEntity $DevicePDMEntityFromJson(Map<String, dynamic> json) {
	final DevicePDMEntity devicePDMEntity = DevicePDMEntity();
	final String? linkageModel = jsonConvert.convert<String>(json['linkageModel']);
	if (linkageModel != null) {
		devicePDMEntity.linkageModel = linkageModel;
	}
	final int? nightBrightValue = jsonConvert.convert<int>(json['nightBrightValue']);
	if (nightBrightValue != null) {
		devicePDMEntity.nightBrightValue = nightBrightValue;
	}
	final int? brightValueMax = jsonConvert.convert<int>(json['brightValueMax']);
	if (brightValueMax != null) {
		devicePDMEntity.brightValueMax = brightValueMax;
	}
	final int? timeOff = jsonConvert.convert<int>(json['timeOff']);
	if (timeOff != null) {
		devicePDMEntity.timeOff = timeOff;
	}
	final int? sunupTimeHour = jsonConvert.convert<int>(json['sunupTimeHour']);
	if (sunupTimeHour != null) {
		devicePDMEntity.sunupTimeHour = sunupTimeHour;
	}
	final int? mildColorTemperatureValue = jsonConvert.convert<int>(json['mildColorTemperatureValue']);
	if (mildColorTemperatureValue != null) {
		devicePDMEntity.mildColorTemperatureValue = mildColorTemperatureValue;
	}
	final int? sunsetTimeHour = jsonConvert.convert<int>(json['sunsetTimeHour']);
	if (sunsetTimeHour != null) {
		devicePDMEntity.sunsetTimeHour = sunsetTimeHour;
	}
	final int? colorTemperatureValueMin = jsonConvert.convert<int>(json['colorTemperatureValueMin']);
	if (colorTemperatureValueMin != null) {
		devicePDMEntity.colorTemperatureValueMin = colorTemperatureValueMin;
	}
	final int? brightValue = jsonConvert.convert<int>(json['brightValue']);
	if (brightValue != null) {
		devicePDMEntity.brightValue = brightValue;
	}
	final int? readBrightValue = jsonConvert.convert<int>(json['readBrightValue']);
	if (readBrightValue != null) {
		devicePDMEntity.readBrightValue = readBrightValue;
	}
	final int? sunsetTimeMinute = jsonConvert.convert<int>(json['sunsetTimeMinute']);
	if (sunsetTimeMinute != null) {
		devicePDMEntity.sunsetTimeMinute = sunsetTimeMinute;
	}
	final int? nightColorTemperatureValue = jsonConvert.convert<int>(json['nightColorTemperatureValue']);
	if (nightColorTemperatureValue != null) {
		devicePDMEntity.nightColorTemperatureValue = nightColorTemperatureValue;
	}
	final bool? power = jsonConvert.convert<bool>(json['power']);
	if (power != null) {
		devicePDMEntity.power = power;
	}
	final bool? sunsetRunState = jsonConvert.convert<bool>(json['sunsetRunState']);
	if (sunsetRunState != null) {
		devicePDMEntity.sunsetRunState = sunsetRunState;
	}
	final int? filmColorTemperatureValue = jsonConvert.convert<int>(json['filmColorTemperatureValue']);
	if (filmColorTemperatureValue != null) {
		devicePDMEntity.filmColorTemperatureValue = filmColorTemperatureValue;
	}
	final int? colorTemperatureValue = jsonConvert.convert<int>(json['colorTemperatureValue']);
	if (colorTemperatureValue != null) {
		devicePDMEntity.colorTemperatureValue = colorTemperatureValue;
	}
	final int? colorTemperatureValueMax = jsonConvert.convert<int>(json['colorTemperatureValueMax']);
	if (colorTemperatureValueMax != null) {
		devicePDMEntity.colorTemperatureValueMax = colorTemperatureValueMax;
	}
	final int? readColorTemperatureValue = jsonConvert.convert<int>(json['readColorTemperatureValue']);
	if (readColorTemperatureValue != null) {
		devicePDMEntity.readColorTemperatureValue = readColorTemperatureValue;
	}
	final bool? sunupRunState = jsonConvert.convert<bool>(json['sunupRunState']);
	if (sunupRunState != null) {
		devicePDMEntity.sunupRunState = sunupRunState;
	}
	final int? mildBrightValue = jsonConvert.convert<int>(json['mildBrightValue']);
	if (mildBrightValue != null) {
		devicePDMEntity.mildBrightValue = mildBrightValue;
	}
	final bool? sunup = jsonConvert.convert<bool>(json['sunup']);
	if (sunup != null) {
		devicePDMEntity.sunup = sunup;
	}
	final int? lifeColorTemperatureValue = jsonConvert.convert<int>(json['lifeColorTemperatureValue']);
	if (lifeColorTemperatureValue != null) {
		devicePDMEntity.lifeColorTemperatureValue = lifeColorTemperatureValue;
	}
	final int? sunupTimeMinute = jsonConvert.convert<int>(json['sunupTimeMinute']);
	if (sunupTimeMinute != null) {
		devicePDMEntity.sunupTimeMinute = sunupTimeMinute;
	}
	final String? screenModel = jsonConvert.convert<String>(json['screenModel']);
	if (screenModel != null) {
		devicePDMEntity.screenModel = screenModel;
	}
	final int? filmBrightValue = jsonConvert.convert<int>(json['filmBrightValue']);
	if (filmBrightValue != null) {
		devicePDMEntity.filmBrightValue = filmBrightValue;
	}
	final int? dimTime = jsonConvert.convert<int>(json['dimTime']);
	if (dimTime != null) {
		devicePDMEntity.dimTime = dimTime;
	}
	final int? lifeBrightValue = jsonConvert.convert<int>(json['lifeBrightValue']);
	if (lifeBrightValue != null) {
		devicePDMEntity.lifeBrightValue = lifeBrightValue;
	}
	final bool? sunset = jsonConvert.convert<bool>(json['sunset']);
	if (sunset != null) {
		devicePDMEntity.sunset = sunset;
	}
	final int? brightValueMin = jsonConvert.convert<int>(json['brightValueMin']);
	if (brightValueMin != null) {
		devicePDMEntity.brightValueMin = brightValueMin;
	}
	return devicePDMEntity;
}

Map<String, dynamic> $DevicePDMEntityToJson(DevicePDMEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['linkageModel'] = entity.linkageModel;
	data['nightBrightValue'] = entity.nightBrightValue;
	data['brightValueMax'] = entity.brightValueMax;
	data['timeOff'] = entity.timeOff;
	data['sunupTimeHour'] = entity.sunupTimeHour;
	data['mildColorTemperatureValue'] = entity.mildColorTemperatureValue;
	data['sunsetTimeHour'] = entity.sunsetTimeHour;
	data['colorTemperatureValueMin'] = entity.colorTemperatureValueMin;
	data['brightValue'] = entity.brightValue;
	data['readBrightValue'] = entity.readBrightValue;
	data['sunsetTimeMinute'] = entity.sunsetTimeMinute;
	data['nightColorTemperatureValue'] = entity.nightColorTemperatureValue;
	data['power'] = entity.power;
	data['sunsetRunState'] = entity.sunsetRunState;
	data['filmColorTemperatureValue'] = entity.filmColorTemperatureValue;
	data['colorTemperatureValue'] = entity.colorTemperatureValue;
	data['colorTemperatureValueMax'] = entity.colorTemperatureValueMax;
	data['readColorTemperatureValue'] = entity.readColorTemperatureValue;
	data['sunupRunState'] = entity.sunupRunState;
	data['mildBrightValue'] = entity.mildBrightValue;
	data['sunup'] = entity.sunup;
	data['lifeColorTemperatureValue'] = entity.lifeColorTemperatureValue;
	data['sunupTimeMinute'] = entity.sunupTimeMinute;
	data['screenModel'] = entity.screenModel;
	data['filmBrightValue'] = entity.filmBrightValue;
	data['dimTime'] = entity.dimTime;
	data['lifeBrightValue'] = entity.lifeBrightValue;
	data['sunset'] = entity.sunset;
	data['brightValueMin'] = entity.brightValueMin;
	return data;
}