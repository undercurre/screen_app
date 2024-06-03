import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/weather_change_notifier.dart';
import 'package:screen_app/widgets/util/nameFormatter.dart';
import '../../../common/utils.dart';
import '../../util/net_utils.dart';

class DigitalWeatherWidget extends StatefulWidget {
  final bool disabled;
  final bool discriminative;

  const DigitalWeatherWidget({
    super.key,
    this.disabled = false,
    this.discriminative = false,
  });

  @override
  _DigitalWeatherWidgetState createState() => _DigitalWeatherWidgetState();
}

class _DigitalWeatherWidgetState extends State<DigitalWeatherWidget>
    with WidgetNetState {
  late ValueNotifier<DateTime> _currentTimeNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 72000), (Timer timer) {
      if (_currentTimeNotifier != null && mounted) {
        _currentTimeNotifier.value = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _currentTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherModel = Provider.of<WeatherModel>(context);
    return GestureDetector(
      onTap: () {
        if (!isConnected()) {
          TipsUtils.toast(content: '请连接网络');
          return;
        }
        if (!widget.disabled && !widget.discriminative) {
          Navigator.pushNamed(context, 'SelectAreaPage');
        }
      },
      child: Container(
        width: 210,
        height: 196,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            stops: widget.discriminative ? _getBgStop('default') : _getBgStop(weatherModel.getWeatherType()),
            colors:
              widget.discriminative ? _getBgColor('default') : _getBgColor(weatherModel.getWeatherType())),
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
                            color: const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.79),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 2,
                        child: Text(
                          '℃',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.6),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWeatherName(weatherModel.getWeatherType()),
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.79)),
                      ),
                      Text(
                        weatherModel.getWeatherType() == 'default'
                            ? '——'
                            : NameFormatter.formatName(weatherModel.selectedDistrict.cityName, 5),
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: weatherModel.getWeatherType() == 'default' ? 16 : 13,
                            color: const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.64)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  List<Color> _getBgColor(String key) {
    List<Color> defaultBg = [
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.12)
    ];

    List<Color> sunny = [
      Color(0xFF7A7264), // 原始第一色
      Color(0xFF6F736D), // 新增过渡色
      Color(0xFF64757C), // 原始第二色
      Color(0xFF5F7581), // 新增过渡色
      Color(0xFF4D6B8D), // 原始第三色
      Color(0xFF466D8A), // 新增过渡色
    ];

    List<Color> thumder = [
      Color(0xFF5F5892),  // 原始第一色
      Color(0xFF585E91),  // 新增过渡色
      Color(0xFF536090),  // 原始第二色
      Color(0xFF4E658F),  // 新增过渡色
      Color(0xFF48678E),  // 原始第三色
      Color(0xFF526F87),  // 新增过渡色
      Color(0xFF5C7885),  // 原始第四色
    ];

    List<Color> cloudy = [
      Color(0xFF516375),  // 原始第一色
      Color(0xFF687785),  // 新增过渡色
      Color(0xFF848D9C),  // 原始第二色
      Color(0xFF868F9D),  // 新增过渡色
      Color(0xFF88909F),  // 原始第三色
      Color(0xFF7E8797),  // 新增过渡色
      Color(0xFF727F8F),  // 原始第四色
      Color(0xFF697787),  // 新增过渡色
    ];

    List<Color> rainy = [
      Color(0xFF5C747B),  // 原始第一色
      Color(0xFF596D81),  // 新增过渡色
      Color(0xFF576E87),  // 原始第二色
      Color(0xFF496A83),  // 新增过渡色
      Color(0xFF33617F),  // 原始第三色
      Color(0xFF305D78),  // 新增过渡色
    ];

    final Map<String, List<Color>> codeToColor = {
      'default': defaultBg,
      '00': sunny,
      '01': cloudy,
      '02': cloudy,
      '03': rainy,
      '04': thumder,
      '05': thumder,
      '06': cloudy,
      '07': rainy,
      '08': rainy,
      '09': rainy,
      '10': rainy,
      '11': rainy,
      '12': rainy,
      '13': cloudy,
      '14': cloudy,
      '15': cloudy,
      '16': cloudy,
      '17': cloudy,
      '18': cloudy,
      '19': cloudy,
      '20': cloudy,
      '21': rainy,
      '22': rainy,
      '23': rainy,
      '24': rainy,
      '25': rainy,
      '26': cloudy,
      '27': cloudy,
      '28': cloudy,
      '29': cloudy,
      '30': cloudy,
      '31': cloudy,
      '32': cloudy,
      '49': cloudy,
      '53': cloudy,
      '54': cloudy,
      '55': cloudy,
      '56': cloudy,
      '57': cloudy,
      '58': cloudy,
      '301': rainy,
      '302': cloudy
    };

    return codeToColor[key] ?? defaultBg;
  }

  List<double> _getBgStop(String key) {
    List<double> defaultStop = [0, 0.2, 0.4, 0.6, 0.8, 1.0];
    List<double> sunny = [0.0, 0.25, 0.47, 0.61, 0.8, 1.0];
    List<double> thumder = [0.0, 0.12, 0.25, 0.5, 0.76, 0.88, 1.0];
    List<double> cloudy = [0.0, 0.18, 0.34, 0.51, 0.61, 0.76, 0.88, 1.0];
    List<double> rainy = [0.0, 0.22, 0.44, 0.66, 0.88, 1.0];

    final Map<String, List<double>> codeToStop = {
      'default': defaultStop,
      '00': sunny,
      '01': cloudy,
      '02': cloudy,
      '03': rainy,
      '04': thumder,
      '05': thumder,
      '06': cloudy,
      '07': rainy,
      '08': rainy,
      '09': rainy,
      '10': rainy,
      '11': rainy,
      '12': rainy,
      '13': cloudy,
      '14': cloudy,
      '15': cloudy,
      '16': cloudy,
      '17': cloudy,
      '18': cloudy,
      '19': cloudy,
      '20': cloudy,
      '21': rainy,
      '22': rainy,
      '23': rainy,
      '24': rainy,
      '25': rainy,
      '26': cloudy,
      '27': cloudy,
      '28': cloudy,
      '29': cloudy,
      '30': cloudy,
      '31': cloudy,
      '32': cloudy,
      '49': cloudy,
      '53': cloudy,
      '54': cloudy,
      '55': cloudy,
      '56': cloudy,
      '57': cloudy,
      '58': cloudy,
      '301': rainy,
      '302': cloudy
    };

    return codeToStop[key] ?? defaultStop;
  }

  SizedBox _getWeatherIcon(String weatherCode) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Image(
        image: AssetImage('assets/newUI/weather/${codeToImage[weatherCode]}.png'),
      ),
    );
  }

  String _getWeatherName(String weatherCode) {
    return codeToName[weatherCode] ?? '——';
  }

  @override
  void netChange(MZNetState? state) {
    // TODO: implement netChange
  }
}
