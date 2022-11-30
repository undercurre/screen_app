import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/weather_entity.dart';

WeatherEntity $WeatherEntityFromJson(Map<String, dynamic> json) {
	final WeatherEntity weatherEntity = WeatherEntity();
	final String? wetness = jsonConvert.convert<String>(json['wetness']);
	if (wetness != null) {
		weatherEntity.wetness = wetness;
	}
	final String? grade = jsonConvert.convert<String>(json['grade']);
	if (grade != null) {
		weatherEntity.grade = grade;
	}
	final String? windForce = jsonConvert.convert<String>(json['windForce']);
	if (windForce != null) {
		weatherEntity.windForce = windForce;
	}
	final String? windDirection = jsonConvert.convert<String>(json['windDirection']);
	if (windDirection != null) {
		weatherEntity.windDirection = windDirection;
	}
	final String? weatherStatus = jsonConvert.convert<String>(json['weatherStatus']);
	if (weatherStatus != null) {
		weatherEntity.weatherStatus = weatherStatus;
	}
	final String? weatherCode = jsonConvert.convert<String>(json['weatherCode']);
	if (weatherCode != null) {
		weatherEntity.weatherCode = weatherCode;
	}
	final String? precipitation = jsonConvert.convert<String>(json['precipitation']);
	if (precipitation != null) {
		weatherEntity.precipitation = precipitation;
	}
	final String? publicDate = jsonConvert.convert<String>(json['publicDate']);
	if (publicDate != null) {
		weatherEntity.publicDate = publicDate;
	}
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		weatherEntity.date = date;
	}
	final String? aqi = jsonConvert.convert<String>(json['aqi']);
	if (aqi != null) {
		weatherEntity.aqi = aqi;
	}
	final String? pmindex = jsonConvert.convert<String>(json['pmindex']);
	if (pmindex != null) {
		weatherEntity.pmindex = pmindex;
	}
	final String? pmval = jsonConvert.convert<String>(json['pmval']);
	if (pmval != null) {
		weatherEntity.pmval = pmval;
	}
	return weatherEntity;
}

Map<String, dynamic> $WeatherEntityToJson(WeatherEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['wetness'] = entity.wetness;
	data['grade'] = entity.grade;
	data['windForce'] = entity.windForce;
	data['windDirection'] = entity.windDirection;
	data['weatherStatus'] = entity.weatherStatus;
	data['weatherCode'] = entity.weatherCode;
	data['precipitation'] = entity.precipitation;
	data['publicDate'] = entity.publicDate;
	data['date'] = entity.date;
	data['aqi'] = entity.aqi;
	data['pmindex'] = entity.pmindex;
	data['pmval'] = entity.pmval;
	return data;
}