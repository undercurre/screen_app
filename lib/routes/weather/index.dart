import 'package:flutter/material.dart';

class WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
        fit: StackFit.expand,
        children: const [
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imgs/weather/bg-rainy.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              top: 30,
              left: 30,
              child: Text("12月21日 星期一 20:32",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    height: 1,
                    decoration: TextDecoration.none,
                )
              ),
          ),
          Positioned(
            bottom: 100,
            left: 30,
            child: Text("-7°",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 96.0,
                  height: 1,
                  decoration: TextDecoration.none,
                )
            ),
          ),
          Positioned(
            bottom: 20,
            left: 30,
            child: Text("下雪 室外空气 中",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  height: 1,
                  decoration: TextDecoration.none,
                )
            ),
          )
        ],
      );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => WeatherPageState();
}
