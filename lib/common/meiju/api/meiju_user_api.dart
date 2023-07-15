import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../../models/home_list_entity.dart';
import '../models/meiju_home_list_entity.dart';
import '../models/meiju_qr_code_entity.dart';
import '../models/meiju_user_entity.dart';
import 'meiju_api.dart';

class MeiJuUserApi {
  /// 获取授权登录二维码
  static Future<MeiJuResponseEntity<MeiJuQrCodeEntity>> getQrCode() async {
    MeiJuResponseEntity<MeiJuQrCodeEntity> res =
        await MeiJuApi.requestMideaIot<MeiJuQrCodeEntity>(
            "/muc/v5/app/mj/screen/auth/getQrCode",
            data: {'deviceId': Global.profile.deviceId, 'checkType': 1},
            options: Options(method: 'POST'));
    return res;
  }

  /// 登录接口，登录成功后返回用户信息
  static Future<MeiJuResponseEntity<MeiJuTokenEntity>> getAccessToken(
      String sessionId) async {
    var res = await MeiJuApi.requestMideaIot<MeiJuTokenEntity>(
        "/muc/v5/app/mj/screen/auth/pollingGetAccessToken",
        queryParameters: {
          'sessionId': sessionId,
        },
        options: Options(method: 'GET'));

    if (res.isSuccess) {
      MeiJuGlobal.token = res.data;
    }

    return res;
  }

  /// 获取用户所有家庭的家电列表
  static Future<MeiJuResponseEntity<MeiJuHomeListEntity>>
      getHomeListWithDeviceList({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await MeiJuApi.requestMideaIot<MeiJuHomeListEntity>(
        "/mas/v5/app/proxy?alias=/v1/appliance/home/list/get",
        data: {
          'homegroupId': homegroupId,
          'roomId': roomId,
        },
        options: Options(
          method: 'POST',
        ));

    return res;
  }

  /// 获取用户的家庭列表——美的iot中台
  static Future<MeiJuResponseEntity<HomeListEntity>>
      getHomeListFromMidea() async {
    var res = await MeiJuApi.requestMideaIot<HomeListEntity>(
        "/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {},
        options: Options(
          method: 'POST',
        ));

    return res;
  }

  /// 美智中台——美居体系鉴权请求
  static Future<MeiJuResponseEntity> authToken() async {
    return authTokenWithParams(MeiJuGlobal.token?.deviceId,
        MeiJuGlobal.token?.accessToken, MeiJuGlobal.token?.iotUserId);
  }

  static Future<MeiJuResponseEntity> authTokenWithParams(
      String? deviceId, String? itAccessToken, String? uid) async {
    var res = await MeiJuApi.requestMzIot("/v1/openApi/auth/midea/token",
        data: {
          'userId': uid,
          'deviceId': deviceId,
          'appId': dotenv.get('APP_ID'),
          'appSecret': dotenv.get('APP_SECRET'),
          'itAccessToken': itAccessToken,
          'tokenExpires': (8 * 60 * 60).toString(),
        },
        options: Options(method: 'POST', extra: {'isSign': true}));

    if (res.isSuccess) {
      MeiJuGlobal.token?.mzAccessToken = res.data?['accessToken'];
    }

    return res;
  }

  /// 设备绑定到家庭
  static Future<MeiJuResponseEntity> bindHome(
      {required String sn,
      String? applianceName,
      required String homegroupId,
      required String roomId,
      required String applianceType,
      required String modelNumber
      }) async {
    var res = await MeiJuApi.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/appliance/home/bind",
        data: {
          'sn': sn,
          'applianceName': applianceName,
          'homegroupId': homegroupId,
          'applianceType': applianceType,
          'modelNumber': modelNumber,
          'roomId': roomId,
        },
        options: Options(
          method: 'POST',
        ));

    // if(res.isSuccess) {
    //   MeiJuGlobal.gatewayApplianceCode = res.data['applianceCode'];
    // }

    return res;
  }
}
