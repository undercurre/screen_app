// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
import 'package:flutter/material.dart' show debugPrint;
import 'package:screen_app/channel/models/music_state.dart';
import 'package:screen_app/channel/models/net_state.dart';
import 'package:screen_app/channel/models/wifi_scan_result.dart';
import 'package:screen_app/models/delete_device_result_entity.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/models/device_lua_entity.dart';
import 'package:screen_app/models/device_p_d_m_entity.dart';
import 'package:screen_app/models/location_entity.dart';
import 'package:screen_app/models/profile_entity.dart';
import 'package:screen_app/models/scene_info_entity.dart';
import 'package:screen_app/models/scene_list_entity.dart';
import 'package:screen_app/models/weather7d_entity.dart';
import 'package:screen_app/models/weather_entity.dart';
import 'package:screen_app/models/weather_of_city_entity.dart';

import '../../../models/meiju_device_entity.dart';
import '../../../models/meiju_home_info_entity.dart';
import '../../../models/meiju_home_list_info_entity.dart';
import '../../../models/meiju_qr_code_entity.dart';
import '../../../models/meiju_room_entity.dart';
import '../../../models/meiju_user_entity.dart';

MeiJuJsonConvert meijuJsonConvert = MeiJuJsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);
typedef EnumConvertFunction<T> = T Function(String value);

class MeiJuJsonConvert {
	static final Map<String, JsonConvertFunction> convertFuncMap = {
		(AiMusicState).toString(): AiMusicState.fromJson,
		(NetState).toString(): NetState.fromJson,
		(WiFiScanResult).toString(): WiFiScanResult.fromJson,
		(DeleteDeviceResultEntity).toString(): DeleteDeviceResultEntity.fromJson,
		(DeviceHomeListEntity).toString(): DeviceHomeListEntity.fromJson,
		(DeviceHomeListHomeList).toString(): DeviceHomeListHomeList.fromJson,
		(DeviceHomeListHomeListRoomList).toString(): DeviceHomeListHomeListRoomList.fromJson,
		(DeviceHomeListHomeListRoomListApplianceList).toString(): DeviceHomeListHomeListRoomListApplianceList.fromJson,
		(DeviceHomeListHomeListRoomListApplianceListAbility).toString(): DeviceHomeListHomeListRoomListApplianceListAbility.fromJson,
		(DeviceLuaEntity).toString(): DeviceLuaEntity.fromJson,
		(DevicePDMEntity).toString(): DevicePDMEntity.fromJson,
		(LocationEntity).toString(): LocationEntity.fromJson,
		(ProfileEntity).toString(): ProfileEntity.fromJson,

		(SceneInfoEntity).toString(): SceneInfoEntity.fromJson,
		(SceneListEntity).toString(): SceneListEntity.fromJson,
		(Weather7dEntity).toString(): Weather7dEntity.fromJson,
		(WeatherEntity).toString(): WeatherEntity.fromJson,
		(WeatherOfCityEntity).toString(): WeatherOfCityEntity.fromJson,


		(MeiJuQrCodeEntity).toString(): MeiJuQrCodeEntity.fromJson,
		(MeiJuTokenEntity).toString(): MeiJuTokenEntity.fromJson,
		(MeiJuHomeInfoEntity).toString(): MeiJuHomeInfoEntity.fromJson,
		(MeiJuHomeInfoListEntity).toString(): MeiJuHomeInfoListEntity.fromJson,
		(MeiJuRoomEntity).toString(): MeiJuRoomEntity.fromJson,
		(MeiJuDeviceEntity).toString(): MeiJuDeviceEntity.fromJson,




	};

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
		if(<AiMusicState>[] is M){
			return data.map<AiMusicState>((Map<String, dynamic> e) => AiMusicState.fromJson(e)).toList() as M;
		}
		if(<NetState>[] is M){
			return data.map<NetState>((Map<String, dynamic> e) => NetState.fromJson(e)).toList() as M;
		}
		if(<WiFiScanResult>[] is M){
			return data.map<WiFiScanResult>((Map<String, dynamic> e) => WiFiScanResult.fromJson(e)).toList() as M;
		}
		if(<DeleteDeviceResultEntity>[] is M){
			return data.map<DeleteDeviceResultEntity>((Map<String, dynamic> e) => DeleteDeviceResultEntity.fromJson(e)).toList() as M;
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
		if(<SceneInfoEntity>[] is M){
			return data.map<SceneInfoEntity>((Map<String, dynamic> e) => SceneInfoEntity.fromJson(e)).toList() as M;
		}
		if(<SceneListEntity>[] is M){
			return data.map<SceneListEntity>((Map<String, dynamic> e) => SceneListEntity.fromJson(e)).toList() as M;
		}
		if(<MeiJuTokenEntity>[] is M){
			return data.map<MeiJuTokenEntity>((Map<String, dynamic> e) => MeiJuTokenEntity.fromJson(e)).toList() as M;
		}
		if(<Weather7dEntity>[] is M){
			return data.map<Weather7dEntity>((Map<String, dynamic> e) => Weather7dEntity.fromJson(e)).toList() as M;
		}
		if(<WeatherEntity>[] is M){
			return data.map<WeatherEntity>((Map<String, dynamic> e) => WeatherEntity.fromJson(e)).toList() as M;
		}
		if(<WeatherOfCityEntity>[] is M){
			return data.map<WeatherOfCityEntity>((Map<String, dynamic> e) => WeatherOfCityEntity.fromJson(e)).toList() as M;
		}

		debugPrint("${M.toString()} not found");
	
		return null;
}

	M? fromJsonAsT<M>(dynamic json) {
		if (json is List) {
			return _getListChildType<M>(json.map((e) => e as Map<String, dynamic>).toList());
		} else {
			return convert<M>(json);
		}
	}
}