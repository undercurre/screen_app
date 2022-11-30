import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/home_list_entity.dart';
import 'package:screen_app/models/home_entity.dart';


HomeListEntity $HomeListEntityFromJson(Map<String, dynamic> json) {
	final HomeListEntity homeListEntity = HomeListEntity();
	final List<HomeEntity>? homeList = jsonConvert.convertListNotNull<HomeEntity>(json['homeList']);
	if (homeList != null) {
		homeListEntity.homeList = homeList;
	}
	return homeListEntity;
}

Map<String, dynamic> $HomeListEntityToJson(HomeListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homeList'] =  entity.homeList.map((v) => v.toJson()).toList();
	return data;
}