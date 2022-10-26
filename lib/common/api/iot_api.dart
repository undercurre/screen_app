import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


import 'api.dart';
import '../../models/index.dart';

class IotApi {
  /// 登录接口，登录成功后返回用户信息
  static Future<IotResult<QrCode>> getQrCode() async {
    var res = await Api.requestIot<QrCode>("/muc/v5/app/mj/screen/auth/getQrCode",
        data: {'deviceId': '38f6b0a50b2328ea428293858a726671', 'checkType': 1},
        options: Options(
            method: 'POST',
            extra: { 'isEncrypt': false }
        ));


    return IotResult<QrCode>.translate(res.code, res.msg, QrCode.fromJson(res.data));
  }

  /// 登录接口，登录成功后返回用户信息
  static Future getAccessToken(sessionId) async {
    debugPrint("${sessionId.runtimeType}");
    var res = await Api.requestIot("/muc/v5/app/mj/screen/auth/pollingGetAccessToken",
        data: { 'sessionId': sessionId },
        queryParameters: { 'sessionId': sessionId },
        options: Options(
            method: 'GET',
            extra: { 'isEncrypt': false }
        ));

    return res;
  }

  /// 获取用户的家庭列表
  static Future<IotResult<HomegroupList>> getHomegroup() async {
    final now = DateTime.now();
    var res =
    await Api.requestIot<HomegroupList>("/mas/v5/app/proxy?alias=/v1/homegroup/list/get",
        data: {'stamp': now.microsecondsSinceEpoch.toString()},
        options: Options(method: 'POST', extra: {
          'isEncrypt': false
        }, headers: {
          'sign':
          'b8915169907a00b7f707d0c107627256208e6995165d254081d0f6708dbc7aff',
          'accessToken': 'T1d6sx09vrwg5tbl3',
          'Content-Type': 'application/json'
        }));

    return IotResult<HomegroupList>.translate(res.code, '', HomegroupList.fromJson(res.data));
  }

}
