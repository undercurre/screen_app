import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/profile_entity.dart';
import 'package:screen_app/models/home_entity.dart';

import 'package:screen_app/models/room_entity.dart';

import 'package:screen_app/models/user_entity.dart';


ProfileEntity $ProfileEntityFromJson(Map<String, dynamic> json) {
	final ProfileEntity profileEntity = ProfileEntity();
	final UserEntity? user = jsonConvert.convert<UserEntity>(json['user']);
	if (user != null) {
		profileEntity.user = user;
	}
	final HomeEntity? homeInfo = jsonConvert.convert<HomeEntity>(json['homeInfo']);
	if (homeInfo != null) {
		profileEntity.homeInfo = homeInfo;
	}
	final RoomEntity? roomInfo = jsonConvert.convert<RoomEntity>(json['roomInfo']);
	if (roomInfo != null) {
		profileEntity.roomInfo = roomInfo;
	}
	final String? deviceId = jsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		profileEntity.deviceId = deviceId;
	}
	final String? deviceSn = jsonConvert.convert<String>(json['deviceSn']);
	if (deviceSn != null) {
		profileEntity.deviceSn = deviceSn;
	}
	final String? applianceCode = jsonConvert.convert<String>(json['applianceCode']);
	if (applianceCode != null) {
		profileEntity.applianceCode = applianceCode;
	}
	final bool? aiEnable = jsonConvert.convert<bool>(json['aiEnable']);
	if (aiEnable != null) {
		profileEntity.aiEnable = aiEnable;
	}
	return profileEntity;
}

Map<String, dynamic> $ProfileEntityToJson(ProfileEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['user'] = entity.user?.toJson();
	data['homeInfo'] = entity.homeInfo?.toJson();
	data['roomInfo'] = entity.roomInfo?.toJson();
	data['deviceId'] = entity.deviceId;
	data['deviceSn'] = entity.deviceSn;
	data['applianceCode'] = entity.applianceCode;
	data['aiEnable'] = entity.aiEnable;
	return data;
}