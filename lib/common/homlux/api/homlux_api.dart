import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screen_app/common/homlux/homlux_global.dart';
import 'package:screen_app/common/homlux/models/homlux_qr_code_auth_entity.dart';
import 'package:uuid/uuid.dart';

import '../../../widgets/event_bus.dart';
import '../../logcat_helper.dart';
import '../../system.dart';
import '../models/homlux_refresh_token_entity.dart';
import '../models/homlux_response_entity.dart';

const uuid = Uuid();

/// token过期错误码
const tokenExpireCode = 9984;

/// refreshToken过期错误码
const refreshExpireCode = 9861;

/// 刷新token阻塞锁
final _lock = Lock();

class HomluxApi {
  // 单例实例
  static final HomluxApi _instance = HomluxApi._internal();

  HomluxApi._internal();

  factory HomluxApi() {
    return _instance;
  }

  final Dio _dio = Dio(BaseOptions(
    headers: {},
    method: 'POST',
    connectTimeout: 20000,
    receiveTimeout: 20000,
  ));

  static void init() {
    // 全局Https、Http请求监听者
    HomluxApi()
        ._dio
        .interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) {
          Log.i('【onRequest】: ${options.path} \n '
              'method: ${options.method} \n'
              'headers: ${options.headers} \n '
              'data: ${options.data} \n '
              'queryParameters: ${options.queryParameters}  \n');
          return handler.next(options);
        }, onResponse: (response, handler) {
          Log.i('${response.requestOptions.path} \n '
              'onResponse: $response.');
          return handler.next(response);
        }, onError: (e, handler) {
          Log.e('onError:\n'
              '${e.toString()} \n '
              '${e.requestOptions.path} \n'
              '${e.response}');

          return handler.next(e); //continue
        }));
  }

  static Future<HomluxResponseEntity<T>> request<T>(String path,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) {
    return $request('${dotenv.get('HOMLUX_URL')}/mzaio$path',
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  /// 对外提供刷新Token的方法
  static void refreshToken() {
    try {
      _lock.lock();
      _$refreshToken();
    } finally {
      _lock.unlock();
    }
  }
}

Future<HomluxResponseEntity<T>> $request<T>(String path,
    {Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress}) async {
  //// 锁自旋, 等待Token刷新成功
  while (_lock.locked) {
    Log.e("----> 等待Token刷新返回");
    sleep(const Duration(milliseconds: 20));
  }

  options ??= Options();
  options.headers ??= {};
  data ??= {}; // data默认值
  queryParameters ??= {};
  options.extra = options.extra ?? {};
  bool carryToken = options.extra?['carryToken'] ?? true;
  if (carryToken) {
    options.headers?.addAll($tokenHeader());
  }
  data.addAll($commonBodyData());

  var res = await HomluxApi()._dio.request(path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress);

  HomluxResponseEntity<T> response = HomluxResponseEntity.fromJson(res.data);

  /// 重新刷新token, refreshToken
  if (response.code == tokenExpireCode && HomluxGlobal.isLogin) {
    // try {
    //   _lock.lock();

    if (response.code == tokenExpireCode && HomluxGlobal.isLogin) {
      _$refreshToken();
    }
    // } finally {
    //   _lock.unlock();
    // }
  }
  return response;
}

/// 刷新refreshToken
void _$refreshToken() async {
  var refreshToken = await HomluxApi()._dio.request(
      '${dotenv.get('HOMLUX_URL')}/v1/mzgdApi/mzgdUserRefreshToken',
      options: Options(method: 'POST'),
      data: {
        ...$commonBodyData(),
        "refreshToken": HomluxGlobal.homluxQrCodeAuthEntity?.refreshToken
      });
  var entity = HomluxResponseEntity<HomluxRefreshTokenEntity>.fromJson(
      refreshToken.data);
  if (entity.isSuccess) {
    HomluxGlobal.homluxQrCodeAuthEntity = HomluxQrCodeAuthEntity(
        authorizeStatus: 1,
        refreshToken: entity.result?.refreshToken,
        token: entity.result?.token);
  } else if (entity.code == refreshExpireCode) {
    Log.e("refreshToken 过期 即将退出登录");
    // 真正退出逻辑
    System.loginOut();
    bus.emit("logout");
  }
}

/// 通用的Body字段
Map<String, dynamic> $commonBodyData() {
  return {
    "frontendType": "ANDROID",
    "reqId": uuid.v4(),
    "systemSource": "FSMARTSCREEN",
    "timestamp": DateTime.now().millisecondsSinceEpoch
  };
}

/// 通用的Header字段
Map<String, String> $tokenHeader() {
  return {
    'Authorization': 'Bearer ${HomluxGlobal.homluxQrCodeAuthEntity?.token}',
  };
}
