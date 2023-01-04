import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/models/qr_code_entity.dart';

QrCodeEntity $QrCodeEntityFromJson(Map<String, dynamic> json) {
  final QrCodeEntity qrCodeEntity = QrCodeEntity();
  final int? checkType = jsonConvert.convert<int>(json['checkType']);
  if (checkType != null) {
    qrCodeEntity.checkType = checkType;
  }
  final String? deviceId = jsonConvert.convert<String>(json['deviceId']);
  if (deviceId != null) {
    qrCodeEntity.deviceId = deviceId;
  }
  final int? effectTimeSecond =
      jsonConvert.convert<int>(json['effectTimeSecond']);
  if (effectTimeSecond != null) {
    qrCodeEntity.effectTimeSecond = effectTimeSecond;
  }
  final int? expireTime = jsonConvert.convert<int>(json['expireTime']);
  if (expireTime != null) {
    qrCodeEntity.expireTime = expireTime;
  }
  final String? openId = jsonConvert.convert<String>(json['openId']);
  if (openId != null) {
    qrCodeEntity.openId = openId;
  }
  final String? sessionId = jsonConvert.convert<String>(json['sessionId']);
  if (sessionId != null) {
    qrCodeEntity.sessionId = sessionId;
  }
  final String? shortUrl = jsonConvert.convert<String>(json['shortUrl']);
  if (shortUrl != null) {
    qrCodeEntity.shortUrl = shortUrl;
  }
  return qrCodeEntity;
}

Map<String, dynamic> $QrCodeEntityToJson(QrCodeEntity entity) {
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
