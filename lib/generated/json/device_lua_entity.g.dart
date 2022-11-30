import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/device_lua_entity.dart';

DeviceLuaEntity $DeviceLuaEntityFromJson(Map<String, dynamic> json) {
	final DeviceLuaEntity deviceLuaEntity = DeviceLuaEntity();
	final String? enSunsetModel = jsonConvert.convert<String>(json['en_sunset_model']);
	if (enSunsetModel != null) {
		deviceLuaEntity.enSunsetModel = enSunsetModel;
	}
	final String? delayLightOff = jsonConvert.convert<String>(json['delay_light_off']);
	if (delayLightOff != null) {
		deviceLuaEntity.delayLightOff = delayLightOff;
	}
	final String? sunupIsRun = jsonConvert.convert<String>(json['sunup_is_run']);
	if (sunupIsRun != null) {
		deviceLuaEntity.sunupIsRun = sunupIsRun;
	}
	final String? colorTemperature = jsonConvert.convert<String>(json['color_temperature']);
	if (colorTemperature != null) {
		deviceLuaEntity.colorTemperature = colorTemperature;
	}
	final String? sunsetIsRun = jsonConvert.convert<String>(json['sunset_is_run']);
	if (sunsetIsRun != null) {
		deviceLuaEntity.sunsetIsRun = sunsetIsRun;
	}
	final String? filmColorTemperature = jsonConvert.convert<String>(json['film_color_temperature']);
	if (filmColorTemperature != null) {
		deviceLuaEntity.filmColorTemperature = filmColorTemperature;
	}
	final String? redValue = jsonConvert.convert<String>(json['red_value']);
	if (redValue != null) {
		deviceLuaEntity.redValue = redValue;
	}
	final String? linkAgeModel = jsonConvert.convert<String>(json['link_age_model']);
	if (linkAgeModel != null) {
		deviceLuaEntity.linkAgeModel = linkAgeModel;
	}
	final String? lifeColorTemperature = jsonConvert.convert<String>(json['life_color_temperature']);
	if (lifeColorTemperature != null) {
		deviceLuaEntity.lifeColorTemperature = lifeColorTemperature;
	}
	final String? blueValue = jsonConvert.convert<String>(json['blue_value']);
	if (blueValue != null) {
		deviceLuaEntity.blueValue = blueValue;
	}
	final String? result = jsonConvert.convert<String>(json['result']);
	if (result != null) {
		deviceLuaEntity.result = result;
	}
	final String? dimSpeed = jsonConvert.convert<String>(json['dim_speed']);
	if (dimSpeed != null) {
		deviceLuaEntity.dimSpeed = dimSpeed;
	}
	final String? mildBrightness = jsonConvert.convert<String>(json['mild_brightness']);
	if (mildBrightness != null) {
		deviceLuaEntity.mildBrightness = mildBrightness;
	}
	final String? sunupModelHour = jsonConvert.convert<String>(json['sunup_model_hour']);
	if (sunupModelHour != null) {
		deviceLuaEntity.sunupModelHour = sunupModelHour;
	}
	final String? nightColorTemperature = jsonConvert.convert<String>(json['night_color_temperature']);
	if (nightColorTemperature != null) {
		deviceLuaEntity.nightColorTemperature = nightColorTemperature;
	}
	final String? enSunupModel = jsonConvert.convert<String>(json['en_sunup_model']);
	if (enSunupModel != null) {
		deviceLuaEntity.enSunupModel = enSunupModel;
	}
	final String? readBrightness = jsonConvert.convert<String>(json['read_brightness']);
	if (readBrightness != null) {
		deviceLuaEntity.readBrightness = readBrightness;
	}
	final String? sceneLight = jsonConvert.convert<String>(json['scene_light']);
	if (sceneLight != null) {
		deviceLuaEntity.sceneLight = sceneLight;
	}
	final String? power = jsonConvert.convert<String>(json['power']);
	if (power != null) {
		deviceLuaEntity.power = power;
	}
	final String? sunsetModelMinute = jsonConvert.convert<String>(json['sunset_model_minute']);
	if (sunsetModelMinute != null) {
		deviceLuaEntity.sunsetModelMinute = sunsetModelMinute;
	}
	final String? filmBrightness = jsonConvert.convert<String>(json['film_brightness']);
	if (filmBrightness != null) {
		deviceLuaEntity.filmBrightness = filmBrightness;
	}
	final String? sunsetModelHour = jsonConvert.convert<String>(json['sunset_model_hour']);
	if (sunsetModelHour != null) {
		deviceLuaEntity.sunsetModelHour = sunsetModelHour;
	}
	final String? lifeBrightness = jsonConvert.convert<String>(json['life_brightness']);
	if (lifeBrightness != null) {
		deviceLuaEntity.lifeBrightness = lifeBrightness;
	}
	final String? readColorTemperature = jsonConvert.convert<String>(json['read_color_temperature']);
	if (readColorTemperature != null) {
		deviceLuaEntity.readColorTemperature = readColorTemperature;
	}
	final String? sunupModelMinute = jsonConvert.convert<String>(json['sunup_model_minute']);
	if (sunupModelMinute != null) {
		deviceLuaEntity.sunupModelMinute = sunupModelMinute;
	}
	final String? version = jsonConvert.convert<String>(json['version']);
	if (version != null) {
		deviceLuaEntity.version = version;
	}
	final String? mildColorTemperature = jsonConvert.convert<String>(json['mild_color_temperature']);
	if (mildColorTemperature != null) {
		deviceLuaEntity.mildColorTemperature = mildColorTemperature;
	}
	final String? greenValue = jsonConvert.convert<String>(json['green_value']);
	if (greenValue != null) {
		deviceLuaEntity.greenValue = greenValue;
	}
	final String? brightness = jsonConvert.convert<String>(json['brightness']);
	if (brightness != null) {
		deviceLuaEntity.brightness = brightness;
	}
	final String? nightBrightness = jsonConvert.convert<String>(json['night_brightness']);
	if (nightBrightness != null) {
		deviceLuaEntity.nightBrightness = nightBrightness;
	}
	return deviceLuaEntity;
}

