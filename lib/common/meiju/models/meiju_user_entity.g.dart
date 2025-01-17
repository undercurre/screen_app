import '../generated/json/base/meiju_json_convert_content.dart';
import 'meiju_user_entity.dart';

MeiJuTokenEntity $MeiJuTokenEntityFromJson(Map<String, dynamic> json) {
	final MeiJuTokenEntity userEntity = MeiJuTokenEntity();
	final String? accessToken = meijuJsonConvert.convert<String>(json['accessToken']);
	if (accessToken != null) {
		userEntity.accessToken = accessToken;
	}
	final String? deviceId = meijuJsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		userEntity.deviceId = deviceId;
	}
	final String? iotUserId = meijuJsonConvert.convert<String>(json['iotUserId']);
	if (iotUserId != null) {
		userEntity.iotUserId = iotUserId;
	}
	final String? key = meijuJsonConvert.convert<String>(json['key']);
	if (key != null) {
		userEntity.key = key;
	}
	final String? openId = meijuJsonConvert.convert<String>(json['openId']);
	if (openId != null) {
		userEntity.openId = openId;
	}
	final String? seed = meijuJsonConvert.convert<String>(json['seed']);
	if (seed != null) {
		userEntity.seed = seed;
	}
	final String? sessionId = meijuJsonConvert.convert<String>(json['sessionId']);
	if (sessionId != null) {
		userEntity.sessionId = sessionId;
	}
	final String? tokenPwd = meijuJsonConvert.convert<String>(json['tokenPwd']);
	if (tokenPwd != null) {
		userEntity.tokenPwd = tokenPwd;
	}
	final String? uid = meijuJsonConvert.convert<String>(json['uid']);
	if (uid != null) {
		userEntity.uid = uid;
	}
	final String? mzAccessToken = meijuJsonConvert.convert<String>(json['mzAccessToken']);
	if (mzAccessToken != null) {
		userEntity.mzAccessToken = mzAccessToken;
	}
	final int? expired = meijuJsonConvert.convert<int>(json['expired']);
	if (expired != null) {
		userEntity.expired = expired;
	}
	return userEntity;
}

Map<String, dynamic> $MeiJuTokenEntityToJson(MeiJuTokenEntity entity) {
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