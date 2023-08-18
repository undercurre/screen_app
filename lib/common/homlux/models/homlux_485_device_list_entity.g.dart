import 'package:screen_app/common/homlux/generated/json/base/homlux_json_convert_content.dart';
import 'package:screen_app/common/homlux/models/homlux_485_device_list_entity.dart';

Homlux485DeviceListEntity $Homlux485DeviceListEntityFromJson(Map<String, dynamic> json) {
  final Homlux485DeviceListEntity homlux485DeviceListEntity = Homlux485DeviceListEntity();
  final Homlux485DeviceListNameValuePairs? nameValuePairs = homluxJsonConvert.convert<Homlux485DeviceListNameValuePairs>(json['nameValuePairs']);
  if (nameValuePairs != null) {
    homlux485DeviceListEntity.nameValuePairs = nameValuePairs;
  }
  return homlux485DeviceListEntity;
}

Map<String, dynamic> $Homlux485DeviceListEntityToJson(Homlux485DeviceListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['nameValuePairs'] = entity.nameValuePairs?.toJson();
  return data;
}

extension Homlux485DeviceListEntityExtension on Homlux485DeviceListEntity {
  Homlux485DeviceListEntity copyWith({
    Homlux485DeviceListNameValuePairs? nameValuePairs,
  }) {
    return Homlux485DeviceListEntity()
      ..nameValuePairs = nameValuePairs ?? this.nameValuePairs;
  }
}

Homlux485DeviceListNameValuePairs $Homlux485DeviceListNameValuePairsFromJson(Map<String, dynamic> json) {
  final Homlux485DeviceListNameValuePairs homlux485DeviceListNameValuePairs = Homlux485DeviceListNameValuePairs();
  final List<Homlux485DeviceListNameValuePairsAirConditionList>? airConditionList = (json['AirConditionList'] as List<dynamic>?)?.map(
          (e) => homluxJsonConvert.convert<Homlux485DeviceListNameValuePairsAirConditionList>(e) as Homlux485DeviceListNameValuePairsAirConditionList).toList();
  if (airConditionList != null) {
    homlux485DeviceListNameValuePairs.airConditionList = airConditionList;
  }
  final List<Homlux485DeviceListNameValuePairsFreshAirList>? freshAirList = (json['FreshAirList'] as List<dynamic>?)?.map(
          (e) => homluxJsonConvert.convert<Homlux485DeviceListNameValuePairsFreshAirList>(e) as Homlux485DeviceListNameValuePairsFreshAirList).toList();
  if (freshAirList != null) {
    homlux485DeviceListNameValuePairs.freshAirList = freshAirList;
  }
  final List<Homlux485DeviceListNameValuePairsFloorHotList>? floorHotList = (json['FloorHotList'] as List<dynamic>?)?.map(
          (e) => homluxJsonConvert.convert<Homlux485DeviceListNameValuePairsFloorHotList>(e) as Homlux485DeviceListNameValuePairsFloorHotList).toList();
  if (floorHotList != null) {
    homlux485DeviceListNameValuePairs.floorHotList = floorHotList;
  }
  return homlux485DeviceListNameValuePairs;
}

Map<String, dynamic> $Homlux485DeviceListNameValuePairsToJson(Homlux485DeviceListNameValuePairs entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['AirConditionList'] = entity.airConditionList?.map((v) => v.toJson()).toList();
  data['FreshAirList'] = entity.freshAirList?.map((v) => v.toJson()).toList();
  data['FloorHotList'] = entity.floorHotList?.map((v) => v.toJson()).toList();
  return data;
}

extension Homlux485DeviceListNameValuePairsExtension on Homlux485DeviceListNameValuePairs {
  Homlux485DeviceListNameValuePairs copyWith({
    List<Homlux485DeviceListNameValuePairsAirConditionList>? airConditionList,
    List<Homlux485DeviceListNameValuePairsFreshAirList>? freshAirList,
    List<Homlux485DeviceListNameValuePairsFloorHotList>? floorHotList,
  }) {
    return Homlux485DeviceListNameValuePairs()
      ..airConditionList = airConditionList ?? this.airConditionList
      ..freshAirList = freshAirList ?? this.freshAirList
      ..floorHotList = floorHotList ?? this.floorHotList;
  }
}

