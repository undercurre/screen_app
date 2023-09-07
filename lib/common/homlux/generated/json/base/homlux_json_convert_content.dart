

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/homlux/models/homlux_family_entity.dart';

import '../../../models/homlux_485_device_list_entity.dart';
import '../../../models/homlux_auth_entity.dart';
import '../../../models/homlux_bind_device_entity.dart';
import '../../../models/homlux_device_entity.dart';
import '../../../models/homlux_dui_token_entity.dart';
import '../../../models/homlux_group_entity.dart';
import '../../../models/homlux_panel_associate_scene_entity.dart';
import '../../../models/homlux_qr_code_auth_entity.dart';
import '../../../models/homlux_qr_code_entity.dart';
import '../../../models/homlux_refresh_token_entity.dart';
import '../../../models/homlux_room_list_entity.dart';
import '../../../models/homlux_scene_entity.dart';
import '../../../models/homlux_user_config_info.dart';
import '../../../models/homlux_user_info_entity.dart';
import '../../../models/homlux_weather_entity.dart';

HomluxJsonConvert homluxJsonConvert = HomluxJsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);
typedef EnumConvertFunction<T> = T Function(String value);


class HomluxJsonConvert {

  static final Map<String, JsonConvertFunction> convertFuncMap = {
    (HomluxUserInfoEntity).toString(): HomluxUserInfoEntity.fromJson,
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
    (HomluxDeviceMzgdPropertyDTOListLight).toString(): HomluxDeviceMzgdPropertyDTOListLight.fromJson,
    (HomluxDuiTokenEntity).toString(): HomluxDuiTokenEntity.fromJson,
    (HomluxBindDeviceEntity).toString(): HomluxBindDeviceEntity.fromJson,
    (HomluxAuthEntity).toString(): HomluxAuthEntity.fromJson,
    (HomluxWeatherEntity).toString(): HomluxWeatherEntity.fromJson,
    (HomluxGroupEntity).toString(): HomluxGroupEntity.fromJson,
    (HomluxDeviceActions).toString(): HomluxDeviceActions.fromJson,
    (Homlux485DeviceListEntity).toString(): Homlux485DeviceListEntity.fromJson,
    (Homlux485DeviceListNameValuePairs).toString(): Homlux485DeviceListNameValuePairs.fromJson,
    (Homlux485DeviceListNameValuePairsAirConditionList).toString(): Homlux485DeviceListNameValuePairsAirConditionList.fromJson,
    (Homlux485DeviceListNameValuePairsFreshAirList).toString(): Homlux485DeviceListNameValuePairsFreshAirList.fromJson,
    (Homlux485DeviceListNameValuePairsFloorHotList).toString(): Homlux485DeviceListNameValuePairsFloorHotList.fromJson,
    (HomluxPanelAssociateSceneEntity).toString(): HomluxPanelAssociateSceneEntity.fromJson,
    (HomluxPanelAssociateSceneEntitySceneList).toString(): HomluxPanelAssociateSceneEntitySceneList.fromJson,
    (HomluxDeviceConditions).toString(): HomluxDeviceConditions.fromJson,
    (HomluxEffectiveTime).toString(): HomluxEffectiveTime.fromJson,
    (HomluxUserConfigInfo).toString(): HomluxUserConfigInfo.fromJson,

  };

  static M? _getListChildType<M>(List<Map<String, dynamic>> data) {
    if(<HomluxPanelAssociateSceneEntity>[] is M) {
      return data.map<HomluxPanelAssociateSceneEntity>((e) => HomluxPanelAssociateSceneEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxPanelAssociateSceneEntitySceneList>[] is M) {
      return data.map<HomluxPanelAssociateSceneEntitySceneList>((e) => HomluxPanelAssociateSceneEntitySceneList.fromJson(e)).toList() as M;
    }
    if(<HomluxUserInfoEntity>[] is M) {
      return data.map<HomluxUserInfoEntity>((e) => HomluxUserInfoEntity.fromJson(e)).toList() as M;
    }
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
    if(<HomluxDeviceActions>[] is M) {
      return data.map<HomluxDeviceActions>((e) => HomluxDeviceActions.fromJson(e)).toList() as M;
    }
    if(<HomluxDeviceConditions>[] is M) {
      return data.map<HomluxDeviceConditions>((e) => HomluxDeviceConditions.fromJson(e)).toList() as M;
    }
    if(<HomluxEffectiveTime>[] is M) {
      return data.map<HomluxEffectiveTime>((e) => HomluxEffectiveTime.fromJson(e)).toList() as M;
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
    if(<HomluxDeviceMzgdPropertyDTOListLight>[] is M) {
      return data.map<HomluxDeviceMzgdPropertyDTOListLight>((e) => HomluxDeviceMzgdPropertyDTOListLight.fromJson(e)).toList() as M;
    }
    if(<HomluxDuiTokenEntity>[] is M) {
      return data.map<HomluxDuiTokenEntity>((e) => HomluxDuiTokenEntity.fromJson(e)).toList() as M;
    }
    if(<HomluxBindDeviceEntity>[] is M) {
      return data.map<HomluxBindDeviceEntity>((e) => HomluxBindDeviceEntity.fromJson(e)).toList() as M;
    }
    if(<GroupDeviceList>[] is M) {
      return data.map<GroupDeviceList>((e) => GroupDeviceList.fromJson(e)).toList() as M;
    }
    if(<ControlAction>[] is M) {
      return data.map<ControlAction>((e) => ControlAction.fromJson(e)).toList() as M;
    }
    if (<Homlux485DeviceListEntity>[] is M) {
      return data.map<Homlux485DeviceListEntity>((Map<String, dynamic> e) => Homlux485DeviceListEntity.fromJson(e)).toList() as M;
    }
    if (<Homlux485DeviceListNameValuePairs>[] is M) {
      return data.map<Homlux485DeviceListNameValuePairs>((Map<String, dynamic> e) => Homlux485DeviceListNameValuePairs.fromJson(e)).toList() as M;
    }
    if (<Homlux485DeviceListNameValuePairsAirConditionList>[] is M) {
      return data.map<Homlux485DeviceListNameValuePairsAirConditionList>((Map<String, dynamic> e) => Homlux485DeviceListNameValuePairsAirConditionList.fromJson(e))
          .toList() as M;
    }
    if (<Homlux485DeviceListNameValuePairsFreshAirList>[] is M) {
      return data.map<Homlux485DeviceListNameValuePairsFreshAirList>((Map<String, dynamic> e) => Homlux485DeviceListNameValuePairsFreshAirList.fromJson(e))
          .toList() as M;
    }
    if (<Homlux485DeviceListNameValuePairsFloorHotList>[] is M) {
      return data.map<Homlux485DeviceListNameValuePairsFloorHotList>((Map<String, dynamic> e) => Homlux485DeviceListNameValuePairsFloorHotList.fromJson(e))
          .toList() as M;
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