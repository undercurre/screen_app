import 'dart:convert';

import 'meiju_delete_device_result_entity.g.dart';


class MeiJuDeleteDeviceResultEntity {
  late List<String> errorList;

  MeiJuDeleteDeviceResultEntity();

  factory MeiJuDeleteDeviceResultEntity.fromJson(Map<String, dynamic> json) =>
      $MeiJuDeleteDeviceResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeiJuDeleteDeviceResultEntityToJson(this);

  MeiJuDeleteDeviceResultEntity copyWith({List<String>? errorList}) {
    return MeiJuDeleteDeviceResultEntity()
      ..errorList = errorList ?? this.errorList;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
