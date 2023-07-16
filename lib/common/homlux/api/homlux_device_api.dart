import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';

import '../models/homlux_device_entity.dart';

class HomluxDeviceApi {

  /// 家庭设备列表接口
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>> queryDeviceListByRoomId(String roomId,
      {CancelToken? cancelToken}) {
    return HomluxApi.request<List<HomluxDeviceEntity>>(
        '/v1/device/queryDeviceInfoByRoomId',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {
          'roomId': roomId
        });
  }

  /// 获取设备列表
  static Future<HomluxResponseEntity<List<HomluxDeviceEntity>>> queryDeviceListByHomeId(String homeId,
      {CancelToken? cancelToken}) {
    return HomluxApi.request(
      '/v1/device/queryDeviceInfoByHouseId',
      cancelToken: cancelToken,
      options: Options(method: 'POST'),
      data: {
        'houseId': homeId
      }
    );
  }

}
