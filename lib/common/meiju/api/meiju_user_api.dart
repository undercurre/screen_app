import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/common/meiju/meiju_global.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../logcat_helper.dart';
import '../models/meiju_home_list_info_entity.dart';
import '../models/meiju_login_home_list_entity.dart';
import '../models/meiju_qr_code_entity.dart';
import '../models/meiju_user_entity.dart';
import 'meiju_api.dart';

class MeiJuUserApi {
  /// 获取授权登录二维码
  static Future<MeiJuResponseEntity<MeiJuQrCodeEntity>> queryQrCode() async {
    MeiJuResponseEntity<MeiJuQrCodeEntity> res =
        await MeiJuApi.requestMideaIot<MeiJuQrCodeEntity>(
            "/muc/v5/app/mj/screen/auth/getQrCode",
            data: {'deviceId': System.deviceId, 'checkType': 1},
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
      Log.file("美居接口授权成功");
      MeiJuTokenEntity token = res.data!;
      int tryCount = 3;
      var authResult = false;
      while (tryCount > 0) {
        var authMzRes = await authMzPlatform(token);
        if (authMzRes.isSuccess) {
          Log.file("美居-美智接口授权成功");
          token.mzAccessToken = authMzRes.data?['accessToken'];
          authResult = true;
          break;
        } else {
          Log.file("美居-美智接口授权失败");
        }
        tryCount--;
      }
      if (authResult) {
        MeiJuGlobal.token = res.data;
      } else {
        // 强制修改请求错误，美智中台授权失败
        res.code = -9999;
      }
    }

    return res;
  }

  /// 获取家庭信息 homegroupId 为空时，返回所有的家庭信息
  static Future<MeiJuResponseEntity<MeiJuHomeInfoListEntity>>
      getHomeDetail({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await MeiJuApi.requestMideaIot<MeiJuHomeInfoListEntity>(
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
  static Future<MeiJuResponseEntity<MeiJuLoginHomeListEntity>>
      getHomeListFromMidea() async {
    var res = await MeiJuApi.requestMideaIot<MeiJuLoginHomeListEntity>(
        "/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {},
        options: Options(
          method: 'POST',
        ));

    return res;
  }

  /// 美智中台——美居体系鉴权请求
  /// 入参：uid，accessToken，deviceId
  static Future<MeiJuResponseEntity> authMzPlatform(MeiJuTokenEntity entity) async {
    return authTokenWithParams(System.deviceId, entity.accessToken, entity.uid);
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
          'tokenExpires': DateTime.timestamp().add(const Duration(hours: 2)).millisecondsSinceEpoch,
        },
        options: Options(method: 'POST', extra: {'isSign': true}));

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
