import 'package:screen_app/generated/json/base/json_convert_content.dart';
import 'package:screen_app/channel/models/music_state.dart';
import 'package:json_annotation/json_annotation.dart';


AiMusicState $AiMusicStateFromJson(Map<String, dynamic> json) {
	final AiMusicState aiMusicState = AiMusicState();
	final int? playState = jsonConvert.convert<int>(json['playState']);
	if (playState != null) {
		aiMusicState.playState = playState;
	}
	final String? songName = jsonConvert.convert<String>(json['songName']);
	if (songName != null) {
		aiMusicState.songName = songName;
	}
	final String? singerName = jsonConvert.convert<String>(json['singerName']);
	if (singerName != null) {
		aiMusicState.singerName = singerName;
	}
	final String? imgUrl = jsonConvert.convert<String>(json['imgUrl']);
	if (imgUrl != null) {
		aiMusicState.imgUrl = imgUrl;
	}
	return aiMusicState;
}

Map<String, dynamic> $AiMusicStateToJson(AiMusicState entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['playState'] = entity.playState;
	data['songName'] = entity.songName;
	data['singerName'] = entity.singerName;
	data['imgUrl'] = entity.imgUrl;
	return data;
}