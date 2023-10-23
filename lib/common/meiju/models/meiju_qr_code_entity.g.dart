import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';

import 'meiju_qr_code_entity.dart';

MeiJuQrCodeEntity $MeiJuQrCodeEntityFromJson(Map<String, dynamic> json) {
	final MeiJuQrCodeEntity qrCodeEntity = MeiJuQrCodeEntity();
	final int? checkType = meijuJsonConvert.convert<int>(json['checkType']);
	if (checkType != null) {
		qrCodeEntity.checkType = checkType;
	}
	final String? deviceId = meijuJsonConvert.convert<String>(json['deviceId']);
	if (deviceId != null) {
		qrCodeEntity.deviceId = deviceId;
	}
	final int? effectTimeSecond = meijuJsonConvert.convert<int>(json['effectTimeSecond']);
	if (effectTimeSecond != null) {
		qrCodeEntity.effectTimeSecond = effectTimeSecond;
	}
	final int? expireTime = meijuJsonConvert.convert<int>(json['expireTime']);
	if (expireTime != null) {
		qrCodeEntity.expireTime = expireTime;
	}
	final String? openId = meijuJsonConvert.convert<String>(json['openId']);
	if (openId != null) {
		qrCodeEntity.openId = openId;
	}
	final String? sessionId = meijuJsonConvert.convert<String>(json['sessionId']);
	if (sessionId != null) {
		qrCodeEntity.sessionId = sessionId;
	}
	final String? shortUrl = meijuJsonConvert.convert<String>(json['shortUrl']);
	if (shortUrl != null) {
		qrCodeEntity.shortUrl = shortUrl;
	}
	return qrCodeEntity;
}

Map<String, dynamic> $MeiJuQrCodeEntityToJson(MeiJuQrCodeEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['checkType'] = entity.checkType;
	data['deviceId'] = entity.deviceId;
	data['effectTimeSecond'] = entity.effectTimeSecond;
	data['expireTime'] = entity.expireTime;
	data['openId'] = entity.openId;
	data['sessionId'] = entity.sessionId;
	data['shortUrl'] = entity.shortUrl;
	return data;
}