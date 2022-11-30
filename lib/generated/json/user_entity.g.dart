import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/user_entity.dart';

UserEntity $UserEntityFromJson(Map<String, dynamic> json) {
	final UserEntity userEntity = UserEntity();
	final String? accessToken = jsonConvert.convert<String>(json['accessToken']);
	if (accessToken != null) {
		userEntity.accessToken = accessToken;
	}
	final String? deviceId = jsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		userEntity.deviceId = deviceId;
	}
	final String? iotUserId = jsonConvert.convert<String>(json['iotUserId']);
	if (iotUserId != null) {
		userEntity.iotUserId = iotUserId;
	}
	final String? key = jsonConvert.convert<String>(json['key']);
	if (key != null) {
		userEntity.key = key;
	}
	final String? openId = jsonConvert.convert<String>(json['openId']);
	if (openId != null) {
		userEntity.openId = openId;
	}
	final String? seed = jsonConvert.convert<String>(json['seed']);
	if (seed != null) {
		userEntity.seed = seed;
	}
	final String? sessionId = jsonConvert.convert<String>(json['sessionId']);
	if (sessionId != null) {
		userEntity.sessionId = sessionId;
	}
	final String? tokenPwd = jsonConvert.convert<String>(json['tokenPwd']);
	if (tokenPwd != null) {
		userEntity.tokenPwd = tokenPwd;
	}
	final String? uid = jsonConvert.convert<String>(json['uid']);
	if (uid != null) {
		userEntity.uid = uid;
	}
	final String? mzAccessToken = jsonConvert.convert<String>(json['mzAccessToken']);
	if (mzAccessToken != null) {
		userEntity.mzAccessToken = mzAccessToken;
	}
	final int? expired = jsonConvert.convert<int>(json['expired']);
	if (expired != null) {
		userEntity.expired = expired;
	}
	return userEntity;
}

Map<String, dynamic> $UserEntityToJson(UserEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['accessToken'] = entity.accessToken;
	data['deviceId'] = entity.deviceId;
	data['iotUserId'] = entity.iotUserId;
	data['key'] = entity.key;
	data['openId'] = entity.openId;
	data['seed'] = entity.seed;
	data['sessionId'] = entity.sessionId;
	data['tokenPwd'] = entity.tokenPwd;
	data['uid'] = entity.uid;
	data['mzAccessToken'] = entity.mzAccessToken;
	data['expired'] = entity.expired;
	return data;
}