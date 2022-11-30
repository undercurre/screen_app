import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/location_entity.dart';

LocationEntity $LocationEntityFromJson(Map<String, dynamic> json) {
	final LocationEntity locationEntity = LocationEntity();
	final String? provinceName = jsonConvert.convert<String>(json['provinceName']);
	if (provinceName != null) {
		locationEntity.provinceName = provinceName;
	}
	final String? cityName = jsonConvert.convert<String>(json['cityName']);
	if (cityName != null) {
		locationEntity.cityName = cityName;
	}
	final String? coordinate = jsonConvert.convert<String>(json['coordinate']);
	if (coordinate != null) {
		locationEntity.coordinate = coordinate;
	}
	final String? fullName = jsonConvert.convert<String>(json['fullName']);
	if (fullName != null) {
		locationEntity.fullName = fullName;
	}
	final String? enName = jsonConvert.convert<String>(json['enName']);
	if (enName != null) {
		locationEntity.enName = enName;
	}
	final String? chName = jsonConvert.convert<String>(json['chName']);
	if (chName != null) {
		locationEntity.chName = chName;
	}
	final String? pyName = jsonConvert.convert<String>(json['pyName']);
	if (pyName != null) {
		locationEntity.pyName = pyName;
	}
	final String? cityNo = jsonConvert.convert<String>(json['cityNo']);
	if (cityNo != null) {
		locationEntity.cityNo = cityNo;
	}
	final String? countryName = jsonConvert.convert<String>(json['countryName']);
	if (countryName != null) {
		locationEntity.countryName = countryName;
	}
	return locationEntity;
}

Map<String, dynamic> $LocationEntityToJson(LocationEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['provinceName'] = entity.provinceName;
	data['cityName'] = entity.cityName;
	data['coordinate'] = entity.coordinate;
	data['fullName'] = entity.fullName;
	data['enName'] = entity.enName;
	data['chName'] = entity.chName;
	data['pyName'] = entity.pyName;
	data['cityNo'] = entity.cityNo;
	data['countryName'] = entity.countryName;
	return data;
}