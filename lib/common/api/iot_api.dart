import 'package:dio/dio.dart';

import '../global.dart';
import 'api.dart';
import '../../models/index.dart';

class IotApi {
  /// 登录接口，登录成功后返回用户信息
  static Future<MideaIotResult<QrCode>> getQrCode() async {
    var res = await Api.requestMideaIot<QrCode>(
        "/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': '38f6b0a50b2328ea428293858a726671', 'checkType': 1},
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
        options: Options(
            method: 'GET',
            extra: {'isEncrypt': false}));

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

  /// 自动登录接口
  static Future autoLogin() async {
    var rule = 1;
    var res = await Api.requestMideaIot("/muc/v5/app/mj/user/autoLogin",
        data: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
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

    if (!res.isSuccess) {
      return;
    }

    // 刷新Global.user.accessToken
    if (rule == 1) {
      Global.user?.accessToken = res.data['accessToken'];
      Global.user?.expired = res.data['expired'];
    } else if (rule == 0) {
      // 刷新的令牌密码tokenPwd
      Global.user?.tokenPwd = res.data['tokenPwd'];
      Global.user?.expired = res.data['expiredDate'];
    }
  }

  /// 获取用户所有家庭的家电列表
  static void getHomeList({
    String? homegroupId,
    String? roomId,
  }) async {
    var res = await Api.requestMideaIot("/mas/v5/app/proxy?alias=/v1/appliance/home/list/get",
        data: {
          'homegroupId': homegroupId,
          'roomId': roomId,
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    if (!res.isSuccess) {
      return;
    }
  }

  /// 获取用户的家庭列表
  static Future<MideaIotResult<HomegroupList>> getHomegroup() async {
    var res = await Api.requestMideaIot("/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {},
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return MideaIotResult<HomegroupList>.translate(res.code, '', HomegroupList.fromJson(res.data));
  }

  /// TODO 获取天气
  static Future<dynamic> getWeather() async {
    var res = await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/weather/observe/byCityId",
        data: {
          "appId": "APP",
          'cityId': "101280801",
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));
    logger.i(res.toString());

    // return MideaIotResult<HomegroupList>.translate(
    //     res.code, '', HomegroupList.fromJson(res.data));
  }
}
