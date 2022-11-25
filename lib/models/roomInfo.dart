import 'package:json_annotation/json_annotation.dart';
import "device.dart";
part 'roomInfo.g.dart';

@JsonSerializable()
class RoomInfo {
  RoomInfo();

  late String roomId;
  late String name;
  late String des;
  late String icon;
  late String isDefault;
  late List<Device> applianceList;
  
  factory RoomInfo.fromJson(Map<String,dynamic> json) => _$RoomInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomInfoToJson(this);
}
