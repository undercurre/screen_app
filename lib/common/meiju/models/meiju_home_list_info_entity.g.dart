import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_home_info_entity.dart';
import 'meiju_home_list_info_entity.dart';


MeiJuHomeInfoListEntity $MeiJuHomeInfoListEntityFromJson(Map<String, dynamic> json) {
	final MeiJuHomeInfoListEntity homeListEntity = MeiJuHomeInfoListEntity();
	final List<MeiJuHomeInfoEntity>? homeList = meijuJsonConvert.convertListNotNull<MeiJuHomeInfoEntity>(json['homeList']);
	if (homeList != null) {
		homeListEntity.homeList = homeList;
	}
	return homeListEntity;
}

Map<String, dynamic> $MeiJuHomeInfoListEntityToJson(MeiJuHomeInfoListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homeList'] =  entity.homeList?.map((v) => v.toJson()).toList();
	return data;
}