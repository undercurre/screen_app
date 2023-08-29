

import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';

import '../models/homlux_response_entity.dart';

class HomluxLanDeviceApi {

  /// ******************
  /// 获取局域网控制key
  /// *******************
  static Future<HomluxResponseEntity<String>> queryLocalKey(String houseId, {CancelToken? cancelToken}) {
    return HomluxApi.request(
      '/v1/device/queryLocalKey',
      data: {
        'houseId': houseId
      },
      cancelToken: cancelToken
    );
  }

}