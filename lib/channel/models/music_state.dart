import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AiMusicState {
  AiMusicState();

  int playState = 0;
  String songName = "";
  String singerName = "";
  String imgUrl = "";

  factory AiMusicState.fromJson(Map<dynamic, dynamic> map) => _$AiMusicFromJson(map);

  Map<String, dynamic> toJson() => _$AiMusicToJson(this);
}

_$AiMusicToJson(AiMusicState instance) =>
    <String, dynamic>{
      'playState': instance.playState,
      'songName': instance.songName,
      'singerName': instance.singerName,
      'imgUrl': instance.imgUrl,
    };

_$AiMusicFromJson(Map<dynamic, dynamic> map) {
  AiMusicState state = AiMusicState();
  state.playState = map['playState'] ?? 0;
  state.songName = map['songName'] ?? "";
  state.singerName = map['singerName'] ?? "";
  state.imgUrl = map['imgUrl'] ?? "";
  return state;
}

