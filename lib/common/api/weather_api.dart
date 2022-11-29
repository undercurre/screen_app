import 'package:dio/dio.dart';

import '../index.dart';
import '../../models/index.dart';

class WeatherApi {
  /// 获取天气
  static Future<MideaIotResult<WeatherOfCity>> getWeather(
      {String? cityId = '101280801'}) async {
    var res = await Api.requestMideaIot(
        "/mas/v5/app/proxy?alias=/v1/weather/observe/byCityId",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        options: Options(method: 'POST'));

    return MideaIotResult<WeatherOfCity>.translate(
        res.code, '', WeatherOfCity.fromJson(res.data));
  }

  /// 获取7天天气
  static Future<MideaIotResult<List<Weather7d>>> getWeather7d(
      {String? cityId = '101280801'}) async {
    var res = await Api.requestMideaIot<List<Weather7d>>(
        "/mas/v5/app/proxy?alias=/v1/weather/forecast7d",
        data: {
          "appId": "APP",
          'cityId': cityId,
        },
        options: Options(
          method: 'POST',
          headers: {'accessToken': Global.user?.accessToken},
        ));

    // return res.data;

    return MideaIotResult<List<Weather7d>>.translate(res.code, '',
        res.data.map<Weather7d>((value) => Weather7d.fromJson(value)).toList());
  }
}
