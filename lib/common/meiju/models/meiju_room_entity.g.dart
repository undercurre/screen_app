import 'package:screen_app/models/device_entity.dart';

import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_device_entity.dart';
import 'meiju_room_entity.dart';


MeiJuRoomEntity $MeiJuRoomEntityFromJson(Map<String, dynamic> json) {
	final MeiJuRoomEntity roomEntity = MeiJuRoomEntity();
	final String? roomId = meijuJsonConvert.convert<String>(json['roomId']);
	if (roomId != null) {
		roomEntity.roomId = roomId;
	}
	final String? id = meijuJsonConvert.convert<String>(json['id']);
	if (id != null) {
		roomEntity.id = id;
	}
	final String? name = meijuJsonConvert.convert<String>(json['name']);
	if (name != null) {
		roomEntity.name = name;
	}
	final String? des = meijuJsonConvert.convert<String>(json['des']);
	if (des != null) {
		roomEntity.des = des;
	}
	final String? icon = meijuJsonConvert.convert<String>(json['icon']);
	if (icon != null) {
		roomEntity.icon = icon;
	}
	final String? isDefault = meijuJsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		roomEntity.isDefault = isDefault;
	}
	final List<MeiJuDeviceEntity>? applianceList = meijuJsonConvert.convertListNotNull<MeiJuDeviceEntity>(json['applianceList']);
	if (applianceList != null) {
		roomEntity.applianceList = applianceList;
	}
	return roomEntity;
}

Map<String, dynamic> $MeiJuRoomEntityToJson(MeiJuRoomEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['roomId'] = entity.roomId;
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['des'] = entity.des;
	data['icon'] = entity.icon;
	data['isDefault'] = entity.isDefault;
	data['applianceList'] =  entity.applianceList?.map((v) => v.toJson()).toList();
	return data;
}