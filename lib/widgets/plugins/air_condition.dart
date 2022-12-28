import 'package:flutter/material.dart';

class AirCondition extends StatefulWidget {
  final String? mode;
  final num? temperature;
  final num? windSpeed;

  const AirCondition({super.key, this.mode, this.temperature, this.windSpeed});

  @override
  State<AirCondition> createState() => _AirCondition();
}

class _AirCondition extends State<AirCondition> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: const [
          SizedBox(
            width: 150,
            height: 200,
          ),
          Positioned(
            left: 0,
            top: 103,
            child: Image(
              image: AssetImage('assets/imgs/plugins/0xAC/air_condition.png'),
            ),
          ),
          Positioned(
            left: 0,
            top: 103,
            child: Image(
              image: AssetImage('assets/imgs/plugins/0xAC/wind.png'),
            ),
          ),
        ]);
  }
}
