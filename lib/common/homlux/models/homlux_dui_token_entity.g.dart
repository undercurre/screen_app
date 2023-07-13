import 'package:screen_app/common/homlux/models/homlux_dui_token_entity.dart';
import '../generated/json/base/homlux_json_convert_content.dart';

HomluxDuiTokenEntity $HomluxDuiTokenEntityFromJson(Map<String, dynamic> json) {
	final HomluxDuiTokenEntity homluxDuiTokenEntity = HomluxDuiTokenEntity();
	final int? refreshTokenExpireTime = homluxJsonConvert.convert<int>(json['refreshTokenExpireTime']);
	if (refreshTokenExpireTime != null) {
		homluxDuiTokenEntity.refreshTokenExpireTime = refreshTokenExpireTime;
	}
	final int? accessTokenExpireTime = homluxJsonConvert.convert<int>(json['accessTokenExpireTime']);
	if (accessTokenExpireTime != null) {
		homluxDuiTokenEntity.accessTokenExpireTime = accessTokenExpireTime;
	}
	final String? accessToken = homluxJsonConvert.convert<String>(json['accessToken']);
	if (accessToken != null) {
		homluxDuiTokenEntity.accessToken = accessToken;
	}
	final String? refreshToken = homluxJsonConvert.convert<String>(json['refreshToken']);
	if (refreshToken != null) {
		homluxDuiTokenEntity.refreshToken = refreshToken;
	}
	return homluxDuiTokenEntity;
}

Map<String, dynamic> $HomluxDuiTokenEntityToJson(HomluxDuiTokenEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['refreshTokenExpireTime'] = entity.refreshTokenExpireTime;
	data['accessTokenExpireTime'] = entity.accessTokenExpireTime;
	data['accessToken'] = entity.accessToken;
	data['refreshToken'] = entity.refreshToken;
	return data;
}