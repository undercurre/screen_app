import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/index.dart';
import '../index.dart';

class AiAuthorApi {

  static var aiUpdateTokenUrl = "${dotenv.get('NOTICE_AI_CLOUD_HOST')}/v1/user/token/meiju";

  /// ai语音授权
  static Future<MideaResponseEntity<String>> AiAuthor(
      {String? deviceId}) async {
    var res = await Api.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/mj/user/auth/device",
        data: {
          'data': {
            "deviceId":deviceId,
            "aiUpdateTokenUrl":aiUpdateTokenUrl
          },
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    return res;
  }
}
