

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/homlux/models/homlux_family_entity.dart';

import '../../../models/homlux_auth_entity.dart';
import '../../../models/homlux_bind_device_entity.dart';
import '../../../models/homlux_device_entity.dart';
import '../../../models/homlux_dui_token_entity.dart';
import '../../../models/homlux_qr_code_auth_entity.dart';
import '../../../models/homlux_qr_code_entity.dart';
import '../../../models/homlux_refresh_token_entity.dart';
import '../../../models/homlux_room_list_entity.dart';
import '../../../models/homlux_scene_entity.dart';
import '../../../models/homlux_weather_entity.dart';

HomluxJsonConvert homluxJsonConvert = HomluxJsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);
typedef EnumConvertFunction<T> = T Function(String value);


class HomluxJsonConvert {

  static final Map<String, JsonConvertFunction> convertFuncMap = {
    (HomluxFamilyEntity).toString(): HomluxFamilyEntity.fromJson,
    (HomluxRoomListEntity).toString(): HomluxRoomListEntity.fromJson,
    (HomluxQrCodeEntity).toString(): HomluxQrCodeEntity.fromJson,
    (HomluxQrCodeAuthEntity).toString(): HomluxQrCodeAuthEntity.fromJson,
    (HomluxRefreshTokenEntity).toString(): HomluxRefreshTokenEntity.fromJson,
    (HomluxRoomInfo).toString(): HomluxRoomInfo.fromJson,
    (HomluxSceneEntity).toString(): HomluxSceneEntity.fromJson,
    (HomluxRoomListEntity).toString(): HomluxRoomListEntity.fromJson,
    (HomluxDeviceEntity).toString(): HomluxDeviceEntity.fromJson,
    (HomluxDeviceSwitchInfoDTOList).toString(): HomluxDeviceSwitchInfoDTOList.fromJson,
    (HomluxDeviceMzgdPropertyDTOList).toString(): HomluxDeviceMzgdPropertyDTOList.fromJson,
    (HomluxDeviceMzgdPropertyDTOList1).toString(): HomluxDeviceMzgdPropertyDTOList1.fromJson,
    (HomluxDeviceMzgdPropertyDTOList2).toString(): HomluxDeviceMzgdPropertyDTOList2.fromJson,
    (HomluxDeviceMzgdPropertyDTOList3).toString(): HomluxDeviceMzgdPropertyDTOList3.fromJson,
    (HomluxDeviceMzgdPropertyDTOList4).toString(): HomluxDeviceMzgdPropertyDTOList4.fromJson,
    (HomluxDuiTokenEntity).toString(): HomluxDuiTokenEntity.fromJson,
    (HomluxBindDeviceEntity).toString(): HomluxBindDeviceEntity.fromJson,
    (HomluxAuthEntity).toString(): HomluxAuthEntity.fromJson,
    (HomluxWeatherEntity).toString(): HomluxWeatherEntity.fromJson,


  };

