import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/weather_change_notifier.dart';

import '../../../common/logcat_helper.dart';
import '../../../common/models/district.dart';

class DigitalWeatherWidget extends StatefulWidget {
  final bool disabled;
  final bool discriminative;

  DigitalWeatherWidget({
    this.disabled = false,
    this.discriminative = false,
  });

  @override
  _DigitalWeatherWidgetState createState() => _DigitalWeatherWidgetState();
}

class _DigitalWeatherWidgetState extends State<DigitalWeatherWidget> {
  late ValueNotifier<DateTime> _currentTimeNotifier;

  @override
  void initState() {
    super.initState();
    _currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
    Timer.periodic(const Duration(seconds: 72000), (Timer timer) {
      if (_currentTimeNotifier != null && mounted) {
        _currentTimeNotifier.value = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _currentTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherModel = Provider.of<WeatherModel>(context);
    return Container(
      width: 210,
      height: 196,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33616A76),
            widget.discriminative ? Colors.white.withOpacity(0.12) : const Color(0x33434852),
          ],
          stops: const [0.06, 1.0],
          transform: const GradientRotation(213 * (3.1415926 / 360.0)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(child: _getWeatherIcon(weatherModel.getWeatherType())),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '${weatherModel.getTemperature()}',
                        style: TextStyle(
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          fontSize: 48,
                          color: const Color.fromRGBO(255, 255, 255, 1)
                              .withOpacity(0.79),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: Text(
                        '°',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: const Color.fromRGBO(255, 255, 255, 1)
                              .withOpacity(0.79),
                        ),
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (!widget.disabled && !widget.discriminative) {
                      Navigator.pushNamed(context, 'SelectAreaPage');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWeatherName(weatherModel.getWeatherType()),
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color.fromRGBO(255, 255, 255, 1)
                                .withOpacity(0.79)),
                      ),
                      Text(
                        weatherModel.selectedDistrict.cityName,
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: const Color.fromRGBO(255, 255, 255, 1)
                                .withOpacity(0.64)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 天气编码转换为天气图片的名称
  final Map<String, String> codeToImage = {
    'default': 'overcast',
    '00': 'sunny',
    '01': 'cloudy',
    '02': 'overcast',
    '03': 'rainy',
    '04': 'thunderstorm',
    '05': 'thunderstorm',
    '06': 'snowy',
    '07': 'rainy',
    '08': 'rainy',
    '09': 'rainy',
    '10': 'rainy',
    '11': 'rainy',
    '12': 'rainy',
    '13': 'snowy',
    '14': 'snowy',
    '15': 'snowy',
    '16': 'snowy',
    '17': 'snowy',
    '18': 'smog',
    '19': 'snowy',
    '20': 'storm',
    '21': 'rainy',
    '22': 'rainy',
    '23': 'rainy',
    '24': 'rainy',
    '25': 'rainy',
    '26': 'snowy',
    '27': 'snowy',
    '28': 'snowy',
    '29': 'storm',
    '30': 'storm',
    '31': 'storm',
    '32': 'smog',
    '49': 'smog',
    '53': 'smog',
    '54': 'smog',
    '55': 'smog',
    '56': 'smog',
    '57': 'smog',
    '58': 'smog',
    '301': 'rainy',
    '302': 'snowy'
  };

  // 天气编码转换为天气的名称
  final Map<String, String> codeToName = {
    'default': "——",
    '00': '晴天',
    '01': '阴天',
    '02': '多云',
    '03': '大雨',
    '04': '雷阵雨',
    '05': '雷阵雨',
    '06': '雨雪',
    '07': '大雨',
    '08': '大雨',
    '09': '大雨',
    '10': '大雨',
    '11': '大雨',
    '12': '大雨',
    '13': '下雪',
    '14': '下雪',
    '15': '下雪',
    '16': '下雪',
    '17': '下雪',
    '18': '雾霾',
    '19': '下雪',
    '20': '暴风',
    '21': '大雨',
    '22': '大雨',
    '23': '大雨',
    '24': '大雨',
    '25': '大雨',
    '26': '下雪',
    '27': '下雪',
    '28': '下雪',
    '29': '暴风',
    '30': '暴风',
    '31': '暴风',
    '32': '雾霾',
    '49': '雾霾',
    '53': '雾霾',
    '54': '雾霾',
    '55': '雾霾',
    '56': '雾霾',
    '57': '雾霾',
    '58': '雾霾',
    '301': '大雨',
    '302': '下雪'
  };

  SizedBox _getWeatherIcon(String weatherCode) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Image(
        image:
            AssetImage('assets/newUI/weather/${codeToImage[weatherCode]}.png'),
      ),
    );
  }

  String _getWeatherName(String weatherCode) {
    return codeToName[weatherCode] ?? '——';
  }
}
