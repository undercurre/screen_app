import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:uuid/uuid.dart';

import '../../../widgets/event_bus.dart';
import '../../logcat_helper.dart';
import '../../system.dart';
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

  static bool isIOTLogoutCode(int code) {
    return code == 1003 || code == 1004 || code == 40002 || code == 65012 || code == 65013;
  }

  static bool isMZLogoutCode(int code) {
    return code == 9998 || code == 9984 || code == 9993;
  }

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
      Log.file('【onRequest】: ${options.path} \n '
          'method: ${options.method} \n'
          'headers: ${options.headers} \n '
          'data: ${options.data} \n '
          'queryParameters: ${options.queryParameters}  \n');
      return handler.next(options);
    }, onResponse: (response, handler) {
      Log.file('${response.requestOptions.path} \n '
          'onResponse: $response.');
      return handler.next(response);
    }, onError: (e, handler) {
      Log.file('onError:\n'
          '${e.toString()} \n '
          '${e.requestOptions.path} \n'
          '${e.response}');

      return handler.next(e);
    }));
  }

  static Future<bool> mzAutoLogin() async {
    var options = Options();
    options.extra ??= {};
    options.headers ??= {};
    var data = {
      'userId': MeiJuGlobal.token?.uid,
      'deviceId': MeiJuGlobal.token?.deviceId,
      'appId': dotenv.get('APP_ID'),
      'appSecret': dotenv.get('APP_SECRET'),
      'itAccessToken': MeiJuGlobal.token?.accessToken,
      'tokenExpires': (24 * 60 * 60).toString(),
    };
    Map<String, dynamic>? queryParameters = {};

    var reqId = uuid.v4();
    var params = data;

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
        'deviceId': MeiJuGlobal.token?.deviceId,
      });

      params['userId'] = MeiJuGlobal.token?.uid;
    }

    if (StrUtils.isNotNullAndEmpty(MeiJuGlobal.token?.mzAccessToken)) {
      headers.addAll({
        'Authorization': 'Bearer ${MeiJuGlobal.token?.mzAccessToken}',
      });
    }

    var md5Origin = dotenv.get('APP_SECRET'); // 拼接加密前字符串
    md5Origin += json.encode(data);
    md5Origin += reqId;

    headers['sign'] = md5.convert(utf8.encode(md5Origin));
    headers['random'] = reqId;
    // sign签名 end

    var res = await MeiJuApi()._dio.request(
      "${dotenv.get('MZ_URL')}/v1/openApi/auth/midea/token",
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    if(res.statusCode != 200) {
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }

    var entity = MeiJuResponseEntity.fromJson(res.data);

    if (isMZLogoutCode(entity.code)) {
      MeiJuGlobal.setLogout();
      bus.emit('logout');
      Log.file("美智平台刷新Token 失败, 提示要退出登录");
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }


    if (!entity.isSuccess) {
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }

    String? mzToken = entity.data['accessToken'];
    MeiJuGlobal.token?.mzAccessToken = mzToken;
    MeiJuGlobal.token = MeiJuGlobal.token;
    return entity.isSuccess;
  }

  static Future<bool> iotAutoLogin() async {
    Map<String, dynamic>? queryParameters = {};
    Options options = Options();
    options.extra ??= {};
    options.headers ??= {};
    options.extra?['isShowLoading'] = false;
    options.extra?['isLog'] = true;

    Map<String, dynamic> data = {
      'data': {
        'uid': MeiJuGlobal.token?.uid,
        'tokenPwd': MeiJuGlobal.token?.tokenPwd,
        'rule': 1,
        'deviceId': MeiJuGlobal.token?.deviceId,
        'platform': 1,
        'iotAppId':12002,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'reqId': uuid.v4(),
      'openId': 'zhinengjiadian',
      'uid': MeiJuGlobal.token?.uid
    };

    var reqId = uuid.v4();
    var headers = options.headers as LinkedHashMap<String, dynamic>;

    // sign签名 start
    var md5Origin = httpSignSecret; // 拼接加密前字符串
    md5Origin += json.encode(data);
    md5Origin += reqId;

    headers['sign'] = md5.convert(utf8.encode(md5Origin));
    headers['random'] = reqId;

    var res = await MeiJuApi()._dio.request(
      "${dotenv.get('IOT_URL')}/muc/v5/app/mj/user/autoLogin",
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: null,
      onSendProgress: null,
      onReceiveProgress: null,
    );

    if(res.statusCode != 200) {
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }

    MeiJuResponseEntity entity = MeiJuResponseEntity.fromJson(res.data);
    if (isIOTLogoutCode(entity.code)) {
      MeiJuGlobal.setLogout();
      bus.emit('logout');
      Log.file('iot token 失效,即将退出登录 ${entity.toJson()}');
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }

    if (!entity.isSuccess) {
      throw DioError(
          requestOptions: res.requestOptions,
          response: res
      );
    }

    // 刷新Global.user.accessToken
    if(entity.data['accessToken'] != null) {
      MeiJuGlobal.token?.accessToken = entity.data['accessToken'];
    }
    if(entity.data['tokenPwd'] != null) {
      MeiJuGlobal.token?.tokenPwd = entity.data['tokenPwd'];
    }
    if(entity.data['expired'] != null) {
      MeiJuGlobal.token?.expired = entity.data['expired'];
      Log.file("it token 过期时间 ${DateTime.fromMillisecondsSinceEpoch(entity.data['expired'])}");
    }
    if(entity.data['expiredDate'] != null) {
      MeiJuGlobal.token?.pwdExpired = entity.data['expiredDate'];
      Log.file("it refresh_token 过期时间 ${DateTime.fromMillisecondsSinceEpoch(entity.data['expiredDate'])}");
    }

    MeiJuGlobal.token = MeiJuGlobal.token;

    return true;
  }

  static final _lock = Lock();

  static tryToRefreshToken() async {
    try {
      _lock.lock();
      await iotAutoLogin();
      await mzAutoLogin();
    } finally {
      _lock.unlock();
    }
  }

  /// IOT接口发起公共接口
  ///
  static Future<MeiJuResponseEntity<T>> requestMideaIot<T>(String path, {
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

    var entity =  MeiJuResponseEntity<T>.fromJson(res.data);

    if(isIOTLogoutCode(entity.code)) {
      tryToRefreshToken();
    }

    return entity;

  }

  /// 美智光电IOT中台接口发起公共接口
  static Future<MeiJuResponseEntity<T>> requestMzIot<T>(String path, {
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
        'deviceId': System.deviceId,
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

    var entity = MeiJuResponseEntity<T>.fromJson(res.data);
    // 多增加[isIOTLogoutCode] 已防止美智平台接口直接将iot的错误码返回到客户端
    if (isMZLogoutCode(entity.code) || isIOTLogoutCode(entity.code)) {
      tryToRefreshToken();
    }
    return entity;
  }
}
