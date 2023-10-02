import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/homlux/api/homlux_weather_api.dart';
import 'package:screen_app/common/homlux/models/homlux_weather_entity.dart';
import 'package:screen_app/common/meiju/models/meiju_weather_entity.dart';
import 'package:screen_app/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/gateway_platform.dart';
import '../common/homlux/models/homlux_response_entity.dart';
import '../common/logcat_helper.dart';
import '../common/meiju/api/meiju_weather_api.dart';
import '../common/meiju/models/meiju_response_entity.dart';
import '../common/models/city.dart';
import '../common/models/district.dart';
import '../common/models/province.dart';

class WeatherModel extends ChangeNotifier {

  // 定义一个定时器
  Timer _weatherTimer = Timer(const Duration(hours: 4), () { });

  // 两种数据载体
  MeiJuWeather curWeatherInMeiJu = MeiJuWeather(); // 根据实际需要提供默认值
  HomluxWeatherEntity curWeatherInHomlux = HomluxWeatherEntity(); // 根据实际需要提供默认值

  // 定义一个方法来启动定时器
  void startWeatherTimer() {
    _fetchWeatherData();
    // 每隔一定时间执行一次请求天气数据的操作
    const Duration interval = Duration(hours: 4); // 4小时更新一次

    // 如果已存在定时器，先取消之前的定时器，避免重复执行
    if (_weatherTimer != null) {
      _weatherTimer.cancel();
    }

    // 创建新的定时器并执行请求天气数据的操作
    _weatherTimer = Timer.periodic(interval, (Timer timer) {
      _fetchWeatherData(); // 请求天气数据的方法
    });
  }

  // 请求天气数据的方法
  Future<void> _fetchWeatherData() async {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      if (selectedDistrict != null) {
        MeiJuResponseEntity<MeiJuWeatherEntity> res = await MeiJuWeatherApi.getWeather(cityId: selectedDistrict.areaid);
        curWeatherInMeiJu = res.data?.weather ?? MeiJuWeather();
      }
    } else {
      if (selectedDistrict != null) {
        HomluxResponseEntity<HomluxWeatherEntity> res = await HomluxWeatherApi.queryWeather(selectedDistrict.cityName, selectedDistrict.latitude, selectedDistrict.longitude);
        curWeatherInHomlux = res.data ?? HomluxWeatherEntity(condition: "晴天");
      }
    }
    notifyListeners();
  }
  
  // 在构造函数中启动定时器
  WeatherModel() {
    loadSelectedDistrict();
  }

  Future<void> loadSelectedDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    final provinceJson = await prefs.getString('selectedProvince');
    final cityJson = await prefs.getString('selectedCity');
    final districtJson = await prefs.getString('selectedDistrict');
    if (districtJson != null && provinceJson != null && cityJson != null) {
      selectedDistrict = District.fromJson(jsonDecode(districtJson));
      selectedCity = City.fromJson(jsonDecode(cityJson));
      selectedProvince = Province.fromJson(jsonDecode(provinceJson));
    }
    notifyListeners();
    startWeatherTimer();
  }

  Province selectedProvince = Province(province: '广东', cityList: []);
  City selectedCity = City(
    areaid: '101280800',
    cityName: '佛山市',
    longitude: '113.12851219549718',
    latitude: '23.02775875078891',
    adCode: '440600',
    areaList: [],
  );
  District selectedDistrict = District(
    areaid: '101280801',
    cityName: '顺德区',
    longitude: '113.30045343954433',
    latitude: '22.81045342679539',
    adCode: '440606',
  );

  Future<void> updateSelectedProvince(Province province) async {
    selectedProvince = province;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedProvince', jsonEncode(province.toJson()));
    notifyListeners();
  }

  Future<void> updateSelectedCity(City city) async {
    selectedCity = city;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedCity', jsonEncode(city.toJson()));
    notifyListeners();
  }

  Future<void> updateSelectedDistrict(District district) async {
    selectedDistrict = district;
    _fetchWeatherData();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDistrict', jsonEncode(district.toJson()));
    notifyListeners();
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedProvince');
    await prefs.remove('selectedCity');
    await prefs.remove('selectedDistrict');
    selectedProvince = Province(province: '广东', cityList: []);
    selectedCity = City(
      areaid: '101280800',
      cityName: '佛山市',
      longitude: '113.12851219549718',
      latitude: '23.02775875078891',
      adCode: '440600',
      areaList: [],
    );
    selectedDistrict = District(
      areaid: '101280801',
      cityName: '顺德区',
      longitude: '113.30045343954433',
      latitude: '22.81045342679539',
      adCode: '440606',
    );
  }

  static Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedProvince');
    await prefs.remove('selectedCity');
    await prefs.remove('selectedDistrict');
  }

  String getWeatherType() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return curWeatherInMeiJu.weatherCode ?? 'default';
    } else {
      if (curWeatherInHomlux.condition == null) return '02';
      if (curWeatherInHomlux.condition!.contains('雨')) {
        return '03';
      } else if (curWeatherInHomlux.condition!.contains('雪')) {
        return '13';
      } else if (curWeatherInHomlux.condition!.contains('云')) {
        return '02';
      } else if (curWeatherInHomlux.condition!.contains('雾')) {
        return '18';
      } else if (curWeatherInHomlux.condition!.contains('阴')) {
        return '01';
      } else if (curWeatherInHomlux.condition!.contains('晴')) {
        return '00';
      } else if (curWeatherInHomlux.condition!.contains('风')) {
        return '20';
      } else if (curWeatherInHomlux.condition!.contains('雷')) {
        return '04';
      } else {
        return 'default';
      }
    }
  }

  String getTemperature() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.MEIJU) {
      return curWeatherInMeiJu.grade ?? '—';
    } else {
      return curWeatherInHomlux.temperature ?? '—';
    }
  }
}
