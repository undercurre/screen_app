import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/meiju/generated/json/base/meiju_json_convert_content.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:uuid/uuid.dart';

import '../../logcat_helper.dart';
import '../../system.dart';
import '../../utils.dart';
import '../meiju_global.dart';

const uuid = Uuid();

class MeiJuApiHelper {
  static Future<MeiJuResponseEntity<T>> wrap<T>(
      Future<MeiJuResponseEntity<T>> future) async {
    try {
      return await future;
    } catch (e) {
      return MeiJuResponseEntity()
        ..code = -1
        ..msg = '网络错误';
    }
  }
}

//美居&美智Token 联合状态
enum TokenCombineState {
  INVAILD, // Token无效
  ALL_EXPIRED, // 美居&美智过期
  ONLY_MEIZHI_EXPIRED, // 只有美智过期
  NORMAL // 都正常
}

class MeiJuApi {
  // 单例实例
  static final MeiJuApi _instance = MeiJuApi._internal();

  MeiJuApi._internal();

  factory MeiJuApi() {
    return _instance;
  }

  static bool refreshTokenActive = false;

  /// token状态
  static TokenCombineState tokenState = TokenCombineState.INVAILD;

  /// 密钥
  static var secret = dotenv.get('SECRET');

  //签名密钥
  static var httpSignSecret = dotenv.get('HTTP_SIGN_SECRET');

  static bool isIOTLogoutCode(int code) {
    return code == 1003 ||
        code == 1004 ||
        code == 40002 ||
        code == 65012 ||
        code == 65013;
  }

  static bool isMZLogoutCode(int code) {
    return code == 9998 || code == 9984 || code == 9993;
  }

