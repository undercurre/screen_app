import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/global.dart';

import 'api.dart';
import '../../models/index.dart';

class MzApi {
  /// 美居体系鉴权请求
  static Future<MzIotResult<QrCode>> authToken() async {
    var res = await Api.requestMzIot<QrCode>("/v1/openApi/auth/midea/token",
        data: {
          'appId': dotenv.get('APP_ID'),
          'appSecret': dotenv.get('APP_SECRET'),
          'itAccessToken': Global.user?.accessToken,
          'tokenExpires': (24 * 60 * 60).toString(),
        },
        options: Options(
          method: 'POST',
        ));

    return MzIotResult<QrCode>.translate(
        res.code, res.msg, QrCode.fromJson(res.result));
  }
}
