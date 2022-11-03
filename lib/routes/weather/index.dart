import 'package:flutter/material.dart';
import '../../common/api/iot_api.dart';
import '../../common/global.dart';

class WeatherPageState extends State<WeatherPage> {
  String city = '';

  @override
  Widget build(BuildContext context) {
    const showBgImage = DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/imgs/weather/bg-rainy.png"),
          fit: BoxFit.cover,
        ),
      ),
    );

    const showDateTime = Text("12月21日 周一 20:32",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontFamily: "MideaType",
          fontWeight: FontWeight.normal,
          height: 1,
          decoration: TextDecoration.none,
        ));

    const showTemperature = Text("-7°",
        style: TextStyle(
          color: Colors.white,
          fontSize: 160.0,
          fontWeight: FontWeight.w100,
          fontFamily: "MideaType",
          height: 1,
          decoration: TextDecoration.none,
        ));

    var showWeather = Wrap(
        direction: Axis.horizontal,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            "assets/imgs/weather/icon-snowy.png",
            width: 26,
          ),
          Text('下雪    $city    室外空气 中',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontFamily: "MideaType",
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                wordSpacing: 10.0
              )),
        ]);

    return Stack(
      fit: StackFit.expand,
      children: [
        showBgImage,
        const Positioned(left: 30, top: 40, child: showDateTime),
        const Positioned(left: 30, bottom: 60, child: showTemperature),
        Positioned(left: 30, bottom: 20, child: showWeather),
        Positioned(
            child: Row(
          children: [
            TextButton.icon(
              onPressed: () async {
                var res = await IotApi.getHomegroup();
                logger.i(res.data.homeList.first.address);
                logger.i(res.data.homeList.first.areaid);
                if (res.isSuccess) {
                  setState(() {
                    List arr = res.data.homeList.first.address.split(' ');
                    city = arr[arr.length - 1];
                  });
                }
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

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => WeatherPageState();
}
