import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:screen_app/common/utils.dart';
import 'package:screen_app/models/index.dart';
import 'package:uuid/uuid.dart';
import '../global.dart';

const uuid = Uuid();

class Api {
  /// 密钥
  static var secret = dotenv.get('SECRET');

  //签名密钥
  static var httpSignSecret = dotenv.get('HTTP_SIGN_SECRET');

  static final Api _instance = Api._internal();

  static Dio dio = Dio(BaseOptions(
    headers: {},
    method: 'POST',
    connectTimeout: 5000,
    receiveTimeout: 10000,
  ));

  /// 私有的命名构造函数
  Api._internal();

  /// 单例模式
  factory Api() {
    return _instance;
  }

  /// Api类初始化配置
  static void init() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.extra['isShowLoading'] == true) {
        TipsUtils.showLoading();
      }

      if (options.extra['isLog'] != false) {
        logger.i('【onRequest】: ${options.path} \n '
            'method: ${options.method} \n'
            'headers: ${options.headers} \n '
            'data: ${options.data} \n '
            'queryParameters: ${options.queryParameters}  \n');
      }

      // Do something before request is sent
      return handler.next(options); //continue
      // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
      //
      // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    }, onResponse: (response, handler) {
      if (response.requestOptions.extra['isShowLoading'] == true) {
        TipsUtils.hideLoading();
      }

      if (response.requestOptions.extra['isLog'] != false) {
        logger.i('${response.requestOptions.path} \n '
            'onResponse: $response.');
      }

      // Do something with response data
      return handler.next(response); // continue
      // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    }, onError: (DioError e, handler) {
      // Do something with response error
      logger.e('onError:\n'
          '${e.toString()} \n '
          '${e.requestOptions.path} \n'
          '${e.response}');

      return handler.next(e); //continue
      // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
    }));
    // 设置用户token（可能为null，代表未登录）
    // dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
  }

  /// IOT接口发起公共接口
  static Future<MideaResponseEntity<T>> requestMideaIot<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isShowLoading = true,
    bool isLog = true,
  }) async {
    options ??= Options();
    options.headers ??= {};
    data ??= {};
    queryParameters ??= {};
    options.extra ??= {};

    // 是否显示loading标识
    options.extra!['isShowLoading'] = isShowLoading;
    // 是否打印日志标识
    options.extra!['isLog'] = isLog;

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

    if (Global.isLogin) {
      params['uid'] = Global.user?.uid;
      headers['accessToken'] = Global.user?.accessToken;
    }

    // 公共header参数
    // 云端接口出错时，返回调试信息
    if (!Global.isRelease) {
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

    var res = await dio.request(
      dotenv.get('IOT_URL') + path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return MideaResponseEntity<T>.fromJson(res.data);
  }

  /// 美智光电IOT中台接口发起公共接口
  static Future<MzResponseEntity<T>> requestMzIot<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isShowLoading = true,
    bool isLog = true,
  }) async {
    options ??= Options();
    options.headers ??= {};
    data ??= {}; // data默认值
    queryParameters ??= {};
    var extra = options.extra ?? {};

    // 是否显示loading标识
    // options.extra!['isShowLoading'] = isShowLoading;
    // 是否打印日志标识
    // options.extra!['isLog'] = isLog;

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

    if (Global.isLogin) {
      headers.addAll({
        'deviceId': Global.user?.deviceId,
      });

      params['userId'] = Global.user?.uid;
    }

    if (StrUtils.isNotNullAndEmpty(Global.user?.mzAccessToken)) {
      headers.addAll({
        'Authorization': 'Bearer ${Global.user?.mzAccessToken}',
      });
    }

    // sign签名 start
    if (extra['isSign'] == true) {
      var md5Origin = dotenv.get('APP_SECRET'); // 拼接加密前字符串
      md5Origin += json.encode(data);
      md5Origin += reqId;

      headers['sign'] = md5.convert(utf8.encode(md5Origin));
      headers['random'] = reqId;
    }
    // sign签名 end

    var res = await dio.request(
      dotenv.get('MZ_URL') + path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return MzResponseEntity<T>.fromJson(res.data);
  }
}
