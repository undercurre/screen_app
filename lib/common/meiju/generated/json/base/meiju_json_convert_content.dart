// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
import 'package:flutter/material.dart' show debugPrint;
import 'package:screen_app/channel/models/music_state.dart';
import 'package:screen_app/channel/models/net_state.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/models/device_lua_entity.dart';
import 'package:screen_app/models/device_p_d_m_entity.dart';
import 'package:screen_app/models/location_entity.dart';
import 'package:screen_app/models/profile_entity.dart';

import '../../../models/auth_device_bath_entity.dart';
import '../../../models/meiju_delete_device_result_entity.dart';
import '../../../models/meiju_device_entity.dart';
import '../../../models/meiju_device_info_entity.dart';
import '../../../models/meiju_home_info_entity.dart';
import '../../../models/meiju_home_list_info_entity.dart';
import '../../../models/meiju_login_home_entity.dart';
import '../../../models/meiju_login_home_list_entity.dart';
import '../../../models/meiju_panel_scene_bind_list_entity.dart';
import '../../../models/meiju_qr_code_entity.dart';
import '../../../models/meiju_room_entity.dart';
import '../../../models/meiju_scene_list_entity.dart';
import '../../../models/meiju_user_entity.dart';
import '../../../models/meiju_weather7d_entity.dart';
import '../../../models/meiju_weather_entity.dart';

MeiJuJsonConvert meijuJsonConvert = MeiJuJsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);
typedef EnumConvertFunction<T> = T Function(String value);

class MeiJuJsonConvert {


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

	M? fromJsonAsT<M>(dynamic json) {
		if (json is List) {
			return _getListChildType<M>(json.map((e) => e as Map<String, dynamic>).toList());
		} else {
			return convert<M>(json);
		}
	}

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

