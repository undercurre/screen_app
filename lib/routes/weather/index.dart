import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../common/api/iot_api.dart';

// 页面定义
class WeatherPageState extends State<WeatherPage> {
  String city = '';

  @override
  void initState() {
    super.initState();
    initQuery();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 获取家庭组
  void initQuery() async {
    var res = await IotApi.getHomegroup();
    if (res.isSuccess) {
      setState(() {
        List arr = res.data.homeList.first.address.split(' ');
        city = arr[arr.length - 1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('zh_CN', null);

    Widget showBgImage = const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/imgs/weather/bg-rainy.png"),
          fit: BoxFit.cover,
        ),
      ),
    );

    Widget showTemperature = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('-37', style: TextStyle(
          color: Colors.white,
          fontSize: 160.0,
          fontWeight: FontWeight.w100,
          fontFamily: "MideaType",
          height: 1,
          decoration: TextDecoration.none,
        )),
        Text('°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 80.0,
              fontWeight: FontWeight.w100,
              fontFamily: "MideaType",
              height: 1,
              decoration: TextDecoration.none,
            )
        )
      ],
    );

    Widget showWeather = Wrap(
        direction: Axis.horizontal,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            "assets/imgs/weather/icon-snowy.png",
            width: 26,
          ),
          Text('下雪    $city    室外空气 中', // 空格会按wordSpacing输出
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  wordSpacing: 2.0)),
        ]);

    return Stack(
      fit: StackFit.expand,
      children: [
        showBgImage,
        const Positioned(left: 30, top: 40, child: DateTimeStr()),
        Positioned(left: 30, bottom: 60, child: showTemperature),
        Positioned(left: 30, bottom: 20, child: showWeather),
        Positioned(
            child: Row(
          children: [
            TextButton.icon(
              onPressed: () async {
                await IotApi.getWeather();
              },
              label: const Text('接口测试'),
              icon: const Icon(Icons.sunny_snowing),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pushNamed('/');
              },
              label: const Text('back'),
              icon: const Icon(Icons.keyboard_return),
            )
          ],
        )),
      ],
    );
  }
}

// 日期时间显示
class DateTimeStrState extends State<DateTimeStr> {
  String datetime = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        datetime = DateFormat('MM月d日 E kk:mm', 'zh_CN').format(DateTime.now());
      });
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
