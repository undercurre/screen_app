import 'dart:core';
import '../generated/json/base/meiju_json_convert_content.dart';
part 'auth_device_bath_entity.g.dart';

class MeiJuAuthDeviceBatchEntity {

  List<MeiJuAuthStatus>? applianceAuthList;

  MeiJuAuthDeviceBatchEntity();

  factory MeiJuAuthDeviceBatchEntity.fromJson(Map<String, dynamic> json) => _$AuthDeviceBatchEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDeviceBatchEntityToJson(this);

}

class MeiJuAuthStatus {

   late int applianceCode;

   late int status;

   MeiJuAuthStatus();

   factory MeiJuAuthStatus.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

   Map<String, dynamic> toJson() => _$StatusToJson(this);

}