	//list is returned by type
	M? _getListChildType<M>(List<Map<String, dynamic>> data) {
		if(<MeiJuAuthStatus>[] is M) {
			return data.map<MeiJuAuthStatus>((Map<String, dynamic> e) => MeiJuAuthStatus.fromJson(e)).toList() as M;
		}
		if(<MeiJuAuthDeviceBatchEntity>[] is M) {
			return data.map<MeiJuAuthDeviceBatchEntity>((Map<String, dynamic> e) => MeiJuAuthDeviceBatchEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuLoginHomeEntity>[] is M) {
			return data.map<MeiJuLoginHomeEntity>((Map<String, dynamic> e) => MeiJuLoginHomeEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuLoginHomeListEntity>[] is M) {
			return data.map<MeiJuLoginHomeListEntity>((Map<String, dynamic> e) => MeiJuLoginHomeListEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuPanelSceneBindListEntity>[] is M) {
			return data.map<MeiJuPanelSceneBindListEntity>((Map<String, dynamic> e) => MeiJuPanelSceneBindListEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuPanelSceneBindItemEntity>[] is M) {
			return data.map<MeiJuPanelSceneBindItemEntity>((Map<String, dynamic> e) => MeiJuPanelSceneBindItemEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuWeather>[] is M) {
			return data.map<MeiJuWeather>((Map<String, dynamic> e) => MeiJuWeather.fromJson(e)).toList() as M;
		}
		if(<MeiJuLocation>[] is M) {
			return data.map<MeiJuLocation>((Map<String, dynamic> e) => MeiJuLocation.fromJson(e)).toList() as M;
		}
		if(<MeiJuSceneEntity>[] is M) {
			return data.map<MeiJuSceneEntity>((Map<String, dynamic> e) => MeiJuSceneEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuDeviceInfoAbilityEntity>[] is M) {
			return data.map<MeiJuDeviceInfoAbilityEntity>((Map<String, dynamic> e) => MeiJuDeviceInfoAbilityEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuDeviceInfoEntity>[] is M) {
			return data.map<MeiJuDeviceInfoEntity>((Map<String, dynamic> e) => MeiJuDeviceInfoEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuWeather7dEntity>[] is M){
			return data.map<MeiJuWeather7dEntity>((Map<String, dynamic> e) => MeiJuWeather7dEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuWeatherEntity>[] is M){
			return data.map<MeiJuWeatherEntity>((Map<String, dynamic> e) => MeiJuWeatherEntity.fromJson(e)).toList() as M;
		}
		if(<AiMusicState>[] is M){
			return data.map<AiMusicState>((Map<String, dynamic> e) => AiMusicState.fromJson(e)).toList() as M;
		}
		if(<NetState>[] is M){
			return data.map<NetState>((Map<String, dynamic> e) => NetState.fromJson(e)).toList() as M;
		}
		if(<WiFiScanResult>[] is M){
			return data.map<WiFiScanResult>((Map<String, dynamic> e) => WiFiScanResult.fromJson(e)).toList() as M;
		}
		if(<MeiJuDeleteDeviceResultEntity>[] is M){
			return data.map<MeiJuDeleteDeviceResultEntity>((Map<String, dynamic> e) => MeiJuDeleteDeviceResultEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuDeviceEntity>[] is M){
			return data.map<MeiJuDeviceEntity>((Map<String, dynamic> e) => MeiJuDeviceEntity.fromJson(e)).toList() as M;
		}
		if(<DeviceHomeListEntity>[] is M){
			return data.map<DeviceHomeListEntity>((Map<String, dynamic> e) => DeviceHomeListEntity.fromJson(e)).toList() as M;
		}
		if(<DeviceHomeListHomeList>[] is M){
			return data.map<DeviceHomeListHomeList>((Map<String, dynamic> e) => DeviceHomeListHomeList.fromJson(e)).toList() as M;
		}
		if(<DeviceHomeListHomeListRoomList>[] is M){
			return data.map<DeviceHomeListHomeListRoomList>((Map<String, dynamic> e) => DeviceHomeListHomeListRoomList.fromJson(e)).toList() as M;
		}
		if(<DeviceHomeListHomeListRoomListApplianceList>[] is M){
			return data.map<DeviceHomeListHomeListRoomListApplianceList>((Map<String, dynamic> e) => DeviceHomeListHomeListRoomListApplianceList.fromJson(e)).toList() as M;
		}
		if(<DeviceHomeListHomeListRoomListApplianceListAbility>[] is M){
			return data.map<DeviceHomeListHomeListRoomListApplianceListAbility>((Map<String, dynamic> e) => DeviceHomeListHomeListRoomListApplianceListAbility.fromJson(e)).toList() as M;
		}
		if(<DeviceLuaEntity>[] is M){
			return data.map<DeviceLuaEntity>((Map<String, dynamic> e) => DeviceLuaEntity.fromJson(e)).toList() as M;
		}
		if(<DevicePDMEntity>[] is M){
			return data.map<DevicePDMEntity>((Map<String, dynamic> e) => DevicePDMEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuHomeInfoEntity>[] is M){
			return data.map<MeiJuHomeInfoEntity>((Map<String, dynamic> e) => MeiJuHomeInfoEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuHomeInfoListEntity>[] is M){
			return data.map<MeiJuHomeInfoListEntity>((Map<String, dynamic> e) => MeiJuHomeInfoListEntity.fromJson(e)).toList() as M;
		}
		if(<LocationEntity>[] is M){
			return data.map<LocationEntity>((Map<String, dynamic> e) => LocationEntity.fromJson(e)).toList() as M;
		}
		if(<ProfileEntity>[] is M){
			return data.map<ProfileEntity>((Map<String, dynamic> e) => ProfileEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuQrCodeEntity>[] is M){
			return data.map<MeiJuQrCodeEntity>((Map<String, dynamic> e) => MeiJuQrCodeEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuRoomEntity>[] is M){
			return data.map<MeiJuRoomEntity>((Map<String, dynamic> e) => MeiJuRoomEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuSceneListEntity>[] is M){
			return data.map<MeiJuSceneListEntity>((Map<String, dynamic> e) => MeiJuSceneListEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuTokenEntity>[] is M){
			return data.map<MeiJuTokenEntity>((Map<String, dynamic> e) => MeiJuTokenEntity.fromJson(e)).toList() as M;
		}
		debugPrint("${M.toString()} not found");
	
		return null;
}

	static final Map<String, JsonConvertFunction> convertFuncMap = {
		(MeiJuAuthDeviceBatchEntity).toString(): MeiJuAuthDeviceBatchEntity.fromJson,
		(MeiJuAuthStatus).toString(): MeiJuAuthStatus.fromJson,
		(AiMusicState).toString(): AiMusicState.fromJson,
		(NetState).toString(): NetState.fromJson,
		(WiFiScanResult).toString(): WiFiScanResult.fromJson,
		(DeviceLuaEntity).toString(): DeviceLuaEntity.fromJson,
		(DevicePDMEntity).toString(): DevicePDMEntity.fromJson,
		(LocationEntity).toString(): LocationEntity.fromJson,
		(ProfileEntity).toString(): ProfileEntity.fromJson,

		(MeiJuQrCodeEntity).toString(): MeiJuQrCodeEntity.fromJson,
		(MeiJuTokenEntity).toString(): MeiJuTokenEntity.fromJson,
		(MeiJuHomeInfoEntity).toString(): MeiJuHomeInfoEntity.fromJson,
		(MeiJuHomeInfoListEntity).toString(): MeiJuHomeInfoListEntity.fromJson,
		(MeiJuRoomEntity).toString(): MeiJuRoomEntity.fromJson,
		(MeiJuDeviceEntity).toString(): MeiJuDeviceEntity.fromJson,
		(MeiJuWeatherEntity).toString(): MeiJuWeatherEntity.fromJson,
		(MeiJuWeather7dEntity).toString(): MeiJuWeather7dEntity.fromJson,
		(MeiJuSceneListEntity).toString(): MeiJuSceneListEntity.fromJson,
		(MeiJuDeviceInfoEntity).toString(): MeiJuDeviceInfoEntity.fromJson,
		(MeiJuDeviceInfoAbilityEntity).toString(): MeiJuDeviceInfoAbilityEntity.fromJson,
		(MeiJuDeleteDeviceResultEntity).toString(): MeiJuDeleteDeviceResultEntity.fromJson,
		(MeiJuSceneEntity).toString(): MeiJuSceneEntity.fromJson,
		(MeiJuLocation).toString(): MeiJuLocation.fromJson,
		(MeiJuWeather).toString(): MeiJuWeather.fromJson,
		(MeiJuPanelSceneBindItemEntity).toString(): MeiJuPanelSceneBindItemEntity.fromJson,
		(MeiJuPanelSceneBindListEntity).toString(): MeiJuPanelSceneBindListEntity.fromJson,
		(MeiJuLoginHomeEntity).toString(): MeiJuLoginHomeEntity.fromJson,
		(MeiJuLoginHomeListEntity).toString(): MeiJuLoginHomeListEntity.fromJson,
	};
}