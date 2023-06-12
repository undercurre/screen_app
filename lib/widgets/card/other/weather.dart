import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DigitalWeatherWidget extends StatefulWidget {
  @override
  _DigitalClockWidgetState createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalWeatherWidget> {
  late ValueNotifier<DateTime> _currentTimeNotifier;

  @override
  void initState() {
    super.initState();
    _currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
    Timer.periodic(const Duration(seconds: 72000), (Timer timer) {
      if (_currentTimeNotifier != null && mounted) {
        _currentTimeNotifier.value = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _currentTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF767B86),
            Color(0xFF88909F),
            Color(0xFF516375),
          ],
          stops: [0, 0.24, 1],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ValueListenableBuilder<DateTime>(
              valueListenable: _currentTimeNotifier,
              builder: (BuildContext context, DateTime value, Widget? child) {
                return _getWeatherIcon(1);
              },
            ),
          ),
          ValueListenableBuilder<DateTime>(
            valueListenable: _currentTimeNotifier,
            builder: (BuildContext context, DateTime value, Widget? child) {
              String curTemp = _getCurTemperature(value);
              String minTemp = _getMinTemperature(value);
              String weatherName = _getWeatherName(1);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curTemp,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 48,
                        fontFamily: 'MideaType',
                        color: const Color.fromRGBO(255, 255, 255, 1)
                            .withOpacity(0.79)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        minTemp,
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color.fromRGBO(255, 255, 255, 1)
                                .withOpacity(0.79)),
                      ),
                      Text(
                        weatherName,
                        style: TextStyle(
                            letterSpacing: 1.33,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: const Color.fromRGBO(255, 255, 255, 1)
                                .withOpacity(0.79)),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getCurTemperature(DateTime dateTime) {
    return '26';
  }

  String _getMinTemperature(DateTime dateTime) {
    return '/16℃';
  }

  Container _getWeatherIcon(int weatherCode) {
    return Container(
        child: const Image(image: AssetImage('assets/newUI/weather/sun_cloud.png')));
  }

  String _getWeatherName(int weekday) {
    return '雾霾天';
  }
}
