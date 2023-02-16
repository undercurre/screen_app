import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/main.dart';
import 'package:screen_app/states/index.dart';
import '../setting/screen_saver/screen_saver_help.dart';
import 'code_to_image.dart';
import 'show_datetime.dart';

// 页面定义
class WeatherPageState extends State<WeatherPage> with AiWakeUPScreenSaverState {
  String temperature = '--';
  String weatherString = '--';
  String weatherBg = '';
  String weatherIcon = '';
  late String weatherCode;
  late Timer _timer;
  int lastUpdateWeatherTime = 0; // 最后刷新天气的时间

  @override
  void initState() {
    super.initState();
    initQuery();

  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    widget.exit();
  }

  // 获取家庭组
  Future<void> initQuery() async {
    // 预加载背景图
    weatherCode =
        Provider.of<StandbyChangeNotifier>(context, listen: false).weatherCode;

    String imageName = codeToImage[weatherCode]!;

    setState(() {
      weatherIcon = imageName;
      weatherBg = imageName;
    });

    logger.i(
        'Global homeInfo: ${Global.profile.homeInfo?.areaId} ${Global.profile.homeInfo?.address}');

    String? areaid = Global.profile.homeInfo?.areaId;
    areaid ??= '101280801'; // 默认顺德区
    updateWeather(areaid);

    // 每10分钟刷新天气
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      updateWeather(areaid!);
      widget.onTick();
    });
  }

  Future<void> updateWeather(String cityId) async {
    /// 2023-2-16 增加时间间隔过滤
    /// 严格控制接口的刷新次数，此接口按次收费
    if(DateTime.now().millisecondsSinceEpoch - lastUpdateWeatherTime < 2 * 60 * 60 * 1000) {
      return;
    }
    lastUpdateWeatherTime = DateTime.now().millisecondsSinceEpoch;

    var weatherOfCityRes = await WeatherApi.getWeather(cityId: cityId);
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
        else if (Provider.of<StandbyChangeNotifier>(context, listen: false)
                    .weatherCode !=
                d.weather.weatherCode &&
            codeToImage.containsKey(d.weather.weatherCode)) {
          weatherIcon = codeToImage[d.weather.weatherCode]!;
          weatherBg = codeToImage[d.weather.weatherCode]!;

          // 保存到系统设置中
          Provider.of<StandbyChangeNotifier>(context, listen: false)
              .weatherCode = d.weather.weatherCode;
        }
      });
    }

    // 只有以下天气背景有晚上模式
    if (!['cloudy', 'rainy', 'snowy'].contains(weatherBg)) {
      return;
    }

    var forecastRes = await WeatherApi.getWeather7d(cityId: cityId);
    if (forecastRes.isSuccess) {
      var forecastData = forecastRes.data.first;
      final now = DateTime.now();
      final dateStr = DateFormat('y-MM-dd').format(now);
      final timeSunrise = DateTime.parse('$dateStr ${forecastData.sunrise}');
      final timeSunset = DateTime.parse('$dateStr ${forecastData.sunset}');

      if (now.isBefore(timeSunrise) || now.isAfter(timeSunset)) {
        setState(() => weatherBg = '$weatherBg-night');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          navigatorKey.currentState?.pop();
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
