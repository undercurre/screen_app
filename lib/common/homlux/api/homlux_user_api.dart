import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/models/homlux_family_entity.dart';
import 'package:screen_app/common/homlux/models/homlux_member_entity.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';

import '../HomluxGlobal.dart';
import '../models/homlux_bind_device_entity.dart';
import '../models/homlux_qr_code_auth_entity.dart';
import '../models/homlux_qr_code_entity.dart';
import '../models/homlux_room_list_entity.dart';

class HomluxUserApi {
  /// 家庭列表接口
  static Future<HomluxResponseEntity<List<HomluxFamilyEntity>>> queryFamilyList(
      {CancelToken? cancelToken}) {
    return HomluxApi.request<List<HomluxFamilyEntity>>(
        '/v1/mzgd/user/house/queryHouseList',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {});
  }

  /// 请求房间列表
  static Future<HomluxResponseEntity<HomluxRoomListEntity>> queryRoomList(
      String houseId,
      {CancelToken? cancelToken}) {
    return HomluxApi.request('/v1/mzgd/user/house/queryRoomList',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'houseId': houseId});
  }

  /// 请求家庭成员
  static Future<HomluxResponseEntity<HomluxMemberListEntity>> queryMemberList(
      String houseId,
      {int currentPage = 1,
      pageSize = 100,
      CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxMemberListEntity>(
        '/v1/mzgd/user/house/queryHouseUserList',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {
          'currentPage': currentPage,
          'pageSize': pageSize,
          'houseId': houseId
        });
  }

  // 获取二维码
  static Future<HomluxResponseEntity<HomluxQrCodeEntity>> queryQrCode(
      {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxQrCodeEntity>('/v1/mzgdApi/auth/mzgd/qrcode',
        cancelToken: cancelToken,
        options: Options(method: 'POST', extra: {"carryToken": false}),
        data: {});
  }

  // 轮询授权码是否确认授权成功
  static Future<HomluxResponseEntity<HomluxQrCodeAuthEntity>> getAccessToken(
      String qrCode,
      {CancelToken? cancelToken}) async {
    var res = await HomluxApi.request<HomluxQrCodeAuthEntity>(
        '/v1/mzgdApi/auth/mzgd/qrcodeLogin',
        cancelToken: cancelToken,
        options: Options(method: 'POST', extra: {"carryToken": false}),
        data: {"qrcode": qrCode});

    if (res.isSuccess && res.data?.authorizeStatus == 1) {
      HomluxGlobal.homluxQrCodeAuthEntity = res.data;
    }

    return res;
  }

  // 刷新Token接口
  static Future<HomluxResponseEntity> refreshToken(String refreshToken,
      {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxQrCodeAuthEntity>(
        '/v1/mzgdApi/mzgdUserRefreshToken',
        cancelToken: cancelToken,
        options: Options(method: 'POST', extra: {"carryToken": false}),
        data: {"refreshToken": refreshToken});
  }

  // 绑定设备
  static Future<HomluxResponseEntity<HomluxBindDeviceEntity>> bindDevice(String deviceName,
      String houseId, String roomId, String sn, String deviceType,
      {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxBindDeviceEntity>('/v1/device/bindDevice',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {
          'deviceName': deviceName,
          'houseId': houseId,
          'roomId': roomId,
          'deviceType': deviceType,
          'sn': sn
        });
  }
}
