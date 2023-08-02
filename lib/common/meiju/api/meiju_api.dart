import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:uuid/uuid.dart';

import '../../global.dart';
import '../../logcat_helper.dart';
import '../../utils.dart';
import '../meiju_global.dart';

const uuid = Uuid();

class MeiJuApi {
  // 单例实例
  static final MeiJuApi _instance = MeiJuApi._internal();

  MeiJuApi._internal();

  factory MeiJuApi() {
    return _instance;
  }

  /// 密钥
  static var secret = dotenv.get('SECRET');

  //签名密钥
  static var httpSignSecret = dotenv.get('HTTP_SIGN_SECRET');

  static const int TOO_LONG_UNLOGIN = 1004;
  static const int TOKEN_INVALID = 65012;
  static const int TOKEN_EXPIRED = 65013;
  static const int ACCOUNT_LOGOUT = 40002;

  final Dio _dio = Dio(BaseOptions(
    headers: {},
    method: 'POST',
    connectTimeout: 20000,
    receiveTimeout: 20000,
  ));

  static void init() {
    // 全局Https、Http请求监听者
    MeiJuApi()
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

          return handler.next(e);
        }));
  }

  /// IOT接口发起公共接口
  ///
  static Future<MeiJuResponseEntity<T>> requestMideaIot<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress
  }) async {
    options ??= Options();
    options.headers ??= {};
    data ??= {};
    queryParameters ??= {};
    options.extra ??= {};

    var reqId = uuid.v4();
    var params = options.method == 'GET' ? queryParameters : data;
    var headers = options.headers as LinkedHashMap<String, dynamic>;

    // 公共data参数
    var timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    params['openId'] = 'zhinengjiadian';
    params['iotAppId'] = '12002';
    params['reqId'] = reqId;
    params['stamp'] = timestamp;
    params['timestamp'] = timestamp;

    if (MeiJuGlobal.isLogin) {
      params['uid'] = MeiJuGlobal.token?.uid;
      headers['accessToken'] = MeiJuGlobal.token?.accessToken;
    }

    // 公共header参数
    // 云端接口出错时，返回调试信息
    if (!MeiJuGlobal.isRelease) {
      headers['debug'] = true;
    }

    // sign签名 start
    var md5Origin = httpSignSecret; // 拼接加密前字符串
    md5Origin += json.encode(data);
    if (queryParameters.isNotEmpty) {
      var sortParams = SplayTreeMap<String, dynamic>.from(
          queryParameters); // 对queryParameters排序
      sortParams.forEach((key, value) {
        md5Origin += '$key$value';
      });
    }
    md5Origin += reqId;

    headers['sign'] = md5.convert(utf8.encode(md5Origin));
    headers['random'] = reqId;
    // sign签名 end

    var res = await MeiJuApi()._dio.request(
          dotenv.get('IOT_URL') + path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

    if (res.statusCode != 200) {
      throw DioError(requestOptions: res.requestOptions, response: res);
    }

    return MeiJuResponseEntity<T>.fromJson(res.data);
  }

  /// 美智光电IOT中台接口发起公共接口
  static Future<MeiJuResponseEntity<T>> requestMzIot<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress
  }) async {
    options ??= Options();
    options.headers ??= {};
    data ??= {}; // data默认值
    queryParameters ??= {};
    options.extra = options.extra ?? {};

    var reqId = uuid.v4();
    var params =
        options.method == 'GET' ? queryParameters : data; // get\post参数统一处理

    var headers = options.headers as LinkedHashMap<String, dynamic>;

    // 增加美智云中台的公共参数
    var timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    params.addAll({
      'reqId': reqId,
      'timestamp': timestamp,
      'systemSource': 'SMART_SCREEN',
      'frontendType': 'ANDROID',
    });

    if (MeiJuGlobal.isLogin) {
      headers.addAll({
        'deviceId': Global.user?.deviceId,
      });

      params['userId'] = MeiJuGlobal.token?.uid;
    }

    if (StrUtils.isNotNullAndEmpty(MeiJuGlobal.token?.mzAccessToken)) {
      headers.addAll({
        'Authorization': 'Bearer ${MeiJuGlobal.token?.mzAccessToken}',
      });
    }

    // sign签名 start
    if (options.extra!['isSign'] == true) {
      var md5Origin = dotenv.get('APP_SECRET'); // 拼接加密前字符串
      md5Origin += json.encode(data);
      md5Origin += reqId;

      headers['sign'] = md5.convert(utf8.encode(md5Origin));
      headers['random'] = reqId;
    }
    // sign签名 end

    var res = await MeiJuApi()._dio.request(
          dotenv.get('MZ_URL') + path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

    if (res.statusCode != 200) {
      throw DioError(requestOptions: res.requestOptions, response: res);
    }

    return MeiJuResponseEntity<T>.fromJson(res.data);
  }
}
