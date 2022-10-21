import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:archive/archive.dart';
import '../global.dart';
import 'dart:developer';
import 'dart:math';

class Api {
  String baseUrl = '';
  static String iotUrl = Global.isRelease
      ? 'https://mp-prod.smartmidea.net'
      : 'https://mp-sit.smartmidea.net';

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
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          var random = Random();
          var data = options.data;
          var extra = options.extra;

          logger.i('onRequest: ${options.path}');
          // 公共header
          options.headers['random'] = '${random.nextInt(10000)}';
          options.headers['sign'] = '${random.nextInt(10000)}';

          // 公共data
          data['openId'] = 'zhinengjiadian';
          data['iotAppI'] = '12002';
          data['reqId'] = '${random.nextInt(10000)}';

          // isEncrypt用于判断是否需要加密请求，默认是
          if (extra['isEncrypt'] != false ) {
            logger.i('data: ${data.toString()}');
            var enCodedJson = utf8.encode(data.toString());
            var gZipJson = GZipEncoder().encode(enCodedJson);
            logger.i('enCodedJson: ${enCodedJson}');
            logger.i('gZipJson: ${gZipJson}');
            final key = Key.fromUtf8('Q06HU5bm4owAeDcH');//加密key
            final iv = IV.fromLength(16);//偏移量


            //设置cbc模式
            final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

            options.data = encrypter.encrypt(data.toString(), iv: iv).base64;
          }

          // Do something before request is sent
          return handler.next(options); //continue
          // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
          // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
          //
          // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
          // 这样请求将被中止并触发异常，上层catchError会被调用。
        },
        onResponse:(response,handler) {
          // 统一增加请求是否成功标志
          logger.i('onResponse: $response');
          // Do something with response data
          return handler.next(response); // continue
          // 如果你想终止请求并触发一个错误,你可以 reject 一个`DioError`对象,如`handler.reject(error)`，
          // 这样请求将被中止并触发异常，上层catchError会被调用。
        },
        onError: (DioError e, handler) {
          // Do something with response error
          return  handler.next(e);//continue
          // 如果你想完成请求并返回一些自定义数据，可以resolve 一个`Response`,如`handler.resolve(response)`。
          // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
        }
    ));
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

  // 测试环境：
// 服务器地址【mp-sit.smartmidea.net:7501】
// 加密与解密方式：对称算法AES  密钥【Q06HU5bm4owAeDcH】 iv【0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0】
// 正式环境：
// 服务器地址【mline.smartmidea.ne:7501】
// 加密与解密方式：对称算法AES  密钥【Q06HU5bm4owAeDcH】 iv【0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0】
  /// IOT接口发起公共接口
  static Future<IotResult> requestIot<T>(
    String path, {
    T? data,
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

class IotResult {
  IotResult();

  late int code;
  late String msg;
  late dynamic data;

  get isSuccess => code == 0;

  factory IotResult.fromJson(Map<String,dynamic> json) => IotResult()
    ..msg = json['msg'] as String
    ..data = json['data'] as dynamic
  ..code = json['code'] as int;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'msg': msg,
    'data': data
  };
}