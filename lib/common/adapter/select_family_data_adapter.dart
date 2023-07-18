import 'dart:async';
import 'dart:convert';

import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/homlux/api/homlux_user_api.dart';
import 'package:screen_app/common/meiju/api/meiju_user_api.dart';

import '../homlux/generated/json/base/homlux_json_convert_content.dart';
import '../homlux/models/homlux_family_entity.dart';
import '../logcat_helper.dart';
import '../meiju/generated/json/base/meiju_json_convert_content.dart';
import '../meiju/models/meiju_home_info_entity.dart';

class SelectFamilyItem {
  // 家庭名称
  String familyName;

  // 房间数量
  String roomNum;

  // 设备数量
  String deviceNum;

  // 家庭成员人数
  String userNum;

  // 是否为创建者
  bool houseCreatorFlag;

  MeiJuHomeInfoEntity? _meijuData;
  HomluxFamilyEntity? _homluxData;

  SelectFamilyItem.fromMeiJu(MeiJuHomeInfoEntity data)
      : familyName = data.name ?? '',
        roomNum = data.roomCount ?? "0",
        deviceNum = data.applianceCount ?? "0",
        userNum = data.memberCount ?? '0',
        houseCreatorFlag = false {
    _meijuData = data;
  }

  SelectFamilyItem.fromHomlux(HomluxFamilyEntity data)
      : familyName = data.houseName,
        roomNum = '${data.roomNum}',
        deviceNum = '${data.deviceNum}',
        userNum = '${data.userNum}',
        houseCreatorFlag = data.houseCreatorFlag {
    _homluxData = data;
  }

  /// 下面两方法对UI层的意义
  /// 提供 Json -> Object 之间切换
  /// 意义：方便对UI层的数据快速持久化
  factory SelectFamilyItem.fromJson(Map<String, dynamic> json) {
    if (json['_homluxData'] != null) {
      return SelectFamilyItem.fromHomlux(
          homluxJsonConvert.convert<HomluxFamilyEntity>(json['_homluxData'])!);
    } else if (json['_meijuData'] != null) {
      return SelectFamilyItem.fromMeiJu(
          meijuJsonConvert.convert<MeiJuHomeInfoEntity>(json['_meijuData'])!);
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

class SelectFamilyListEntity {
  late List<SelectFamilyItem> familyList;

  SelectFamilyListEntity.fromHomlux(List<HomluxFamilyEntity> data) {
    _homluxData = data;
    familyList = data.map((e) => SelectFamilyItem.fromHomlux(e)).toList();
  }

  SelectFamilyListEntity.fromMeiJu(List<MeiJuHomeInfoEntity> data) {
    _meijuData = data;
    familyList = data.map((e) => SelectFamilyItem.fromMeiJu(e)).toList();
  }

  List<MeiJuHomeInfoEntity>? _meijuData;
  List<HomluxFamilyEntity>? _homluxData;

  /// 下面两方法对UI层的意义
  /// 提供 Json -> Object 之间切换
  /// 意义：方便对UI层的数据快速持久化
  factory SelectFamilyListEntity.fromJson(Map<String, dynamic> json) {
    if (json['_homluxData'] != null) {
      return SelectFamilyListEntity.fromHomlux(homluxJsonConvert
              .convertListNotNull<HomluxFamilyEntity>(json['_homluxData']) ??
          []);
    } else if (json['_meijuData'] != null) {
      return SelectFamilyListEntity.fromMeiJu(meijuJsonConvert
              .convertListNotNull<MeiJuHomeInfoEntity>(json['_meijuData']) ??
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

  dynamic get meijuData {
    return _meijuData;
  }

  dynamic get homluxData {
    return _homluxData;
  }
}

class SelectFamilyDataAdapter extends MideaDataAdapter {
  SelectFamilyListEntity? familyListEntity;
  DataState dataState = DataState.NONE;

  SelectFamilyDataAdapter(super.platform);

  void queryFamilyList() async {
    dataState = DataState.LONGING;
    if (platform.inHomlux()) {
      var res = await HomluxUserApi.queryFamilyList();
      if (res.isSuccess && res.data != null) {
        familyListEntity = SelectFamilyListEntity.fromHomlux(res.data ?? []);
        dataState = DataState.SUCCESS;
      } else {
        dataState = DataState.ERROR;
      }
    } else if (platform.inMeiju()) {
      var res = await MeiJuUserApi.getHomeDetail();
      if (res.isSuccess && res.data != null && res.data!.homeList != null) {
        familyListEntity =
            SelectFamilyListEntity.fromMeiJu(res.data?.homeList ?? []);
        dataState = DataState.SUCCESS;
      } else {
        dataState = DataState.ERROR;
      }
    }
    updateUI();
  }

  /// 查询家庭是否有权限登录
  /// null 查询失败
  /// false 没有权限登录
  /// true 有权限登录
  Future<bool?> queryHouseAuth(SelectFamilyItem entity) async {
    if (platform.inHomlux()) {
      HomluxFamilyEntity homluxFamilyEntity =
          entity.homluxData as HomluxFamilyEntity;
      var res = await HomluxUserApi.queryHouseAuth(homluxFamilyEntity.houseId);
      return res.isSuccess && (res.data?.isTourist() ?? false);
    } else if (platform.inMeiju()) {
      MeiJuHomeInfoEntity meiJuHomeInfoEntity =
          entity.meijuData as MeiJuHomeInfoEntity;
      /// 延时一秒再返回
      return Future.delayed(const Duration(seconds: 1),
          () => meiJuHomeInfoEntity.roleId == '1003');
    }
    Log.file("请求异常");
    return null;
  }


}
