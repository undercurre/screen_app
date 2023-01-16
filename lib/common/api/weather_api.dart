import 'package:dio/dio.dart';

import '../../models/index.dart';
import '../index.dart';

class WeatherApi {
  /// 获取天气
  static Future<MideaResponseEntity<WeatherOfCityEntity>> getWeather(
      {String? cityId = '101280801'}) async {
    var res = await Api.requestMideaIot<WeatherOfCityEntity>(
        "/mas/v5/app/proxy?alias=/v1/weather/observe/byCityId",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        isShowLoading: false,
        options: Options(method: 'POST'));

    return res;
  }

  /// 获取7天天气
  static Future<MideaResponseEntity<List<Weather7dEntity>>> getWeather7d(
      {String? cityId = '101280801'}) async {
    var res = await Api.requestMideaIot<List<Weather7dEntity>>(
        "/mas/v5/app/proxy?alias=/v1/weather/forecast7d",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        isShowLoading: false,
        options: Options(
            method: 'POST',
            headers: {'accessToken': Global.user?.accessToken}));

    return res;
  }
}
