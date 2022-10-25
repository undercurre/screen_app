import 'package:flutter/material.dart';

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
                Image.asset("assets/imgs/weather/icon-snowy.png",
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
