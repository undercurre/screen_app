// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device()
  ..applianceCode = json['applianceCode'] as String
  ..sn = json['sn'] as String
  ..onlineStatus = json['onlineStatus'] as String
  ..type = json['type'] as String
  ..modelNumber = json['modelNumber'] as String
  ..name = json['name'] as String
  ..des = json['des'] as String
  ..activeStatus = json['activeStatus'] as String
  ..activeTime = json['activeTime'] as String
  ..isSupportFetchStatus = json['isSupportFetchStatus'] as String
  ..cardStatus = json['cardStatus'] as String
  ..hotspotName = json['hotspotName'] as String
  ..equipmentType = json['equipmentType'] as num
  ..masterId = json['masterId'] as String
  ..attrs = json['attrs'] as String
  ..btMac = json['btMac'] as String
  ..btToken = json['btToken'] as String
  ..sn8 = json['sn8'] as String?
  ..isOtherEquipment = json['isOtherEquipment'] as String
  ..bindType = json['bindType'] as num
  ..ability = json['ability'] as Map<String, dynamic>
  ..moduleType = json['moduleType'] as String;

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'applianceCode': instance.applianceCode,
      'sn': instance.sn,
      'onlineStatus': instance.onlineStatus,
      'type': instance.type,
      'modelNumber': instance.modelNumber,
      'name': instance.name,
      'des': instance.des,
      'activeStatus': instance.activeStatus,
      'activeTime': instance.activeTime,
      'isSupportFetchStatus': instance.isSupportFetchStatus,
      'cardStatus': instance.cardStatus,
      'hotspotName': instance.hotspotName,
      'equipmentType': instance.equipmentType,
      'masterId': instance.masterId,
      'attrs': instance.attrs,
      'btMac': instance.btMac,
      'btToken': instance.btToken,
      'sn8': instance.sn8,
      'isOtherEquipment': instance.isOtherEquipment,
      'bindType': instance.bindType,
      'ability': instance.ability,
      'moduleType': instance.moduleType,
    };
