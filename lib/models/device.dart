import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  Device();

  late String applianceCode;
  late String sn;
  late String onlineStatus;
  late String type;
  late String modelNumber;
  late String name;
  late String des;
  late String activeStatus;
  late String activeTime;
  late String isSupportFetchStatus;
  late String cardStatus;
  late String hotspotName;
  late num equipmentType;
  late String masterId;
  late String attrs;
  late String btMac;
  late String btToken;
  String? sn8;
  late String isOtherEquipment;
  late num bindType;
  late Map<String, dynamic> ability;
  late String moduleType;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
