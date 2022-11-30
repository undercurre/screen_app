import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/home_entity.dart';
import 'package:screen_app/models/room_entity.dart';


HomeEntity $HomeEntityFromJson(Map<String, dynamic> json) {
	final HomeEntity homeEntity = HomeEntity();
	final String? homegroupId = jsonConvert.convert<String>(json['homegroupId']);
	if (homegroupId != null) {
		homeEntity.homegroupId = homegroupId;
	}
	final String? number = jsonConvert.convert<String>(json['number']);
	if (number != null) {
		homeEntity.number = number;
	}
	final String? roleId = jsonConvert.convert<String>(json['roleId']);
	if (roleId != null) {
		homeEntity.roleId = roleId;
	}
	final String? isDefault = jsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		homeEntity.isDefault = isDefault;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		homeEntity.name = name;
	}
	final String? nickname = jsonConvert.convert<String>(json['nickname']);
	if (nickname != null) {
		homeEntity.nickname = nickname;
	}
	final String? des = jsonConvert.convert<String>(json['des']);
	if (des != null) {
		homeEntity.des = des;
	}
	final String? address = jsonConvert.convert<String>(json['address']);
	if (address != null) {
		homeEntity.address = address;
	}
	final String? profilePicUrl = jsonConvert.convert<String>(json['profilePicUrl']);
	if (profilePicUrl != null) {
		homeEntity.profilePicUrl = profilePicUrl;
	}
	final String? coordinate = jsonConvert.convert<String>(json['coordinate']);
	if (coordinate != null) {
		homeEntity.coordinate = coordinate;
	}
	final String? areaId = jsonConvert.convert<String>(json['areaid']);
	if (areaId != null) {
		homeEntity.areaId = areaId;
	}
	final String? createTime = jsonConvert.convert<String>(json['createTime']);
	if (createTime != null) {
		homeEntity.createTime = createTime;
	}
	final String? createUserUid = jsonConvert.convert<String>(json['createUserUid']);
	if (createUserUid != null) {
		homeEntity.createUserUid = createUserUid;
	}
	final String? roomCount = jsonConvert.convert<String>(json['roomCount']);
	if (roomCount != null) {
		homeEntity.roomCount = roomCount;
	}
	final String? applianceCount = jsonConvert.convert<String>(json['applianceCount']);
	if (applianceCount != null) {
		homeEntity.applianceCount = applianceCount;
	}
	final String? memberCount = jsonConvert.convert<String>(json['memberCount']);
	if (memberCount != null) {
		homeEntity.memberCount = memberCount;
	}
	final dynamic? members = jsonConvert.convert<dynamic>(json['members']);
	if (members != null) {
		homeEntity.members = members;
	}
	final int? unread = jsonConvert.convert<int>(json['unread']);
	if (unread != null) {
		homeEntity.unread = unread;
	}
	final List<RoomEntity>? roomList = jsonConvert.convertListNotNull<RoomEntity>(json['roomList']);
	if (roomList != null) {
		homeEntity.roomList = roomList;
	}
	return homeEntity;
}

Map<String, dynamic> $HomeEntityToJson(HomeEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['homegroupId'] = entity.homegroupId;
	data['number'] = entity.number;
	data['roleId'] = entity.roleId;
	data['isDefault'] = entity.isDefault;
	data['name'] = entity.name;
	data['nickname'] = entity.nickname;
	data['des'] = entity.des;
	data['address'] = entity.address;
	data['profilePicUrl'] = entity.profilePicUrl;
	data['coordinate'] = entity.coordinate;
	data['areaid'] = entity.areaId;
	data['createTime'] = entity.createTime;
	data['createUserUid'] = entity.createUserUid;
	data['roomCount'] = entity.roomCount;
	data['applianceCount'] = entity.applianceCount;
	data['memberCount'] = entity.memberCount;
	data['members'] = entity.members;
	data['unread'] = entity.unread;
	data['roomList'] =  entity.roomList?.map((v) => v.toJson()).toList();
	return data;
}