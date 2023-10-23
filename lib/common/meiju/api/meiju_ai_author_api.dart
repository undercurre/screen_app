import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';

import '../../../channel/index.dart';
import '../meiju_global.dart';
import 'meiju_api.dart';

class MeiJuAiAuthorApi {

  static var aiUpdateTokenUrl = "${dotenv.get('NOTICE_AI_CLOUD_HOST')}/v1/user/token/meiju";

  /// ai语音授权
  static Future<MeiJuResponseEntity<String>> AiAuthor(
      {String? deviceId}) async {
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/mj/user/auth/device",
        data: {
          'data': {
            "deviceId":deviceId,
            "aiUpdateTokenUrl":aiUpdateTokenUrl
          },
        },
      options: Options(method: 'POST')
    );

    return res;
  }


  /// ai自定义设备名
  static Future<MeiJuResponseEntity<String>> aiCustomDeviceName(bool? isEnable) async {
    Map<String, dynamic>? request;
    request={
      "mid":uuid.v4(),
      "params":{
        "enable":isEnable
      },
      "user":{
        "homeId":MeiJuGlobal.homeInfo!.homegroupId,
        "uid":MeiJuGlobal.token?.iotUserId
      }
    };
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/v1/app2base/data/transmit",
        data: {
          "data": await aiMethodChannel.aes128Encode(json.encode(request),MeiJuGlobal.token!.seed),
          "param":{
            "serviceUrl":"/v1/deviceName/user/enableCustom"
          },
          "proType":"0xAI",
          "reqId":uuid.v4(),
          "stamp":DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          "uid":MeiJuGlobal.token?.iotUserId
        },
        options: Options(
          method: 'POST'
        ));

    return res;
  }

  /// ai自定义设备名是否开启
  static Future<MeiJuResponseEntity> isAiCustomDeviceName() async {
    Map<String, dynamic>? request;
    request={
      "mid":uuid.v4(),
      "user":{
        "homeId":MeiJuGlobal.homeInfo!.homegroupId,
        "uid":MeiJuGlobal.token?.iotUserId
      }
    };
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/v1/app2base/data/transmit",
        data: {
          "data": await aiMethodChannel.aes128Encode(json.encode(request),MeiJuGlobal.token!.seed),
          "param":{
            "serviceUrl":"/v1/deviceName/user/isEnableCustom"
          },
          "proType":"0xAI",
          "reqId":uuid.v4(),
          "stamp":DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          "uid":MeiJuGlobal.token?.iotUserId
        },
        options: Options(
            method: 'POST'
        ));

    return res;
  }

  /// ai唯一唤醒
  static Future<MeiJuResponseEntity<String>> aiOnlyOneWakeup(int? isEnable) async {
    Map<String, dynamic>? request;
    request={
      "mid":uuid.v4(),
      "deviceId":MeiJuGlobal.gatewayApplianceCode,
      "multiWakeup":isEnable
    };
    logger.i("加密前数据:${json.encode(request)}");
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/v1/app2base/data/transmit",
        data: {
          "data": await aiMethodChannel.aes128Encode(json.encode(request),MeiJuGlobal.token!.seed),
          "param":{
            "serviceUrl":"/v1/device/multiWakeup/set"
          },
          "proType":"0xAI",
          "reqId":uuid.v4(),
          "stamp":DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          "uid":MeiJuGlobal.token?.iotUserId
        },
        options: Options(
            method: 'POST'
        ));

    return res;
  }

  /// ai唯一唤醒是否开启
  static Future<MeiJuResponseEntity> isAiOnlyOneWakeup() async {
    Map<String, dynamic>? request;
    request={
      "mid":uuid.v4(),
      "deviceId":MeiJuGlobal.gatewayApplianceCode,
    };
    var res = await MeiJuApi.requestMideaIot<String>(
        "/mas/v5/app/proxy?alias=/v1/app2base/data/transmit",
        data: {
          "data": await aiMethodChannel.aes128Encode(json.encode(request),MeiJuGlobal.token!.seed),
          "param":{
            "serviceUrl":"/v1/device/multiWakeup/get"
          },
          "proType":"0xAI",
          "reqId":uuid.v4(),
          "stamp":DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
          "uid":MeiJuGlobal.token?.iotUserId
        },
        options: Options(
            method: 'POST'
        ));

    return res;
  }

}
