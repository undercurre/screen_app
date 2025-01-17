import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/exceptions/MideaException.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_delete_device_result_entity.dart';
import 'package:uuid/uuid.dart';

import '../../logcat_helper.dart';
import '../../models/endpoint.dart';
import '../../models/node_info.dart';
import '../models/auth_device_bath_entity.dart';
import '../models/meiju_device_info_entity.dart';
import '../models/meiju_response_entity.dart';

class MeiJuDeviceApi {
  /// 获取某家庭下所有的设备
  static Future<MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>>>
  queryDeviceListByHomeId(String uid, String homegroupId) async {
    var res = await MeiJuApi.requestMideaIot(
        '/mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {'uid': uid, 'homegroupId': homegroupId});

    if (!res.isSuccess ||
        res.data == null ||
        (res.data['homeList'] is List && res.data['homeList'].length <= 0)) {
      throw MideaException('获取家庭列表失败');
    }

    List<dynamic> applianceList = [];

    res.data['homeList'][0]?['roomList']?.forEach((element) {
      if (element['applianceList'] != null) {
        element['applianceList'].forEach((appliance) {
          appliance?['roomName'] = element['name'];
          appliance?['roomId'] = element['roomId'];
        });
        applianceList.addAll(element['applianceList']);
      }
    });

    return MeiJuResponseEntity.fromJson({'code': 0, 'msg': '成功', 'data': applianceList});
  }

  /// 获取某房间下所有的设备
  static Future<List<dynamic>> queryDeviceListByRoomId(String uid,
      String homegroupId, String roomId) async {
    var res = await MeiJuApi.requestMideaIot(
        '/mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {'uid': uid, 'homegroupId': homegroupId, 'roomId': roomId});

    if (!res.isSuccess ||
        res.data == null ||
        (res.data['homeList'] is List && res.data['homeList'].length <= 0)) {
      throw Exception('获取家庭列表失败');
    }

    List<dynamic> applianceList = [];

    res.data['homeList'][0]?['roomList']?.forEach((element) {
      if (element['applianceList'] != null) {
        applianceList.addAll(element['applianceList']);
      }
    });

    return applianceList;
  }

  /// 设备lua控制
  static Future<MeiJuResponseEntity> sendLuaOrderByIOT(
      Map<String, dynamic> data) async {
    return await MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/device/lua/control",
        data: data,
        options: Options(method: 'POST'));
  }

  /// 获取设备详情（lua）
  static Future<MeiJuResponseEntity> getDeviceDetail(String type,
      String applianceCode) async {
    var res = await MeiJuApi.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/status/query",
        data: {"applianceCode": applianceCode, "categoryCode": type},
        options: Options(method: 'POST'));
    return res;
  }

  /// 设备lua控制
  static Future<MeiJuResponseEntity> sendLuaOrder({required String categoryCode,
    required String applianceCode,
    required Object command}) async {
    var res = await MeiJuApi.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/wifiControl",
        data: {
          "deviceId": applianceCode,
          "userId": MeiJuGlobal.token?.uid,
          "command": command,
          "categoryCode": categoryCode,
        },
        options: Options(method: 'POST'));

