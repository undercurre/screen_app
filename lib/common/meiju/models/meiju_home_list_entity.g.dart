import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_home_entity.dart';
import 'meiju_home_list_entity.dart';


MeiJuHomeListEntity $MeiJuHomeListEntityFromJson(Map<String, dynamic> json) {
	final MeiJuHomeListEntity homeListEntity = MeiJuHomeListEntity();
	final List<MeiJuHomeEntity>? homeList = meijuJsonConvert.convertListNotNull<MeiJuHomeEntity>(json['homeList']);
	if (homeList != null) {
		homeListEntity.homeList = homeList;
	}
	return homeListEntity;
}

Map<String, dynamic> $MeiJuHomeListEntityToJson(MeiJuHomeListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homeList'] =  entity.homeList?.map((v) => v.toJson()).toList();
	return data;
}