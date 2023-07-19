import 'package:screen_app/generated/json/base/json_convert_content.dart';

import 'meiju_weather7d_entity.dart';

MeiJuWeather7dEntity $MeiJuWeather7dEntityFromJson(Map<String, dynamic> json) {
	final MeiJuWeather7dEntity weather7dEntity = MeiJuWeather7dEntity();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		weather7dEntity.date = date;
	}
	final String? dayWeatherStatus = jsonConvert.convert<String>(json['dayWeatherStatus']);
	if (dayWeatherStatus != null) {
		weather7dEntity.dayWeatherStatus = dayWeatherStatus;
	}
	final String? sunrise = jsonConvert.convert<String>(json['sunrise']);
	if (sunrise != null) {
		weather7dEntity.sunrise = sunrise;
	}
	final String? dayWindDirection = jsonConvert.convert<String>(json['dayWindDirection']);
	if (dayWindDirection != null) {
		weather7dEntity.dayWindDirection = dayWindDirection;
	}
	final String? nightWindDirection = jsonConvert.convert<String>(json['nightWindDirection']);
	if (nightWindDirection != null) {
		weather7dEntity.nightWindDirection = nightWindDirection;
	}
	final String? dayWindForce = jsonConvert.convert<String>(json['dayWindForce']);
	if (dayWindForce != null) {
		weather7dEntity.dayWindForce = dayWindForce;
	}
	final String? sunset = jsonConvert.convert<String>(json['sunset']);
	if (sunset != null) {
		weather7dEntity.sunset = sunset;
	}
	final String? nightWeatherStatus = jsonConvert.convert<String>(json['nightWeatherStatus']);
	if (nightWeatherStatus != null) {
		weather7dEntity.nightWeatherStatus = nightWeatherStatus;
	}
	final String? nightLowGrade = jsonConvert.convert<String>(json['nightLowGrade']);
	if (nightLowGrade != null) {
		weather7dEntity.nightLowGrade = nightLowGrade;
	}
	final String? nightWindForce = jsonConvert.convert<String>(json['nightWindForce']);
	if (nightWindForce != null) {
		weather7dEntity.nightWindForce = nightWindForce;
	}
	final String? dayHighGrade = jsonConvert.convert<String>(json['dayHighGrade']);
	if (dayHighGrade != null) {
		weather7dEntity.dayHighGrade = dayHighGrade;
	}
	return weather7dEntity;
}

Map<String, dynamic> $MeiJuWeather7dEntityToJson(MeiJuWeather7dEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['dayWeatherStatus'] = entity.dayWeatherStatus;
	data['sunrise'] = entity.sunrise;
	data['dayWindDirection'] = entity.dayWindDirection;
	data['nightWindDirection'] = entity.nightWindDirection;
	data['dayWindForce'] = entity.dayWindForce;
	data['sunset'] = entity.sunset;
	data['nightWeatherStatus'] = entity.nightWeatherStatus;
	data['nightLowGrade'] = entity.nightLowGrade;
	data['nightWindForce'] = entity.nightWindForce;
	data['dayHighGrade'] = entity.dayHighGrade;
	return data;
}