Map<String, dynamic> $DeviceLuaEntityToJson(DeviceLuaEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['en_sunset_model'] = entity.enSunsetModel;
	data['delay_light_off'] = entity.delayLightOff;
	data['sunup_is_run'] = entity.sunupIsRun;
	data['color_temperature'] = entity.colorTemperature;
	data['sunset_is_run'] = entity.sunsetIsRun;
	data['film_color_temperature'] = entity.filmColorTemperature;
	data['red_value'] = entity.redValue;
	data['link_age_model'] = entity.linkAgeModel;
	data['life_color_temperature'] = entity.lifeColorTemperature;
	data['blue_value'] = entity.blueValue;
	data['result'] = entity.result;
	data['dim_speed'] = entity.dimSpeed;
	data['mild_brightness'] = entity.mildBrightness;
	data['sunup_model_hour'] = entity.sunupModelHour;
	data['night_color_temperature'] = entity.nightColorTemperature;
	data['en_sunup_model'] = entity.enSunupModel;
	data['read_brightness'] = entity.readBrightness;
	data['scene_light'] = entity.sceneLight;
	data['power'] = entity.power;
	data['sunset_model_minute'] = entity.sunsetModelMinute;
	data['film_brightness'] = entity.filmBrightness;
	data['sunset_model_hour'] = entity.sunsetModelHour;
	data['life_brightness'] = entity.lifeBrightness;
	data['read_color_temperature'] = entity.readColorTemperature;
	data['sunup_model_minute'] = entity.sunupModelMinute;
	data['version'] = entity.version;
	data['mild_color_temperature'] = entity.mildColorTemperature;
	data['green_value'] = entity.greenValue;
	data['brightness'] = entity.brightness;
	data['night_brightness'] = entity.nightBrightness;
	return data;
}