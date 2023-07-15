import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_home_entity.dart';
import 'meiju_room_entity.dart';



MeiJuHomeEntity $MeiJuHomeEntityFromJson(Map<String, dynamic> json) {
	final MeiJuHomeEntity homeEntity = MeiJuHomeEntity();
	final String? homegroupId = meijuJsonConvert.convert<String>(json['homegroupId']);
	if (homegroupId != null) {
		homeEntity.homegroupId = homegroupId;
	}
	final String? number = meijuJsonConvert.convert<String>(json['number']);
	if (number != null) {
		homeEntity.number = number;
	}
	final String? roleId = meijuJsonConvert.convert<String>(json['roleId']);
	if (roleId != null) {
		homeEntity.roleId = roleId;
	}
	final String? isDefault = meijuJsonConvert.convert<String>(json['isDefault']);
	if (isDefault != null) {
		homeEntity.isDefault = isDefault;
	}
	final String? name = meijuJsonConvert.convert<String>(json['name']);
	if (name != null) {
		homeEntity.name = name;
	}
	final String? nickname = meijuJsonConvert.convert<String>(json['nickname']);
	if (nickname != null) {
		homeEntity.nickname = nickname;
	}
	final String? des = meijuJsonConvert.convert<String>(json['des']);
	if (des != null) {
		homeEntity.des = des;
	}
	final String? address = meijuJsonConvert.convert<String>(json['address']);
	if (address != null) {
		homeEntity.address = address;
	}
	final String? profilePicUrl = meijuJsonConvert.convert<String>(json['profilePicUrl']);
	if (profilePicUrl != null) {
		homeEntity.profilePicUrl = profilePicUrl;
	}
	final String? coordinate = meijuJsonConvert.convert<String>(json['coordinate']);
	if (coordinate != null) {
		homeEntity.coordinate = coordinate;
	}
	final String? areaId = meijuJsonConvert.convert<String>(json['areaid']);
	if (areaId != null) {
		homeEntity.areaId = areaId;
	}
	final String? createTime = meijuJsonConvert.convert<String>(json['createTime']);
	if (createTime != null) {
		homeEntity.createTime = createTime;
	}
	final String? createUserUid = meijuJsonConvert.convert<String>(json['createUserUid']);
	if (createUserUid != null) {
		homeEntity.createUserUid = createUserUid;
	}
	final String? roomCount = meijuJsonConvert.convert<String>(json['roomCount']);
	if (roomCount != null) {
		homeEntity.roomCount = roomCount;
	}
	final String? applianceCount = meijuJsonConvert.convert<String>(json['applianceCount']);
	if (applianceCount != null) {
		homeEntity.applianceCount = applianceCount;
	}
	final String? memberCount = meijuJsonConvert.convert<String>(json['memberCount']);
	if (memberCount != null) {
		homeEntity.memberCount = memberCount;
	}
	final dynamic members = meijuJsonConvert.convert<dynamic>(json['members']);
	if (members != null) {
		homeEntity.members = members;
	}
	final int? unread = meijuJsonConvert.convert<int>(json['unread']);
	if (unread != null) {
		homeEntity.unread = unread;
	}
	final List<MeiJuRoomEntity>? roomList = meijuJsonConvert.convertListNotNull<MeiJuRoomEntity>(json['roomList']);
	if (roomList != null) {
		homeEntity.roomList = roomList;
	}
	return homeEntity;
}

Map<String, dynamic> $MeiJuHomeEntityToJson(MeiJuHomeEntity entity) {
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