  static M? _getListChildType<M>(List<Map<String, dynamic>> data) {
    if(<HomluxWeatherEntity>[] is M) {
      return data.map<HomluxWeatherEntity>((e) => HomluxWeatherEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxAuthEntity>[] is M) {
      return data.map<HomluxAuthEntity>((e) => HomluxAuthEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxFamilyEntity>[] is M) {
      return data.map<HomluxFamilyEntity>((e) => HomluxFamilyEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxRoomListEntity>[] is M) {
      return data.map<HomluxRoomListEntity>((e) => HomluxRoomListEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxQrCodeEntity>[] is M) {
      return data.map<HomluxQrCodeEntity>((e) => HomluxQrCodeEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxQrCodeAuthEntity>[] is M) {
      return data.map<HomluxQrCodeAuthEntity>((e) => HomluxQrCodeAuthEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxRefreshTokenEntity>[] is M) {
      return data.map<HomluxRefreshTokenEntity>((e) => HomluxRefreshTokenEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxRoomInfo>[] is M) {
      return data.map<HomluxRoomInfo>((e) => HomluxRoomInfo.fromJson(e)).toList() as M;
    }
    if(<HomluxSceneEntity>[] is M) {
      return data.map<HomluxSceneEntity>((e) => HomluxSceneEntity.fromJson(e)).toList() as M;
    }
    if(<DeviceActions>[] is M) {
      return data.map<DeviceActions>((e) => DeviceActions.fromJson(e)).toList() as M;
    }
    if(<DeviceConditions>[] is M) {
      return data.map<DeviceConditions>((e) => DeviceConditions.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceEntity>[] is M) {
      return data.map<HomluxDeviceEntity>((e) => HomluxDeviceEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceSwitchInfoDTOList>[] is M) {
      return data.map<HomluxDeviceSwitchInfoDTOList>((e) => HomluxDeviceSwitchInfoDTOList.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceMzgdPropertyDTOList>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOList>((e) => HomluxDeviceMzgdPropertyDTOList.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceMzgdPropertyDTOList1>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOList1>((e) => HomluxDeviceMzgdPropertyDTOList1.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceMzgdPropertyDTOList2>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOList2>((e) => HomluxDeviceMzgdPropertyDTOList2.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceMzgdPropertyDTOList3>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOList3>((e) => HomluxDeviceMzgdPropertyDTOList3.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceMzgdPropertyDTOList4>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOList4>((e) => HomluxDeviceMzgdPropertyDTOList4.fromJson(e)).toList() as M;
    }
    if(<HomluxDuiTokenEntity>[] is M) {
      return data.map<HomluxDuiTokenEntity>((e) => HomluxDuiTokenEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxBindDeviceEntity>[] is M) {
      return data.map<HomluxBindDeviceEntity>((e) => HomluxBindDeviceEntity.fromJson(e)).toList() as M;
    }
    debugPrint("${M.toString()} not found");
    return null;
  }


  T? convert<T>(dynamic value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    try {
      return _asT<T>(value, enumConvert: enumConvert);
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return null;
    }
  }

  static M? fromJsonAsT<M>(dynamic json) {
    if (json is List) {
      return _getListChildType<M>(json.map((e) => e as Map<String, dynamic>).toList());
    } else {
      return homluxJsonConvert.convert<M>(json);
    }
  }


  /// 禁止修改
  List<T?>? convertList<T>(List<dynamic>? value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    try {
      return value.map((dynamic e) => _asT<T>(e,enumConvert: enumConvert)).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }


  /// 禁止修改
  List<T>? convertListNotNull<T>(dynamic value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    try {
      return (value as List<dynamic>).map((dynamic e) => _asT<T>(e,enumConvert: enumConvert)!).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }

  /// 禁止修改
  T? _asT<T extends Object?>(dynamic value,
      {EnumConvertFunction? enumConvert}) {
    final String type = T.toString();
    final String valueS = value.toString();
    if (enumConvert != null) {
      return enumConvert(valueS) as T;
    } else if (type == "String") {
      return valueS as T;
    } else if (type == "int") {
      final int? intValue = int.tryParse(valueS);
      if (intValue == null) {
        return double.tryParse(valueS)?.toInt() as T?;
      } else {
        return intValue as T;
      }
    } else if (type == "double") {
      return double.parse(valueS) as T;
    } else if (type == "DateTime") {
      return DateTime.parse(valueS) as T;
    } else if (type == "bool") {
      if (valueS == '0' || valueS == '1') {
        return (valueS == '1') as T;
      }
      return (valueS == 'true') as T;
    } else if (type == "Map" || type.startsWith("Map<")) {
      return value as T;
    } else {
      if (convertFuncMap.containsKey(type)) {
        return convertFuncMap[type]!(Map<String, dynamic>.from(value)) as T;
      } else {
        throw UnimplementedError('$type unimplemented');
      }
    }
  }

}