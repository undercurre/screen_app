import 'dart:convert';

import 'package:screen_app/generated/json/base/json_field.dart';

import 'device_entity.g.dart';

@JsonSerializable()
class MeiJuDeviceEntity {
  MeiJuDeviceEntity();

  dynamic bindType;
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
  String? roomName;
  String? roomId;
  late String isOtherEquipment;
  late Map<String, dynamic> ability;
  String? moduleType;
  Map<String, dynamic>? detail;

  factory MeiJuDeviceEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuDeviceEntityFromJson(json);
  Map<String, dynamic> toJson() => $MeiJuDeviceEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
