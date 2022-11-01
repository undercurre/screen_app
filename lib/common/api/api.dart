import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import '../../models/accessToken.dart';
import '../global.dart';

class Api {
  String baseUrl = '';

  /// iot中台Url
  static String iotUrl = dotenv.get('IOT_URL');

  /// 密钥
  static var secret = dotenv.get('SECRET');

  static AccessToken tokenInfo = AccessToken.fromJson({
    "accessToken": "",
    "deviceId": "",
    "iotUserId": "",
    "key": "",
    "openId": "",
    "seed": "",
    "sessionId": "",
    "tokenPwd": "",
    "uid": ""
  });

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
      var random = Random().nextInt(100000);
      var params = options.data ?? options.queryParameters;
      var extra = options.extra;
      var headers = options.headers;

      logger.i('【onRequest】: ${options.path} \n '
          'headers: $headers \n '
          'data: ${options.data} \n '
          'queryParameters: ${options.queryParameters} ');
      // 公共header
      headers['random'] = '$random';
      if (options.data != null) {
        var sign = md5
            .convert(utf8.encode('$secret${options.data.toString()}$random'));
        headers['sign'] = sign;
      }

      // 公共参数
      if (params != null) {
        params?['openId'] = 'zhinengjiadian';
        params['iotAppI'] = '12002';
        params['reqId'] = '$random';
        params['stamp'] = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      }

      if (tokenInfo.accessToken.isNotEmpty) {
        params?['uid'] = tokenInfo.uid;
      }

      // isEncrypt用于判断是否需要加密请求，默认是
      if (extra['isEncrypt'] != false) {
        var enCodedJson = utf8.encode(params.toString());
        var gZipJson = GZipEncoder().encode(enCodedJson);
        logger.i('enCodedJson: $enCodedJson');
        logger.i('gZipJson: $gZipJson');
        final key = Key.fromUtf8(secret); //加密key
        final iv = IV.fromLength(16); //偏移量

        //设置cbc模式
        final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

        params = encrypter.encrypt(params.toString(), iv: iv).base64;

        // options.data = params.toString();
      }

      logger.i('【onRequest处理后】: ${options.path} \n '
          'headers: $headers \n '
          'data: ${options.data} \n '
          'queryParameters: ${options.queryParameters} ');
      // Do something before request is sent
      return handler.next(options); //continue
      // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
      //
      // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    }, onResponse: (response, handler) {
      // 统一增加请求是否成功标志
      logger.i('onResponse: $response');
      // Do something with response data
      return handler.next(response); // continue
      // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    }, onError: (DioError e, handler) {
      // Do something with response error
      return handler.next(e); //continue
      // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
    }));
    // 设置用户token（可能为null，代表未登录）
    // dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    // 在调试模式下需要禁用HTTPS证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return null;
      };
    }
  }

  /// IOT接口发起公共接口
  static Future<IotResult> requestIot<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // String? deviceId = await PlatformDeviceId.getDeviceId;

    var res = await dio.request(
      iotUrl + path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return IotResult.fromJson(res.data);
  }
}

class IotResult<T> {
  IotResult();

  IotResult.translate(this.code, this.msg, this.data);

  late int code;
  late String? msg;
  late T data;

  get isSuccess => code == 0;

  factory IotResult.fromJson(Map<String, dynamic> json) => IotResult()
    ..msg = json['msg']
    ..data = json['data']
    ..code = json['code'] as int;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'code': code, 'msg': msg, 'data': data};
}
