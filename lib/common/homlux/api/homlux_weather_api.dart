

import 'package:dio/dio.dart';
import 'package:screen_app/common/homlux/models/homlux_weather_entity.dart';

import '../models/homlux_response_entity.dart';
import 'homlux_api.dart';

class HomluxWeatherApi {

  /// 查询天气
  Future<HomluxResponseEntity<HomluxWeatherEntity>> queryWeather(
      String name, String latitude,
      String longitude, {CancelToken? cancelToken}) {
    return HomluxApi.request('/v1/thirdparty/moji/weather/queryMojiWeatherConditionInfo',
      data: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      },
      options: Options(method: 'POST'),
      cancelToken: cancelToken
    );
  }


}