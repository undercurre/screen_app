

import 'package:dio/dio.dart';
import 'package:screen_app/common/meiju/models/meiju_response_entity.dart';
import 'package:screen_app/common/meiju/models/meiju_weather_entity.dart';

import '../../../models/weather7d_entity.dart';
import 'meiju_api.dart';

class MeiJuWeatherApi {

  /// 获取天气
  static Future<MeiJuResponseEntity<MeiJuWeatherEntity>> getWeather(
      {String? cityId = '101280801'}) async {
    var res = await MeiJuApi.requestMideaIot<MeiJuWeatherEntity>(
        "/mas/v5/app/proxy?alias=/v1/weather/observe/byCityId",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        options: Options(method: 'POST'));
    return res;
  }

  /// 获取7天天气
  static Future<MeiJuResponseEntity<List<Weather7dEntity>>> getWeather7d(
      {String? cityId = '101280801'}) async {
    var res = await MeiJuApi.requestMideaIot<List<Weather7dEntity>>(
        "/mas/v5/app/proxy?alias=/v1/weather/forecast7d",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        options: Options(method: 'POST'));
    return res;
  }


}