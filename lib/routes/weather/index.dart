import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/index.dart';

// 天气编码转换为天气图片的名称
final codeToImage = {
  '00': 'sunny',
  '01': 'cloudy',
  '02': 'overcast',
  '03': 'rainy',
  '04': 'thunder',
  '05': 'thunder',
  '06': 'sleet',
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
  '18': 'foggy',
  '19': 'icy',
  '20': 'duststorm',
  '21': 'rainy',
  '22': 'rainy',
  '23': 'rainy',
  '24': 'rainy',
  '25': 'rainy',
  '26': 'snowy',
  '27': 'snowy',
  '28': 'snowy',
  '29': 'duststorm'
};

// 页面定义
class WeatherPageState extends State<WeatherPage> {
  String temperature = '--';
  String weatherString = '--';
  String weatherBg = '';
  String weatherIcon = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initQuery();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 获取家庭组
  void initQuery() async {
    // 预加载背景图
    if (StandbySetting.weatherCode != '') {
      setState(() {
          weatherIcon = codeToImage[StandbySetting.weatherCode]!;
          weatherBg = codeToImage[StandbySetting.weatherCode]!;
      });
    }

    logger.i(
        'Global homeInfo: ${Global.profile.homeInfo?.areaid} ${Global.profile.homeInfo?.address}');

    String? areaid = Global.profile.homeInfo?.areaid;
    areaid ??= '101280801'; // 默认顺德区
    updateWeather(areaid);

    // 每10分钟刷新天气
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      updateWeather(areaid!);
    });
  }

  void updateWeather(String cityId) async {
    var weatherOfCityRes = await MideaApi.getWeather(cityId: cityId);
    if (weatherOfCityRes.isSuccess) {
      var d = weatherOfCityRes.data;

      setState(() {
        temperature = d.weather.grade;
        weatherString =
            '${d.weather.weatherStatus}    ${d.location.chName}    室外空气 ${d.weather.pmindex}';

        // UI 特别设计的背景
        if (d.weather.pmindex == '差') {
          weatherIcon = 'cloudy';
          weatherBg = 'poor-air';
        }
        // 天气码变化 && 天气码有定义对应背景 才切换背景图
        else if (StandbySetting.weatherCode != d.weather.weatherCode &&
            codeToImage.containsKey(d.weather.weatherCode)) {
          weatherIcon = codeToImage[d.weather.weatherCode]!;
          weatherBg = codeToImage[d.weather.weatherCode]!;

          // 保存到系统设置中
          StandbySetting.weatherCode = d.weather.weatherCode;
        }
      });
    }

    // 只有以下天气背景有晚上模式
    if (!['cloudy', 'rainy', 'snowy'].contains(weatherBg)) {
      return;
    }

    var forecastRes = await MideaApi.getWeather7d(cityId: cityId);
    if (forecastRes.isSuccess) {
      var forecastData = forecastRes.data.first;
      final now = DateTime.now();
      final dateStr = DateFormat('y-M-dd').format(now);
      final timeSunrise = DateTime.parse('$dateStr ${forecastData.sunrise}');
      final timeSunset = DateTime.parse('$dateStr ${forecastData.sunset}');

      if (now.isBefore(timeSunrise) || now.isAfter(timeSunset)) {
        setState(() => weatherBg = '$weatherBg-night');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('zh_CN', null);

    Widget showBgImage = DecoratedBox(
      decoration: BoxDecoration(
          image: weatherBg != ''
              ? DecorationImage(
                  image: AssetImage("assets/imgs/weather/bg-$weatherBg.png"),
                  fit: BoxFit.cover,
                )
              : null,
          color: const Color.fromRGBO(0, 0, 0, 0)),
    );

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
            "assets/imgs/weather/icon-$weatherIcon.png",
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
        });
  }
}

// 日期时间显示
class DateTimeStrState extends State<DateTimeStr> {
  String datetime = '';
  late Timer _timer;

  String getDatetime() =>
      DateFormat('MM月d日 E kk:mm', 'zh_CN').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    setState(() => datetime = getDatetime());
    // 每5秒刷新时间
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() => datetime = getDatetime());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(datetime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontFamily: "MideaType",
          fontWeight: FontWeight.normal,
          height: 1,
          decoration: TextDecoration.none,
        ));
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => WeatherPageState();
}

class DateTimeStr extends StatefulWidget {
  const DateTimeStr({super.key});

  @override
  State<DateTimeStr> createState() => DateTimeStrState();
}
