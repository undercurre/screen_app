import 'package:json_annotation/json_annotation.dart';

part 'sceneInfo.g.dart';

@JsonSerializable()
class SceneInfo {
  SceneInfo();

  @JsonKey() dynamic appId;
  late String image;
  late String eventLogical;
  late String updateTime;
  late num homegroupId;
  late String version;
  late String weekly;
  late num sceneType;
  late String createTime;
  late num enable;
  late num sceneId;
  late String name;
  
  factory SceneInfo.fromJson(Map<String,dynamic> json) => _$SceneInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SceneInfoToJson(this);
}
