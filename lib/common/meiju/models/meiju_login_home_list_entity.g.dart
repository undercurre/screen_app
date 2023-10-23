part of 'meiju_login_home_list_entity.dart';


MeiJuLoginHomeListEntity _$MeiJuLoginHomeListEntityFromJson(Map<String, dynamic> json) {
	final MeiJuLoginHomeListEntity homeListEntity = MeiJuLoginHomeListEntity();
	final List<MeiJuLoginHomeEntity>? homeList = meijuJsonConvert.convertListNotNull<MeiJuLoginHomeEntity>(json['homeList']);
	if (homeList != null) {
		homeListEntity.homeList = homeList;
	}
	return homeListEntity;
}

Map<String, dynamic> _$MeiJuLoginHomeListEntityToJson(MeiJuLoginHomeListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homeList'] =  entity.homeList?.map((v) => v.toJson()).toList();
	return data;
}