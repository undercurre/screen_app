import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/index.dart';

import '../../models/index.dart';
import 'api.dart';

class UserApi {
  /// 获取授权登录二维码
  static Future<MideaResponseEntity<QrCodeEntity>> getQrCode() async {
    MideaResponseEntity<QrCodeEntity> res =
        await Api.requestMideaIot<QrCodeEntity>(
      "/muc/v5/app/mj/screen/auth/getQrCode",
      data: {'deviceId': Global.profile.deviceId, 'checkType': 1},
      options: Options(method: 'POST'),
      isShowLoading: false,
    );

    return res;
  }

  /// 登录接口，登录成功后返回用户信息
  static Future<MideaResponseEntity<UserEntity>> getAccessToken(
      String sessionId) async {
    var res = await Api.requestMideaIot<UserEntity>(
      "/muc/v5/app/mj/screen/auth/pollingGetAccessToken",
      queryParameters: {
        'sessionId': sessionId,
      },
      options: Options(method: 'GET'),
      isShowLoading: false,
      isLog: false,
    );

    if (res.isSuccess) {
      Global.user = res.data;
    }

    return res;
  }

  /// 自动登录接口
  static Future<bool> autoLogin() async {
    var rule = 1;
    var res = await Api.requestMideaIot("/muc/v5/app/mj/user/autoLogin",
        data: {
          'data': {
            'uid': Global.user?.uid,
            'tokenPwd': Global.user?.tokenPwd,
            'rule': rule,
            'deviceId': Global.user?.deviceId,
            'platform': 100,
          }
        },
        isShowLoading: false,
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    if (res.code == 65012) {
      System.loginOut();
    }

    if (!res.isSuccess) {
      return false;
    }

    // 刷新Global.user.accessToken
    if (rule == 1) {
      Global.user?.accessToken = res.data['accessToken'];
      Global.user?.expired = res.data['expired'];
      var time = DateTime.fromMillisecondsSinceEpoch(
          Global.user?.expired?.toInt() ?? 0);
      debugPrint('美的Iot的token过期时间: $time');
    } else if (rule == 0) {
      // 刷新的令牌密码tokenPwd
      Global.user?.tokenPwd = res.data['tokenPwd'];
      Global.user?.expired = res.data['expiredDate'];
    }
    return true;
  }

  /// 获取用户所有家庭的家电列表
  static Future<MideaResponseEntity<HomeListEntity>> getHomeListWithDeviceList({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await Api.requestMideaIot<HomeListEntity>(
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
  static Future<MideaResponseEntity<HomeListEntity>>
      getHomeListFromMidea() async {
    var res = await Api.requestMideaIot<HomeListEntity>(
        "/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {},
        options: Options(
          method: 'POST',
        ));

    return res;
  }

  /// 美智中台——美居体系鉴权请求
  static Future<MzResponseEntity> authToken() async {
    return authTokenWithParams(Global.user?.deviceId, Global.user?.accessToken);
  }

  static Future<MzResponseEntity> authTokenWithParams(String? deviceId, String? itAccessToken) async {
    var res = await Api.requestMzIot("/v1/openApi/auth/midea/token",
        data: {
          'deviceId': deviceId,
          'appId': dotenv.get('APP_ID'),
          'appSecret': dotenv.get('APP_SECRET'),
          'itAccessToken': itAccessToken,
          'tokenExpires': (24 * 60 * 60).toString(),
        },
        isShowLoading: false,
        options: Options(method: 'POST', extra: {'isSign': true}));

    if (res.isSuccess) {
      Global.user?.mzAccessToken = res.result['accessToken'];
    }

    return res;
  }

  /// 家庭列表查询
  static Future<MzResponseEntity> getHomeList() async {
    var res = await Api.requestMzIot<QrCodeEntity>(
        "/v1/category/midea/user/homeGroup/list",
        data: {},
        options: Options(
          method: 'POST',
        ));

    return res;
  }

  /// 设备绑定到家庭
  static Future<MideaResponseEntity> bindHome(
      {required String sn,
      String? applianceName,
      required String applianceType}) async {
    var res = await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/appliance/home/bind",
        data: {
          'sn': sn,
          'applianceName': applianceName,
          'homegroupId': Global.profile.homeInfo?.homegroupId,
          'applianceType': applianceType,
          'modelNumber': Global.sn8,
          'roomId': Global.profile.roomInfo?.roomId,
        },
        options: Options(
          method: 'POST',
        ));

    Global.profile.applianceCode = res.data['applianceCode'];

    return res;
  }
}
