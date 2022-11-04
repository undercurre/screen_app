import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api.dart';
import '../../models/index.dart';

class IotApi {
  /// 登录接口，登录成功后返回用户信息
  static Future<IotResult<QrCode>> getQrCode() async {
    var res = await Api.requestIot<QrCode>(
        "/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': '38f6b0a50b2328ea428293858a726671', 'checkType': 1},
        options: Options(method: 'POST', extra: {'isEncrypt': false}));

    return IotResult<QrCode>.translate(
        res.code, res.msg, QrCode.fromJson(res.data));
  }

  /// 登录接口，登录成功后返回用户信息
  static Future<IotResult<AccessToken>> getAccessToken(sessionId) async {
    var res = await Api.requestIot(
        "/muc/v5/app/mj/screen/auth/pollingGetAccessToken",
        queryParameters: {'sessionId': sessionId},
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

    Api.tokenInfo = AccessToken.fromJson(res.data);

    return IotResult<AccessToken>.translate(
        res.code, res.msg, AccessToken.fromJson(res.data));
  }

  /// 自动登录接口
  static Future autoLogin() async {
    var rule = 1;
    var res = await Api.requestIot("/muc/v5/app/mj/user/autoLogin",
        data: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'data': {
            'uid': Api.tokenInfo.uid,
            'tokenPwd': Api.tokenInfo.tokenPwd,
            'rule': rule,
            'deviceId': Api.tokenInfo.deviceId,
            'platform': 100,
          }
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Api.tokenInfo.accessToken},
        ));

    if (!res.isSuccess) {
      return;
    }

    // 刷新Api.tokenInfo.accessToken
    if (rule == 1) {
      Api.tokenInfo.accessToken = res.data['accessToken'];
      Api.tokenInfo.expired = res.data['expired'];
    } else if (rule == 0) {
      // 刷新的令牌密码tokenPwd
      Api.tokenInfo.tokenPwd = res.data['tokenPwd'];
      Api.tokenInfo.expired = res.data['expiredDate'];
    }
  }

  /// 获取用户所有家庭的家电列表
  static void getHomeList({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await Api.requestIot("/mas/v5/app/proxy?alias=/v1/appliance/home/list/get",
        data: {
          'homegroupId': homegroupId,
          'roomId': roomId,
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Api.tokenInfo.accessToken},
        ));

    if (!res.isSuccess) {
      return;
    }
  }

  /// 获取用户的家庭列表
  static Future<IotResult<HomegroupList>> getHomegroup() async {
    final now = DateTime.now();
    var res = await Api.requestIot("/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {'stamp': now.microsecondsSinceEpoch.toString()},
        options: Options(
          method: 'POST',
          headers: {'accessToken': Api.tokenInfo.accessToken},
        ));

    return IotResult<HomegroupList>.translate(res.code, '', HomegroupList.fromJson(res.data));
  }