Homlux485DeviceListNameValuePairsAirConditionList $Homlux485DeviceListNameValuePairsAirConditionListFromJson(Map<String, dynamic> json) {
  final Homlux485DeviceListNameValuePairsAirConditionList homlux485DeviceListNameValuePairsAirConditionList = Homlux485DeviceListNameValuePairsAirConditionList();
  final String? currTemperature = homluxJsonConvert.convert<String>(json['CurrTemperature']);
  if (currTemperature != null) {
    homlux485DeviceListNameValuePairsAirConditionList.currTemperature = currTemperature;
  }
  final String? onOff = homluxJsonConvert.convert<String>(json['OnOff']);
  if (onOff != null) {
    homlux485DeviceListNameValuePairsAirConditionList.onOff = onOff;
  }
  final String? errorCode = homluxJsonConvert.convert<String>(json['errorCode']);
  if (errorCode != null) {
    homlux485DeviceListNameValuePairsAirConditionList.errorCode = errorCode;
  }
  final String? inSideAddress = homluxJsonConvert.convert<String>(json['inSideAddress']);
  if (inSideAddress != null) {
    homlux485DeviceListNameValuePairsAirConditionList.inSideAddress = inSideAddress;
  }
  final String? onlineState = homluxJsonConvert.convert<String>(json['onlineState']);
  if (onlineState != null) {
    homlux485DeviceListNameValuePairsAirConditionList.onlineState = onlineState;
  }
  final String? outSideAddress = homluxJsonConvert.convert<String>(json['outSideAddress']);
  if (outSideAddress != null) {
    homlux485DeviceListNameValuePairsAirConditionList.outSideAddress = outSideAddress;
  }
  final String? temperature = homluxJsonConvert.convert<String>(json['temperature']);
  if (temperature != null) {
    homlux485DeviceListNameValuePairsAirConditionList.temperature = temperature;
  }
  final String? windSpeed = homluxJsonConvert.convert<String>(json['windSpeed']);
  if (windSpeed != null) {
    homlux485DeviceListNameValuePairsAirConditionList.windSpeed = windSpeed;
  }
  final String? workModel = homluxJsonConvert.convert<String>(json['workModel']);
  if (workModel != null) {
    homlux485DeviceListNameValuePairsAirConditionList.workModel = workModel;
  }
  return homlux485DeviceListNameValuePairsAirConditionList;
}

Map<String, dynamic> $Homlux485DeviceListNameValuePairsAirConditionListToJson(Homlux485DeviceListNameValuePairsAirConditionList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['CurrTemperature'] = entity.currTemperature;
  data['OnOff'] = entity.onOff;
  data['errorCode'] = entity.errorCode;
  data['inSideAddress'] = entity.inSideAddress;
  data['onlineState'] = entity.onlineState;
  data['outSideAddress'] = entity.outSideAddress;
  data['temperature'] = entity.temperature;
  data['windSpeed'] = entity.windSpeed;
  data['workModel'] = entity.workModel;
  return data;
}

extension Homlux485DeviceListNameValuePairsAirConditionListExtension on Homlux485DeviceListNameValuePairsAirConditionList {
  Homlux485DeviceListNameValuePairsAirConditionList copyWith({
    String? currTemperature,
    String? onOff,
    String? errorCode,
    String? inSideAddress,
    String? onlineState,
    String? outSideAddress,
    String? temperature,
    String? windSpeed,
    String? workModel,
  }) {
    return Homlux485DeviceListNameValuePairsAirConditionList()
      ..currTemperature = currTemperature ?? this.currTemperature
      ..onOff = onOff ?? this.onOff
      ..errorCode = errorCode ?? this.errorCode
      ..inSideAddress = inSideAddress ?? this.inSideAddress
      ..onlineState = onlineState ?? this.onlineState
      ..outSideAddress = outSideAddress ?? this.outSideAddress
      ..temperature = temperature ?? this.temperature
      ..windSpeed = windSpeed ?? this.windSpeed
      ..workModel = workModel ?? this.workModel;
  }
}

Homlux485DeviceListNameValuePairsFreshAirList $Homlux485DeviceListNameValuePairsFreshAirListFromJson(Map<String, dynamic> json) {
  final Homlux485DeviceListNameValuePairsFreshAirList homlux485DeviceListNameValuePairsFreshAirList = Homlux485DeviceListNameValuePairsFreshAirList();
  final String? onOff = homluxJsonConvert.convert<String>(json['OnOff']);
  if (onOff != null) {
    homlux485DeviceListNameValuePairsFreshAirList.onOff = onOff;
  }
  final String? errorCode = homluxJsonConvert.convert<String>(json['errorCode']);
  if (errorCode != null) {
    homlux485DeviceListNameValuePairsFreshAirList.errorCode = errorCode;
  }
  final String? inSideAddress = homluxJsonConvert.convert<String>(json['inSideAddress']);
  if (inSideAddress != null) {
    homlux485DeviceListNameValuePairsFreshAirList.inSideAddress = inSideAddress;
  }
  final String? onlineState = homluxJsonConvert.convert<String>(json['onlineState']);
  if (onlineState != null) {
    homlux485DeviceListNameValuePairsFreshAirList.onlineState = onlineState;
  }
  final String? outSideAddress = homluxJsonConvert.convert<String>(json['outSideAddress']);
  if (outSideAddress != null) {
    homlux485DeviceListNameValuePairsFreshAirList.outSideAddress = outSideAddress;
  }
  final String? windSpeed = homluxJsonConvert.convert<String>(json['windSpeed']);
  if (windSpeed != null) {
    homlux485DeviceListNameValuePairsFreshAirList.windSpeed = windSpeed;
  }
  final String? workModel = homluxJsonConvert.convert<String>(json['workModel']);
  if (workModel != null) {
    homlux485DeviceListNameValuePairsFreshAirList.workModel = workModel;
  }
  return homlux485DeviceListNameValuePairsFreshAirList;
}

