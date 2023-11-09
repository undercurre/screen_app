import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/api/homlux_api.dart';
import 'package:screen_app/common/homlux/models/homlux_family_entity.dart';
import 'package:screen_app/common/homlux/models/homlux_member_entity.dart';
import 'package:screen_app/common/homlux/models/homlux_response_entity.dart';
import 'package:screen_app/common/index.dart';

import '../../logcat_helper.dart';
import '../homlux_global.dart';
import '../models/homlux_auth_entity.dart';
import '../models/homlux_bind_device_entity.dart';
import '../models/homlux_qr_code_auth_entity.dart';
import '../models/homlux_qr_code_entity.dart';
import '../models/homlux_room_list_entity.dart';
import '../models/homlux_user_info_entity.dart';

class HomluxUserApi {
  /// 房间列表
  static Map<String, HomluxResponseEntity<HomluxRoomListEntity>> _cacheRoomList = {};

  /// 清除内存缓存
  static void clearMemoryCache() {
    _cacheRoomList.clear();
  }

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
      {CancelToken? cancelToken}) async {

    Future<HomluxResponseEntity<HomluxRoomListEntity>> getCacheData() async {
      if(_cacheRoomList.containsKey(houseId)) {
        return _cacheRoomList[houseId]!;
      } else {
        var jsonStr = await LocalStorage.getItem('homlux_login_room_list_$houseId');
        if(StrUtils.isNotNullAndEmpty(jsonStr)) {
          var entity = HomluxResponseEntity<HomluxRoomListEntity>.fromJson(jsonDecode(jsonStr!));
          _cacheRoomList[houseId] = entity;
          return entity;
        }
      }

      return HomluxResponseEntity<HomluxRoomListEntity>()
        ..code = -1
        ..msg = '请求失败'
        ..success = false;
    }

    void saveCache(HomluxResponseEntity<HomluxRoomListEntity>? res, [bool clear = false]) {
      if(clear) {
        _cacheRoomList.remove(houseId);
        LocalStorage.removeItem('homlux_login_room_list_$houseId');
      } else if(res != null) {
        _cacheRoomList[houseId] = res;
        LocalStorage.setItem('homlux_login_room_list_$houseId', jsonEncode(res.toJson()));
      }
    }
    try {
      var res = await HomluxApi.request<HomluxRoomListEntity>('/v1/mzgd/user/house/queryRoomList',
          cancelToken: cancelToken,
          options: Options(method: 'POST'),
          data: {'houseId': houseId});

      if(res.isSuccess) {
        Log.i('查询房间成功', res.result?.roomInfoWrap?.map((e) => e.roomName));
        saveCache(res, res.result == null);
      }
      return res;
    } catch(e) {
      Log.i("请求房间列表失败");
    }

    return getCacheData();

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
      int tryCount = 3;
      bool operateSuc = false;
      while(tryCount > 0) {
        var userRes = await queryUserInfo(null, res.data?.token);
        if (userRes.isSuccess && userRes.data  != null) {
          HomluxGlobal.homluxUserInfo = userRes.data;
          HomluxGlobal.homluxQrCodeAuthEntity = res.data;
          operateSuc = true;
        }
        tryCount --;
      }

      if(!operateSuc) {
        // 改写请求结果
        res.code = -1048;
      }

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

  // 查询用户信息
  // uid 为空 则查询自己的信息
  static Future<HomluxResponseEntity<HomluxUserInfoEntity>> queryUserInfo(String? uid, String? token,
      {CancelToken? cancelToken}) async {

    var res =  await HomluxApi.request<HomluxUserInfoEntity>(
        '/v1/mzgd/user/queryWxUserInfo',
        cancelToken: cancelToken,
        options: Options(
            method: 'POST',
            extra: {"carryToken": token == null},
            headers: token != null
                ? {'Authorization': 'Bearer $token'}
                : null),
        data: {"userId": uid});

    if(res.isSuccess && res.data != null) {
      HomluxGlobal.homluxUserInfo = res.data;
    }

    return res;
  }

  // 绑定设备
  static Future<HomluxResponseEntity<HomluxBindDeviceEntity>> bindDevice(
      String deviceName,
      String houseId,
      String roomId,
      String sn,
      String deviceType,
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

  // 解绑设备
  static Future<HomluxResponseEntity> deleteDevices(List<Map<String, String>> devices, {CancelToken? cancelToken}) {
    return HomluxApi.request(
      '/v1/device/batchDelDevice',
        cancelToken: cancelToken,
      options: Options(method: 'POST'),
      data: {
        'deviceBaseDeviceVoList': devices
      }
    );
  }

  // 是否能够授权登录
  // 绑定设备
  static Future<HomluxResponseEntity<HomluxAuthEntity>> queryHouseAuth(String houseId,
      {CancelToken? cancelToken}) {
    return HomluxApi.request<HomluxAuthEntity>(
        '/v1/mzgd/user/queryUserHouseInfo',
        cancelToken: cancelToken,
        options: Options(method: 'POST'),
        data: {'houseId': houseId});
  }

  /// 修改设备房间
  /// [deviceType] 1 网关 2 子设备 3wifi设备
  /// [type] type :0 仅更改设备 1 仅更改房间 2 所有都更改 3 仅开关更改
  static Future<HomluxResponseEntity> modifyDevice(String deviceType, String type, String houseId,
      String roomId, String deviceId, {CancelToken? cancelToken}) {
    return HomluxApi.requestSafety(
      '/v1/device/batchUpdate',
      cancelToken: cancelToken,
      options: Options(method: 'POST'),
      data: {
        'deviceInfoUpdateVoList': [
          {
            'deviceType': deviceType,
            'type': type,
            'roomId': roomId,
            'houseId': houseId,
            'deviceId': deviceId
          }
        ]
      }
    );
  }

}
