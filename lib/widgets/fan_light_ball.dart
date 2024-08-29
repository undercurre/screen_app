import 'package:flutter/material.dart';

import '../common/logcat_helper.dart';

class FanLightBall extends StatelessWidget {
  int brightness;
  int colorTemperature;

  FanLightBall({super.key, required this.brightness, required this.colorTemperature}) {
    Log.i("brightness=$brightness colorTemperature=$colorTemperature");
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
            width: 130,
            height: 130,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(105.0)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, brightness / 300), // 阴影颜色
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
            width: 130,
            height: 130,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(125.0)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(
                          255, 209, 133, (100 - colorTemperature) / 300 * brightness / 120), // 阴影颜色
                      offset: const Offset(0, 0), // 阴影位置
                      blurRadius: 40, // 模糊程度
                      spreadRadius: 60), // 模糊大小
                ]),
          ),
        ),
        const Image(
          width: 218,
          height: 275,
          image:AssetImage('assets/imgs/plugins/0x13/fan_light_off.png'),
        ),
        Positioned(
          left: -70,
          top: 158,
          child: Container(
            width: 185,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(
                        255, 255, 255, brightness / 120), // 阴影颜色
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
            width: 190,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(
                        255, 209, 133, (100 - colorTemperature) / 120 * brightness / 120),
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
