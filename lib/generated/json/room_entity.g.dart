import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/models/room_entity.dart';


RoomEntity $RoomEntityFromJson(Map<String, dynamic> json) {
	final RoomEntity roomEntity = RoomEntity();
	final String? roomId = jsonConvert.convert<String>(json['roomId']);
	if (roomId != null) {
		roomEntity.roomId = roomId;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		roomEntity.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		roomEntity.name = name;
	}
	final String? des = jsonConvert.convert<String>(json['des']);
	if (des != null) {
		roomEntity.des = des;
	}
	final String? icon = jsonConvert.convert<String>(json['icon']);
	if (icon != null) {
		roomEntity.icon = icon;
	}
	final String? isDefault = jsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		roomEntity.isDefault = isDefault;
	}
	final List<DeviceEntity>? applianceList = jsonConvert.convertListNotNull<DeviceEntity>(json['applianceList']);
	if (applianceList != null) {
		roomEntity.applianceList = applianceList;
	}
	return roomEntity;
}

Map<String, dynamic> $RoomEntityToJson(RoomEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['roomId'] = entity.roomId;
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['des'] = entity.des;
	data['icon'] = entity.icon;
	data['isDefault'] = entity.isDefault;
	data['applianceList'] =  entity.applianceList.map((v) => v.toJson()).toList();
	return data;
}