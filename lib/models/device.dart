import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  Device();

  @JsonKey() dynamic bindType;
  late String applianceCode;
  late String sn;
  late String onlineStatus;
  late String type;
  late String modelNumber;
  late String name;
  String? des;
  late String activeStatus;
  late String activeTime;
  late String isSupportFetchStatus;
  String? cardStatus;
  late String hotspotName;
  late String masterId;
  late String attrs;
  String? btMac;
  late String btToken;
  String? sn8;
  late String isOtherEquipment;
  late Map<String,dynamic> ability;
  String? moduleType;
  
  factory Device.fromJson(Map<String,dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