Map<String, dynamic> $Homlux485DeviceListNameValuePairsFreshAirListToJson(Homlux485DeviceListNameValuePairsFreshAirList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['OnOff'] = entity.onOff;
  data['errorCode'] = entity.errorCode;
  data['inSideAddress'] = entity.inSideAddress;
  data['onlineState'] = entity.onlineState;
  data['outSideAddress'] = entity.outSideAddress;
  data['windSpeed'] = entity.windSpeed;
  data['workModel'] = entity.workModel;
  return data;
}

extension Homlux485DeviceListNameValuePairsFreshAirListExtension on Homlux485DeviceListNameValuePairsFreshAirList {
  Homlux485DeviceListNameValuePairsFreshAirList copyWith({
    String? onOff,
    String? errorCode,
    String? inSideAddress,
    String? onlineState,
    String? outSideAddress,
    String? windSpeed,
    String? workModel,
  }) {
    return Homlux485DeviceListNameValuePairsFreshAirList()
      ..onOff = onOff ?? this.onOff
      ..errorCode = errorCode ?? this.errorCode
      ..inSideAddress = inSideAddress ?? this.inSideAddress
      ..onlineState = onlineState ?? this.onlineState
      ..outSideAddress = outSideAddress ?? this.outSideAddress
      ..windSpeed = windSpeed ?? this.windSpeed
      ..workModel = workModel ?? this.workModel;
  }
}

Homlux485DeviceListNameValuePairsFloorHotList $Homlux485DeviceListNameValuePairsFloorHotListFromJson(Map<String, dynamic> json) {
  final Homlux485DeviceListNameValuePairsFloorHotList homlux485DeviceListNameValuePairsFloorHotList = Homlux485DeviceListNameValuePairsFloorHotList();
  final String? currTemperature = homluxJsonConvert.convert<String>(json['CurrTemperature']);
  if (currTemperature != null) {
    homlux485DeviceListNameValuePairsFloorHotList.currTemperature = currTemperature;
  }
  final String? onOff = homluxJsonConvert.convert<String>(json['OnOff']);
  if (onOff != null) {
    homlux485DeviceListNameValuePairsFloorHotList.onOff = onOff;
  }
  final String? errorCode = homluxJsonConvert.convert<String>(json['errorCode']);
  if (errorCode != null) {
    homlux485DeviceListNameValuePairsFloorHotList.errorCode = errorCode;
  }
  final String? frostProtection = homluxJsonConvert.convert<String>(json['frostProtection']);
  if (frostProtection != null) {
    homlux485DeviceListNameValuePairsFloorHotList.frostProtection = frostProtection;
  }
  final String? inSideAddress = homluxJsonConvert.convert<String>(json['inSideAddress']);
  if (inSideAddress != null) {
    homlux485DeviceListNameValuePairsFloorHotList.inSideAddress = inSideAddress;
  }
  final String? onlineState = homluxJsonConvert.convert<String>(json['onlineState']);
  if (onlineState != null) {
    homlux485DeviceListNameValuePairsFloorHotList.onlineState = onlineState;
  }
  final String? outSideAddress = homluxJsonConvert.convert<String>(json['outSideAddress']);
  if (outSideAddress != null) {
    homlux485DeviceListNameValuePairsFloorHotList.outSideAddress = outSideAddress;
  }
  final String? temperature = homluxJsonConvert.convert<String>(json['temperature']);
  if (temperature != null) {
    homlux485DeviceListNameValuePairsFloorHotList.temperature = temperature;
  }
  return homlux485DeviceListNameValuePairsFloorHotList;
}

Map<String, dynamic> $Homlux485DeviceListNameValuePairsFloorHotListToJson(Homlux485DeviceListNameValuePairsFloorHotList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['CurrTemperature'] = entity.currTemperature;
  data['OnOff'] = entity.onOff;
  data['errorCode'] = entity.errorCode;
  data['frostProtection'] = entity.frostProtection;
  data['inSideAddress'] = entity.inSideAddress;
  data['onlineState'] = entity.onlineState;
  data['outSideAddress'] = entity.outSideAddress;
  data['temperature'] = entity.temperature;
  return data;
}

extension Homlux485DeviceListNameValuePairsFloorHotListExtension on Homlux485DeviceListNameValuePairsFloorHotList {
  Homlux485DeviceListNameValuePairsFloorHotList copyWith({
    String? currTemperature,
    String? onOff,
    String? errorCode,
    String? frostProtection,
    String? inSideAddress,
    String? onlineState,
    String? outSideAddress,
    String? temperature,
  }) {
    return Homlux485DeviceListNameValuePairsFloorHotList()
      ..currTemperature = currTemperature ?? this.currTemperature
      ..onOff = onOff ?? this.onOff
      ..errorCode = errorCode ?? this.errorCode
      ..frostProtection = frostProtection ?? this.frostProtection
      ..inSideAddress = inSideAddress ?? this.inSideAddress
      ..onlineState = onlineState ?? this.onlineState
      ..outSideAddress = outSideAddress ?? this.outSideAddress
      ..temperature = temperature ?? this.temperature;
  }
}