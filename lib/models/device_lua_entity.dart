import 'package:screen_app/generated/json/base/json_field.dart';
import 'package:screen_app/generated/json/device_lua_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class DeviceLuaEntity {

	@JSONField(name: "en_sunset_model")
	String? enSunsetModel;
	@JSONField(name: "delay_light_off")
	String? delayLightOff;
	@JSONField(name: "sunup_is_run")
	String? sunupIsRun;
	@JSONField(name: "color_temperature")
	String? colorTemperature;
	@JSONField(name: "sunset_is_run")
	String? sunsetIsRun;
	@JSONField(name: "film_color_temperature")
	String? filmColorTemperature;
	@JSONField(name: "red_value")
	String? redValue;
	@JSONField(name: "link_age_model")
	String? linkAgeModel;
	@JSONField(name: "life_color_temperature")
	String? lifeColorTemperature;
	@JSONField(name: "blue_value")
	String? blueValue;
	String? result;
	@JSONField(name: "dim_speed")
	String? dimSpeed;
	@JSONField(name: "mild_brightness")
	String? mildBrightness;
	@JSONField(name: "sunup_model_hour")
	String? sunupModelHour;
	@JSONField(name: "night_color_temperature")
	String? nightColorTemperature;
	@JSONField(name: "en_sunup_model")
	String? enSunupModel;
	@JSONField(name: "read_brightness")
	String? readBrightness;
	@JSONField(name: "scene_light")
	String? sceneLight;
	String? power;
	@JSONField(name: "sunset_model_minute")
	String? sunsetModelMinute;
	@JSONField(name: "film_brightness")
	String? filmBrightness;
	@JSONField(name: "sunset_model_hour")
	String? sunsetModelHour;
	@JSONField(name: "life_brightness")
	String? lifeBrightness;
	@JSONField(name: "read_color_temperature")
	String? readColorTemperature;
	@JSONField(name: "sunup_model_minute")
	String? sunupModelMinute;
	String? version;
	@JSONField(name: "mild_color_temperature")
	String? mildColorTemperature;
	@JSONField(name: "green_value")
	String? greenValue;
	String? brightness;
	@JSONField(name: "night_brightness")
	String? nightBrightness;
  
  DeviceLuaEntity();

  factory DeviceLuaEntity.fromJson(Map<String, dynamic> json) => $DeviceLuaEntityFromJson(json);

  Map<String, dynamic> toJson() => $DeviceLuaEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}