    return res;
  }

  /// 设备物模型查询
  static Future<MeiJuResponseEntity> sendPDMQueryOrder({required String categoryCode,
    required String uri,
    required String applianceCode,
    required Object command,
    String? method = "POST"}) async {
    var res = await MeiJuApi.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/control",
        data: {
          "categoryCode": categoryCode,
          "method": method,
          "command": command,
          "uri": '/$uri/$applianceCode',
          "deviceId": applianceCode,
          "userId": MeiJuGlobal.token?.uid,
        },
        options: Options(method: 'POST'));
    return res;
  }


  /// 设备物模型控制
  /// 物模型输入参数，参考iot平台设备的物模型配置
  /// https://mis.midea.com/#/a/products-list?urlSearch=%7B%22name%22%3A%22%22,%22accessMethod%22%3A%22%22,%22productStatus%22%3A%22%22,%22ownerGroupId%22%3A%22%22,%22catCode%22%3A%22%22,%22brandCode%22%3A%22%22,%22tagId%22%3A%22%22,%22controlTerminal%22%3Anull,%22pageNo%22%3A1,%22pageSize%22%3A10%7D
  ///
  /// 网关子设备物模型输入参数，这里以D3网关[MSGWZ002]为例子解释
  /// 智能产品->D3网关详情页->物模型->操作 -> 查看API列表
  /// 操作一栏定义了各种设备控制的动作。比如 lightControl 灯光设备控制接口(/subdevice/control)
  ///
  static Future<MeiJuResponseEntity<T>> sendPDMControlOrder<T>({required String categoryCode,
    required String uri,
    required String applianceCode,
    required Object command,
    String? method = "PUT"}) async {
    MeiJuResponseEntity<T> res = await MeiJuApi.requestMzIot<T>(
        "/v1/category/midea/device/control",
        data: {
          "categoryCode": categoryCode,
          "method": method,
          "command": command,
          "uri": '/$uri/$applianceCode',
          "deviceId": applianceCode,
          "userId": MeiJuGlobal.token?.uid,
        },
        options: Options(method: 'POST'));
    return res;
  }

  /// 获取Zigbee网关子设备状态详情
  static Future<NodeInfo<Endpoint<T>>> getGatewayInfo<T extends Event>(
      String deviceId, String masterId, T Function(Map<String, dynamic>) eventFromJson) async {
    var res = await MeiJuApi.requestMzIot<String>(
      "/v1/category/midea/getGatewayInfo",
      data: {
        "userId": MeiJuGlobal.token?.uid,
        "applianceCode": masterId,
        "devId": deviceId,
      },
      options: Options(method: 'POST'),
    );

    if (res.isSuccess) {
      Map<String, dynamic> jsonMap = json.decode(res.data!);
      NodeInfo<Endpoint<T>> nodeInfo = NodeInfo.fromJson(
        jsonMap,
        (json) => Endpoint<T>.fromJson(json, eventFromJson),
      );
      return nodeInfo;
    }

    throw Exception('Failed to get gateway info');
  }


  // 灯组查询
  static Future<MeiJuResponseEntity<Map<String, dynamic>>> getGroupList() async {
    var res = await MeiJuApi.requestMideaIot<Map<String, dynamic>>(
        "/mas/v5/app/proxy?alias=/mzgd/v2/appliance/group/list",
        data: {
          "homegroupId": MeiJuGlobal.homeInfo?.homegroupId,
          "uid": MeiJuGlobal.token?.uid,
        },
        queryParameters: {
          "homegroupId": MeiJuGlobal.homeInfo?.homegroupId,
          "uid": MeiJuGlobal.token?.uid,
        },
        options: Options(method: 'POST'));

    return res;
  }

  /// 批量删除设备
  static Future<MeiJuResponseEntity<MeiJuDeleteDeviceResultEntity>> deleteDevices(List<String> applianceCodes, String homeGroupID) async {

    final devices = applianceCodes.map((e) => {
      'applianceCode': e,
      'homegroupId': MeiJuGlobal.homeInfo?.homegroupId,
      'isOtherEquipment': '0'
    }).toList();

    var res = await MeiJuApi.requestMideaIot<MeiJuDeleteDeviceResultEntity>(
        '/mas/v5/app/proxy?alias=/v1/appliance/batch/delete',
        data: {
          'applianceList': devices,
          "uid": MeiJuGlobal.token?.uid,
        });
    return res;
  }

  /// 批量获取未确权设备
  static Future<MeiJuResponseEntity<MeiJuAuthDeviceBatchEntity>> getAuthBatchStatus(List<String> applianceCodes) async {
    return await MeiJuApi.requestMideaIot(
        '/mas/v5/app/proxy?alias=/v1/appliance/auth/batch/get',
        data: {
          "reqId": const Uuid().v4(),
          "stamp": DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          "applianceCodeList": applianceCodes,
        });
  }

}
