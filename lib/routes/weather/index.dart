import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/main.dart';
import 'package:screen_app/states/index.dart';
import '../../states/weather_change_notifier.dart';
import '../../widgets/util/nameFormatter.dart';
import '../setting/screen_saver/screen_saver_help.dart';
import 'code_to_image.dart';
import 'show_datetime.dart';

// 页面定义
class WeatherPageState extends State<WeatherPage>
    with AiWakeUPScreenSaverState {
  String temperature = '--';
  String weatherString = '--';
  String weatherBg = '';
  String weatherIcon = '';
  int lastUpdateWeatherTime = 0; // 最后刷新天气的时间

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.exit();
  }

  String _getWeatherName(String weatherCode) {
    return codeToName[weatherCode] ?? '——';
  }

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

  @override
  Widget build(BuildContext context) {
    final weatherModel = Provider.of<WeatherModel>(context);
    temperature = weatherModel.getTemperature();
    weatherString =
        '${_getWeatherName(weatherModel.getWeatherType())}    ${weatherModel.getWeatherType() == 'default' ? '——' : NameFormatter.formatName(weatherModel.selectedDistrict.cityName, 5)}';
    weatherIcon =
        'assets/newUI/weather/${codeToImage[weatherModel.getWeatherType()]}.png';
    weatherBg = codeToImage[weatherModel.getWeatherType()]!;
    Widget showBgImage = Stack(alignment: Alignment.center, children: [
      Image(
        image: AssetImage("assets/imgs/weather/bg-$weatherBg.png"),
      ),
    ]);

    Widget showTemperature = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(temperature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 160.0,
              fontWeight: FontWeight.w100,
              fontFamily: "MideaType",
              height: 1,
              decoration: TextDecoration.none,
            )),
        const Text('°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.0,
              fontWeight: FontWeight.w100,
              fontFamily: "MideaType",
              height: 1,
              decoration: TextDecoration.none,
            )),
        const Text('C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.w100,
              fontFamily: "MideaType",
              height: 1,
              decoration: TextDecoration.none,
            ))
      ],
    );

    Widget showWeather = Wrap(
        direction: Axis.horizontal,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            weatherIcon,
            width: 32,
          ),
          Text(weatherString, // 空格会按wordSpacing输出
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  wordSpacing: 2.0)),
        ]);

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 天气背景图
            showBgImage,
            // 日期时间
            const Positioned(left: 30, top: 40, child: DateTimeStr()),
            // 温度
            Positioned(left: 30, bottom: 60, child: showTemperature),
            // 地理位置及天气状况
            if (weatherIcon != '')
              Positioned(left: 30, bottom: 20, child: showWeather),
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
          Provider.of<StandbyChangeNotifier>(context, listen: false)
              .standbyPageActive = false;
        });
  }
}

class WeatherPage extends AbstractSaverScreen with StandbyOnSaverScreen {
  WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => WeatherPageState();
}
