import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/global.dart';

import '../../states/index.dart';
import 'api.dart';
import '../../models/index.dart';

class UserApi {
  /// 获取授权登录二维码
  static Future<MideaIotResult<QrCode>> getQrCode() async {
    var res = await Api.requestMideaIot<QrCode>(
        "/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': Global.profile.deviceId, 'checkType': 1},
        options: Options(method: 'POST', extra: {'isEncrypt': false}));

    return MideaIotResult<QrCode>.translate(
        res.code, res.msg, QrCode.fromJson(res.data));
  }

  /// 登录接口，登录成功后返回用户信息
  static Future<MideaIotResult<User>> getAccessToken(sessionId) async {
    var res = await Api.requestMideaIot(
        "/muc/v5/app/mj/screen/auth/pollingGetAccessToken",
        queryParameters: {
          'sessionId': sessionId,
        },
        options: Options(method: 'GET', extra: {'isEncrypt': false}));

    res.data ??= {
      "accessToken": "",
      "deviceId": "",
      "iotUserId": "",
      "key": "",
      "openId": "",
      "seed": "",
      "sessionId": "",
      "tokenPwd": "",
      "uid": ""
    };

    if (res.isSuccess) {
      Global.user = User.fromJson(res.data);
    }

    return MideaIotResult<User>.translate(
        res.code, res.msg, User.fromJson(res.data));
  }

  /// 自动登录接口,
  static Future autoLogin() async {
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
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    if (res.code == 65012) {
      UserModel().user = null;
    }

    if (!res.isSuccess) {
      return;
    }

    // 刷新Global.user.accessToken
    if (rule == 1) {
      Global.user?.accessToken = res.data['accessToken'];
      Global.user?.expired = res.data['expired'];
      var time = DateTime.fromMillisecondsSinceEpoch(
          Global.user?.expired?.toInt() ?? 0);
      debugPrint('token过期时间: $time');
    } else if (rule == 0) {
      // 刷新的令牌密码tokenPwd
      Global.user?.tokenPwd = res.data['tokenPwd'];
      Global.user?.expired = res.data['expiredDate'];
    }
  }

  /// 获取用户所有家庭的家电列表
  static Future getHomeListWithDeviceList({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/appliance/home/list/get",
        data: {
          'homegroupId': homegroupId,
          'roomId': roomId,
        },
        options: Options(
          method: 'POST',
        ));

    return MideaIotResult<HomegroupList>.translate(
        res.code, '', HomegroupList.fromJson(res.data));
  }

  /// 获取用户的家庭列表
  static Future<MideaIotResult<HomegroupList>> getHomegroup() async {
    var res = await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {},
        options: Options(
          method: 'POST',
        ));

    return MideaIotResult<HomegroupList>.translate(
        res.code, '', HomegroupList.fromJson(res.data));
  }

  /// 美智中台——美居体系鉴权请求
  static Future<MzIotResult> authToken() async {
    var res = await Api.requestMzIot<QrCode>("/v1/openApi/auth/midea/token",
        data: {
          'deviceId': Global.user?.deviceId,
          'appId': dotenv.get('APP_ID'),
          'appSecret': dotenv.get('APP_SECRET'),
          'itAccessToken': Global.user?.accessToken,
          'tokenExpires': (24 * 60 * 60).toString(),
        },
        options: Options(method: 'POST', extra: {'isSign': true}));

    if (res.isSuccess) {
      Global.user?.mzAccessToken = res.result['accessToken'];
    }

    return res;
  }

  /// 家庭列表查询
  static Future<MzIotResult> getHomeList() async {
    var res =
        await Api.requestMzIot<QrCode>("/v1/category/midea/user/homeGroup/list",
            data: {},
            options: Options(
              method: 'POST',
            ));

    return res;
  }
}
