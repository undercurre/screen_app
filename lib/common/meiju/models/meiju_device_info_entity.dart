
import 'dart:convert';

import 'meiju_device_info_entity.g.dart';

class MeiJuDeviceInfoEntity {

  dynamic templateOfTSL;
  String? isOtherEquipment;
  String? enterprise;
  String? onlineStatus;
  String? btMac;
  dynamic switchStatus;
  String? type;
  String? equipmentType;
  dynamic des;
  String? newAttrs;
  dynamic nfcLabels;
  String? id;
  String? sn;
  MeiJuDeviceInfoAbilityEntity? ability;
  dynamic cardStatus;
  dynamic enterpriseCode;
  bool? supportWot;
  String? activeTime;
  String? bindType;
  String? applianceCode;
  String? roomName;
  dynamic command;
  String? attrs;
  String? btToken;
  String? hotspotName;
  String? masterId;
  dynamic nfcLabelInfos;
  String? activeStatus;
  String? name;
  String? wifiVersion;
  String? isSupportFetchStatus;
  String? modelNumber;
  dynamic smartProductId;
  String? isBluetooth;
  dynamic sn8;
  dynamic nameChanged;
  dynamic status;
  dynamic detail;

  MeiJuDeviceInfoEntity();

  factory MeiJuDeviceInfoEntity.fromJson(Map<String, dynamic> json) => $MeijuDeviceInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeijuDeviceInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class MeiJuDeviceInfoAbilityEntity {

  int? bleAppBindStatus;
  int? supportGateway;
  int? supportWot;
  int? supportBleMesh;
  int? schoolTime;
  int? supportADNS;
  int? supportBleDataTransfers;
  int? supportBindStatus;
  int? supportOfflineMsg;
  int? bleDeviceStatus;
  int? supportNewKeyVersion;
  int? domainSwitch;
  int? supportBindCode;
  int? supportBleOta;
  int? supportReset;
  int? supportRouterReportAndQuery;
  String? isBluetoothControl;
  String? distributionNetworkType;
  int? supportMedia;
  int? supportFindFriends;
  int? supportDiagnosis;
  int? supportQueryToken;
  int? supportNetworkBridge;

  MeiJuDeviceInfoAbilityEntity();

  factory MeiJuDeviceInfoAbilityEntity.fromJson(Map<String, dynamic> json) => $MeijuDeviceInfoAbilityEntityFromJson(json);

  Map<String, dynamic> toJson() => $MeijuDeviceInfoAbilityEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}