  final Dio _dio = Dio(BaseOptions(
    headers: {},
    method: 'POST',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  static List<RequestInterceptorHandler> requestHandlers = [];

  static void init() {
    // 全局Https、Http请求监听者
    MeiJuApi()
        ._dio
        .interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
          Log.file('【onRequest】: ${options.path} \n'
              '\$method: ${options.method} \n'
              '\$headers: ${options.headers} \n'
              '\$data: ${options.data} \n'
              '\$queryParameters: ${options.queryParameters}  \n');
          final bool isRefreshTokenUrl =
              options.uri.path.endsWith('/v1/openApi/auth/midea/token') ||
                  options.uri.path.endsWith('/muc/v5/app/mj/user/autoLogin');
          if (isRefreshTokenUrl) {
            return handler.next(options);
          }

          if (refreshTokenActive) {
            do {
              await Future.delayed(const Duration(seconds: 3));
              if (refreshTokenActive) {
                Log.develop('[刷新Token] 等待Token刷新结束 ${options.path}');
              }
            } while (refreshTokenActive);
            // 更改请求的Token变量
            options.headers['Authorization'] = 'Bearer ${MeiJuGlobal.token?.mzAccessToken}';
            options.headers['accessToken'] = MeiJuGlobal.token?.accessToken;
          }
          if (tokenState != TokenCombineState.INVAILD && tokenState != TokenCombineState.NORMAL) {
            await syncTryToRefreshToken("检测到本地Token状态异常，准备重新刷新Token状态");
            if(tokenState == TokenCombineState.INVAILD) {
              /// 刷新失败，接口拒绝请求
              return handler.reject(DioException(requestOptions: options));
            } else {
              // 更改请求的Token变量
              options.headers['Authorization'] = 'Bearer ${MeiJuGlobal.token?.mzAccessToken}';
              options.headers['accessToken'] = MeiJuGlobal.token?.accessToken;
            }
          }
          return handler.next(options);
        }, onResponse: (response, handler) {
          Log.file('【onResponse】: ${response.requestOptions.path} \n'
              '\$requestHeaders: ${response.requestOptions.headers} \n'
              '\$requestData: ${response.requestOptions.data} \n'
              '\$onResponse: $response  \n');
          final bool isRefreshTokenUrl = response.requestOptions.path.endsWith('/v1/openApi/auth/midea/token') || response.requestOptions.path.endsWith('/muc/v5/app/mj/user/autoLogin');
          if (isRefreshTokenUrl) {
            return handler.next(response);
          }
          final int? dataCode = meijuJsonConvert.convert<int>(response.data?["code"]);
          if (dataCode == null) {
            return handler.next(response);
          }
          final String url = response.requestOptions.path;
          if (url.startsWith(dotenv.get('IOT_URL'))) {
            if (tokenState != TokenCombineState.INVAILD) {
              if (isIOTLogoutCode(dataCode)) {
                asyncTryToRefreshToken("IOT后台提示Token过期");
              }
            }
          } else if (url.startsWith(dotenv.get('MZ_URL'))) {
            if (tokenState != TokenCombineState.INVAILD) {
              if (isMZLogoutCode(dataCode) || isIOTLogoutCode(dataCode)) {
                asyncTryToRefreshToken("美智后台提示Token失效");
              } else if (response.data['result'] != null &&
                  response.data['result'] is String &&
                  response.data['result']
                      .toString()
                      .contains('invalid_token')) {
                // 特殊处理 美智中台接口会返回下面报错数据
                // {"result":"{\"error_description\":\"The access token is invalid or has expired\",\"error\":\"invalid_token\"}\n",
                // "code":0,"msg":"成功!","success":true,"timestamp":1697439277668}
                asyncTryToRefreshToken("美智后台提示Token失效");
              }
            }
          }
          return handler.next(response);
        }, onError: (e, handler) {
          Log.file('【onResponse】: onError:\n'
              '${e.toString()} \n '
              '${e.requestOptions.path} \n'
              '${e.response}');

          return handler.next(e);
        }));
  }

  static Future<String?> mzAutoLogin() async {
    var options = Options();
    options.extra ??= {};
    options.headers ??= {};
    var data = {
      'userId': MeiJuGlobal.token?.uid,
      'deviceId': System.deviceId,
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
        'deviceId': System.deviceId,
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

    if (res.statusCode != 200) {
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    var entity = MeiJuResponseEntity.fromJson(res.data);

    if (isMZLogoutCode(entity.code)) {
      System.logout("美智平台刷新Token 失败, 提示要退出登录");
      Log.file("美智平台刷新Token 失败, 提示要退出登录");
      tokenState = TokenCombineState.INVAILD;
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    String? mzToken = entity.data?['accessToken'];
    if (entity.isSuccess && mzToken != null) {
      MeiJuGlobal.token?.mzAccessToken = mzToken;
      MeiJuGlobal.token = MeiJuGlobal.token;
    }

    return mzToken;
  }

  static Future<String?> iotAutoLogin() async {
    Map<String, dynamic>? queryParameters = {};
    Options options = Options();
    options.extra ??= {};
    options.headers ??= {};
    options.extra?['isShowLoading'] = false;
    options.extra?['isLog'] = true;

    var reqId = uuid.v4();
    Map<String, dynamic> data = {
      'data': {
        'uid': MeiJuGlobal.token?.uid,
        'tokenPwd': MeiJuGlobal.token?.tokenPwd,
        'rule': 1,
        'deviceId': MeiJuGlobal.token?.deviceId,
        'platform': 1,
        'iotAppId': 12002,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

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

    if (res.statusCode != 200) {
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    MeiJuResponseEntity entity = MeiJuResponseEntity.fromJson(res.data);
    if (isIOTLogoutCode(entity.code)) {
      System.logout("IOT Token 刷新失败，即将退出登录");
      Log.file('iot token 失效,即将退出登录 ${entity.toJson()}');
      tokenState = TokenCombineState.INVAILD;
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    if (entity.isSuccess) {
      // 刷新Global.user.accessToken
      String? accessToken = entity.data?['accessToken'];
      if (accessToken != null) {
        MeiJuGlobal.token?.accessToken = accessToken;
      }
      String? tokenPwd = entity.data?['tokenPwd'];
      if (tokenPwd != null) {
        MeiJuGlobal.token?.tokenPwd = tokenPwd;
      }
      int? expired = entity.data?['expired'];
      if (expired != null) {
        MeiJuGlobal.token?.expired = expired;
        Log.file("it token 过期时间 ${DateTime.fromMillisecondsSinceEpoch(expired)}");
      }
      int? expiredDate = entity.data?['expiredDate'];
      if (expiredDate != null) {
        MeiJuGlobal.token?.pwdExpired = expiredDate;
        Log.file("it refresh_token 过期时间 ${DateTime.fromMillisecondsSinceEpoch(expiredDate)}");
      }
      MeiJuGlobal.token = MeiJuGlobal.token;
    }

    return entity.data?['accessToken'];
  }

  static syncTryToRefreshToken(String msg) async {
    await asyncTryToRefreshToken(msg);
    if (refreshTokenActive) {
      /// 设置三十秒的超时等待时间
      int count = 10;
      do {
        await Future.delayed(const Duration(seconds: 3));
        if(count-- <= 0) {
          Log.develop("[刷新Token] 注意！！！ 超时刷新Token");
          refreshTokenActive = false;
        }
      } while (refreshTokenActive);
    }
  }

  static asyncTryToRefreshToken(String msg) async {
    if (!refreshTokenActive) {
      Log.develop("[刷新Token] 原因：$msg");
      try {
        refreshTokenActive = true;
        tokenState = TokenCombineState.ALL_EXPIRED;
        String? iotToken = await iotAutoLogin();
        Log.develop('[刷新Token] iot-token $iotToken');
        if (iotToken != null) {
          tokenState = TokenCombineState.ONLY_MEIZHI_EXPIRED;
        }
        String? mzToken = await mzAutoLogin();
        Log.develop('[刷新Token] mz-token $mzToken');
        if (iotToken != null && mzToken != null) {
          tokenState = TokenCombineState.NORMAL;
        }
      } on Exception catch (e, stackTrace) {
        Log.develop('[刷新Token] 异常', e, stackTrace);
      } finally {
        Log.develop("[刷新Token] 结束 : $tokenState");
        refreshTokenActive = false;
      }
    }
  }

  static Future<MeiJuResponseEntity<T>> requestMideaIotSafety<T>(String path,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) {
    return MeiJuApiHelper.wrap(requestMideaIot(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onSendProgress));
  }

  static Future<MeiJuResponseEntity<T>> requestMzIotSafety<T>(String path,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) {
    return MeiJuApiHelper.wrap(requestMzIot(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onSendProgress));
  }

  /// IOT接口发起公共接口
  ///
  static Future<MeiJuResponseEntity<T>> requestMideaIot<T>(String path,
      {Map<String, dynamic>? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
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
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    return MeiJuResponseEntity<T>.fromJson(res.data);
  }

  /// 美智光电IOT中台接口发起公共接口
  static Future<MeiJuResponseEntity<T>> requestMzIot<T>(String path,
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
      throw DioException(requestOptions: res.requestOptions, response: res);
    }

    return MeiJuResponseEntity<T>.fromJson(res.data);
  }
}
