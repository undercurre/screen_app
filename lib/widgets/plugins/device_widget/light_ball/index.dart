import 'package:flutter/material.dart';

class LightBall extends StatefulWidget {
  final num brightness;
  final num? colorTemperature;

  const LightBall({super.key, required this.brightness, this.colorTemperature});

  @override
  State<LightBall> createState() => _LightBallState();
}

class _LightBallState extends State<LightBall> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        Positioned(
          left: -85,
          top: 144,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(105.0)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, widget.brightness / 400), // 阴影颜色
                      offset: const Offset(-10, -10), // 阴影位置
                      blurRadius: 30, // 模糊程度
                      spreadRadius: 40), // 模糊大小
                ]),
          ),
        ),
        Positioned(
          left: -65,
          top: 144,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(125.0)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, widget.brightness / 500), // 阴影颜色
                      offset: const Offset(0, 0), // 阴影位置
                      blurRadius: 40, // 模糊程度
                      spreadRadius: 60), // 模糊大小
                ]),
          ),
        ),
        const Positioned(
          left: 0,
          top: 98,
          child: Image(
            image: AssetImage('assets/imgs/plugins/0x13/dengguang.png'),
          ),
        ),
        Positioned(
          left: -70,
          top: 158,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(71.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(
                        255, 255, 255, widget.brightness / 120), // 阴影颜色
                    offset: const Offset(0, 0), // 阴影位置
                    blurRadius: 10, // 模糊程度
                    spreadRadius: 10), // 模糊大小
              ],
            ),
          ),
        ),
        Positioned(
          left: -60,
          top: 158,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(71.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(
                        255, 209, 133, widget.colorTemperature! / 120),
                    // 阴影颜色
                    offset: const Offset(0, 0),
                    // 阴影位置
                    blurRadius: 10,
                    // 模糊程度
                    spreadRadius: 10), // 模糊大小
              ],
            ),
          ),
        ),
      ],
    );
  }
}
