import 'package:json_annotation/json_annotation.dart';
import "sceneInfo.dart";
part 'sceneList.g.dart';

@JsonSerializable()
class SceneList {
  SceneList();

  late num total;
  late List<SceneInfo> list;
  
  factory SceneList.fromJson(Map<String,dynamic> json) => _$SceneListFromJson(json);
  Map<String, dynamic> toJson() => _$SceneListToJson(this);
}
