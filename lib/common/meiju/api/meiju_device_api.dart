import 'dart:async';

import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/api/meiju_api.dart';
import '../models/meiju_device_info_entity.dart';
import '../models/meiju_response_entity.dart';

class MeiJuDeviceApi {

  /// 获取某家庭下所有的设备
  static Future<MeiJuResponseEntity<List<MeiJuDeviceInfoEntity>>> queryDeviceListByHomeId(String uid, String homegroupId) async {

    var res = await MeiJuApi.requestMideaIot(
        'mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {
          'uid': uid,
          'homegroupId': homegroupId
        }
    );

    if (!res.isSuccess || res.data == null
        || res.data['homeList'] is List || res.data['homeList'].length <= 0) {
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

  /// 获取某房间下所有的设备
  static Future<MeiJuResponseEntity> queryDeviceListByRoomId(String uid, String homegroupId, String roomId) async {
    var res = await MeiJuApi.requestMideaIot(
        'mas/v5/app/proxy?alias=/v1/appliance/home/list/get',
        options: Options(method: 'POST'),
        data: {
          'uid': uid,
          'homegroupId': homegroupId,
          'roomId': roomId
        }
    );

    if (!res.isSuccess || res.data == null
        || res.data['homeList'] is List || res.data['homeList'].length <= 0) {
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

}