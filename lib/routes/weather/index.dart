import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common/api/iot_api.dart';

class WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imgs/weather/bg-rainy.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Positioned(
          top: 40,
          left: 30,
          child: Text("12月21日 周一 20:32",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "MideaType",
                fontWeight: FontWeight.normal,
                height: 1,
                decoration: TextDecoration.none,
              )),
        ),
        const Positioned(
          bottom: 60,
          left: 30,
          child: Text("-7°",
              style: TextStyle(
                color: Colors.white,
                fontSize: 160.0,
                fontWeight: FontWeight.w100,
                fontFamily: "MideaType",
                height: 1,
                decoration: TextDecoration.none,
              )),
        ),
        Positioned(
            bottom: 20,
            left: 30,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  "assets/imgs/weather/icon-snowy.png",
                  width: 26,
                ),
                const Text("下雪 室外空气 中",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
                TextButton.icon(
                  onPressed: () async {
                    var res = await IotApi.getHomegroup();
                    if (kDebugMode) {
                      print(res.data.homeList.first.address);
                      print(res.data.homeList.first.areaid);
                    }
                  },
                  label: const Text('接口测试'),
                  icon: const Icon(Icons.sunny_snowing),
                )
              ],
            ))
      ],
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => WeatherPageState();
}
