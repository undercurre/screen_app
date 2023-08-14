import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';

import '../models/homlux_dui_token_entity.dart';

class HomluxDuiTokenApi {

  /// 思必驰语音token接口
  static Future<HomluxResponseEntity<HomluxDuiTokenEntity>> queryDuiToken(String houseId, String clientId,
      {CancelToken? cancelToken}) {

    return HomluxApi.request<HomluxDuiTokenEntity>(
        '/v1/thirdparty/dui/get/oauth2/access_token',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {
          'client_id': clientId,
          'houseId': houseId
        });
  }

}
