import 'package:json_annotation/json_annotation.dart';
import "homeList.dart";
part 'homegroupList.g.dart';

@JsonSerializable()
class HomegroupList {
  HomegroupList();

  late List<HomeList> homeList;
  
  factory HomegroupList.fromJson(Map<String,dynamic> json) => _$HomegroupListFromJson(json);
  Map<String, dynamic> toJson() => _$HomegroupListToJson(this);
}
