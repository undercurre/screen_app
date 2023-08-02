import 'dart:async';

import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_delete_device_result_entity.dart';

import '../models/meiju_device_info_entity.dart';
import '../models/meiju_response_entity.dart';

class MeiJuDeviceApi {

  /// 获取某家庭下所有的设备
  static Future<MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>>> queryDeviceListByHomeId(String uid, String homegroupId) async {

    var res = await MeiJuApi.requestMideaIot(
        '/mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {
          'uid': uid,
          'homegroupId': homegroupId
        }
    );

    if (!res.isSuccess || res.data == null || (res.data['homeList'] is List && res.data['homeList'].length <= 0)) {
      throw Exception('获取家庭列表失败');
    }

    List<dynamic> applianceList = [];

    res.data['homeList'][0]?['roomList']?.forEach((element) {
      if(element['applianceList'] != null) {
        element['applianceList'].forEach((appliance) {
          appliance?['roomName'] = element['name'];
          appliance?['roomId'] = element['roomId'];
        });
        applianceList.addAll(element['applianceList']);
      }
    });

    return MeiJuResponseEntity.fromJson({
      'code': 0,
      'msg': '成功',
      'data': applianceList
    });


  }

  /// 获取某房间下所有的设备
  static Future<MeiJuResponseEntity> queryDeviceListByRoomId(String uid, String homegroupId, String roomId) async {
    var res = await MeiJuApi.requestMideaIot(
        '/mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {
          'uid': uid,
          'homegroupId': homegroupId,
          'roomId': roomId
        }
    );

    if (!res.isSuccess || res.data == null
        || (res.data['homeList'] is List && res.data['homeList'].length <= 0)) {
      throw Exception('获取家庭列表失败');
    }

    List<dynamic> applianceList = [];

    res.data['homeList'][0]?['roomList']?.forEach((element) {
      if(element['applianceList'] != null) {
        applianceList.addAll(element['applianceList']);
      }
    });

    return MeiJuResponseEntity.fromJson({
      'code': 0,
      'msg': '成功',
      'data': applianceList
    });
  }

  /// 获取设备详情（lua）
  static Future<MeiJuResponseEntity> getDeviceDetail(String type, String applianceCode) async {
    var res = await MeiJuApi.requestMzIot<Map<String, dynamic>>(
        "/v1/category/midea/device/status/query",
        data: {
          "applianceCode": applianceCode,
          "categoryCode": type
        },
        options: Options(method: 'POST')
    );
    return res;
  }

  /// 设备lua控制
  static Future<MeiJuResponseEntity> sendLuaOrder({
    required String categoryCode,
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
        options: Options(
          method: 'POST')
    );

    return res;
  }

  /// 设备物模型控制
  static Future<MeiJuResponseEntity> sendPDMOrder({
      required String categoryCode,
      required String uri,
      required String applianceCode,
      required Object command,
    String? method = "PUT"
  }) async {
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

  /// 获取智慧屏继电器详情
  static Future<MeiJuResponseEntity<String>> getGatewayInfo(
      String deviceId, String masterId) async {
    var res = await MeiJuApi.requestMzIot<String>("/v1/category/midea/getGatewayInfo",
        data: {
          "userId": MeiJuGlobal.token?.uid,
          "applianceCode": masterId,
          "devId": deviceId,
        },
        options: Options(method: 'POST'));
    return res;
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
}