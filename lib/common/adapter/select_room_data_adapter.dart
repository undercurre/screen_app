import 'dart:convert';

import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/select_family_data_adapter.dart';
import 'package:screen_app/common/homlux/api/homlux_user_api.dart';
import 'package:screen_app/common/meiju/api/meiju_user_api.dart';

import '../homlux/generated/json/base/homlux_json_convert_content.dart';
import '../homlux/models/homlux_family_entity.dart';
import '../homlux/models/homlux_room_list_entity.dart';
import '../meiju/generated/json/base/meiju_json_convert_content.dart';
import '../meiju/models/meiju_login_home_entity.dart';
import '../meiju/models/meiju_room_entity.dart';
import '../system.dart';

class SelectRoomItem {
  /// 房间名称
  String? name;

  /// 房间设备数量
  int? deviceNum;

  String? id;

  HomluxRoomInfo? _homluxData;
  MeiJuRoomEntity? _meijuData;

  SelectRoomItem.fromMeiJu(MeiJuRoomEntity data)
      : name = data.name,
        id = data.roomId,
        deviceNum = data.applianceList?.length ?? 0 {
    _meijuData = data;
  }

  SelectRoomItem.fromHomlux(HomluxRoomInfo data)
      : name = data.roomName,
        id = data.roomId,
      deviceNum = data.deviceNum {
    _homluxData = data;
  }

  /// 下面两方法对UI层的意义
  /// 提供 Json -> Object 之间切换
  /// 意义：方便对UI层的数据快速持久化
  factory SelectRoomItem.fromJson(Map<String, dynamic> json) {
    if (json['_homluxData'] != null) {
      return SelectRoomItem.fromHomlux(
          homluxJsonConvert.convert<HomluxRoomInfo>(json['_homluxData'])!);
    } else if (json['_meijuData'] != null) {
      return SelectRoomItem.fromMeiJu(
          meijuJsonConvert.convert<MeiJuRoomEntity>(json['_meijuData'])!);
    } else {
      throw UnimplementedError(
          "失败：fromJson解析QRCodeEntity失败 解析的数据为：${const JsonEncoder().convert(json)}");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "_homluxData": _homluxData?.toJson(),
      "_meijuData": _meijuData?.toJson()
    };
  }

  @override
  String toString() {
    return jsonEncode({
      "_homluxData": _homluxData?.toJson(),
      "_meijuData": _meijuData?.toJson()
    });
  }

  dynamic get meijuData {
    return _meijuData;
  }

  dynamic get homluxData {
    return _homluxData;
  }
}

class SelectRoomListEntity {
  late List<SelectRoomItem> familyList;

  SelectRoomListEntity.fromHomlux(List<HomluxRoomInfo> data) {
    _homluxData = data;
    familyList = data.map((e) => SelectRoomItem.fromHomlux(e)).toList();
  }

  SelectRoomListEntity.fromMeiJu(List<MeiJuRoomEntity> data) {
    _meijuData = data;
    familyList = data.map((e) => SelectRoomItem.fromMeiJu(e)).toList();
  }

  List<MeiJuRoomEntity>? _meijuData;
  List<HomluxRoomInfo>? _homluxData;

  /// 下面两方法对UI层的意义
  /// 提供 Json -> Object 之间切换
  /// 意义：方便对UI层的数据快速持久化
  factory SelectRoomListEntity.fromJson(Map<String, dynamic> json) {
    if (json['_homluxData'] != null) {
      return SelectRoomListEntity.fromHomlux(homluxJsonConvert
              .convertListNotNull<HomluxRoomInfo>(json['_homluxData']) ??
          []);
    } else if (json['_meijuData'] != null) {
      return SelectRoomListEntity.fromMeiJu(meijuJsonConvert
              .convertListNotNull<MeiJuRoomEntity>(json['_meijuData']) ??
          []);
    } else {
      throw UnimplementedError(
          "失败：fromJson解析QRCodeEntity失败 解析的数据为：${const JsonEncoder().convert(json)}");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "_homluxData": _homluxData?.map((e) => e.toJson()).toList(),
      "_meijuData": _meijuData?.map((e) => e.toJson()).toList()
    };
  }

  @override
  String toString() {
    return jsonEncode({
      "_homluxData": _homluxData?.map((e) => e.toJson()).toList(),
      "_meijuData": _meijuData?.map((e) => e.toJson()).toList(),
      "familyListCount": familyList.length
    });
  }
}

class SelectRoomDataAdapter extends MideaDataAdapter {
  SelectRoomListEntity? familyListEntity;
  DataState dataState = DataState.NONE;

  SelectRoomDataAdapter(super.platform);

  Future<void> queryRoomList(SelectFamilyItem item) async {
    dataState = DataState.LOADING;
    if (platform.inHomlux()) {
      HomluxFamilyEntity familyEntity = item.homluxData as HomluxFamilyEntity;
      var res = await HomluxUserApi.queryRoomList(familyEntity.houseId);
      if (res.isSuccess && res.data != null) {
        familyListEntity =
            SelectRoomListEntity.fromHomlux(res.data?.roomInfoWrap ?? []);
        System.homluxRoomList = familyListEntity?._homluxData;
        dataState = DataState.SUCCESS;
      } else {
        dataState = DataState.ERROR;
      }
    } else if (platform.inMeiju()) {
      MeiJuLoginHomeEntity familyEntity = item.meijuData;
      var res = await MeiJuUserApi.getHomeDetail(
          homegroupId: familyEntity.homegroupId);
      if (res.isSuccess && res.data != null && res.data!.homeList != null) {
        familyListEntity = SelectRoomListEntity.fromMeiJu(
            res.data?.homeList?[0].roomList ?? []);
        System.meijuRoomList = familyListEntity?._meijuData;
        dataState = DataState.SUCCESS;
      } else {
        dataState = DataState.ERROR;
      }
    }
    updateUI();
  }
}
