import 'dart:async';

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

bool refreshTokenActive = false;

/// token过期错误码
const tokenExpireCode = 9984;

/// refreshToken过期错误码
const refreshExpireCode = 9861;

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
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  static void init() {
    // 全局Https、Http请求监听者
    HomluxApi()
        ._dio
        .interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) {
          Log.file('【onRequest】: ${options.path} \n '
              'method: ${options.method} \n'
              'headers: ${options.headers} \n '
              'data: ${options.data} \n '
              'queryParameters: ${options.queryParameters}  \n');
          return handler.next(options);
        }, onResponse: (response, handler) {
          Log.file('${response.requestOptions.path} \n ''onResponse: $response.');

          return handler.next(response);
        }, onError: (e, handler) {
          Log.file('onError:\n'
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
    _$refreshToken();
  }
}

Future<HomluxResponseEntity<T>> $request<T>(String path,
    {Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress}) async {

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
    _$refreshToken();
  }

  return response;
}

/// 刷新refreshToken
void _$refreshToken() async {
  if (!refreshTokenActive) {
    try {
      refreshTokenActive = true;
      var refreshToken = await HomluxApi()._dio.request(
          '${dotenv.get('HOMLUX_URL')}/mzaio/v1/mzgdApi/mzgdUserRefreshToken',
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
        Log.file("refreshToken 成功 ${HomluxGlobal.homluxQrCodeAuthEntity?.toJson()}");
      } else if (entity.code == refreshExpireCode) {
        Log.file("refreshToken 过期 即将退出登录");
        // 真正退出逻辑
        System.logout();
        bus.emit("logout");
      }
    } finally {
      refreshTokenActive = false;
    }
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
