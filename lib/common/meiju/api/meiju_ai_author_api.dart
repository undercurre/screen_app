import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import 'meiju_api.dart';

class MeiJuAiAuthorApi {

  static var aiUpdateTokenUrl = "${dotenv.get('NOTICE_AI_CLOUD_HOST')}/v1/user/token/meiju";

  /// ai语音授权
  static Future<MeiJuResponseEntity<String>> AiAuthor(
      {String? deviceId}) async {
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/mj/user/auth/device",
        data: {
          'data': {
            "deviceId":deviceId,
            "aiUpdateTokenUrl":aiUpdateTokenUrl
          },
        },
      options: Options(method: 'POST')
    );

    return res;
  }
}
