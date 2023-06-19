import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DigitalWeatherWidget extends StatefulWidget {
  @override
  _DigitalWeatherWidgetState createState() => _DigitalWeatherWidgetState();
}

class _DigitalWeatherWidgetState extends State<DigitalWeatherWidget> {
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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
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
          ValueListenableBuilder<DateTime>(
            valueListenable: _currentTimeNotifier,
            builder: (BuildContext context, DateTime value, Widget? child) {
              return Container(child: _getWeatherIcon(1));
            },
          ),
          Expanded(
              child: Stack(children: [
            ValueListenableBuilder<DateTime>(
              valueListenable: _currentTimeNotifier,
              builder: (BuildContext context, DateTime value, Widget? child) {
                String curTemp = _getCurTemperature(value);
                String minTemp = _getMinTemperature(value);
                String location = _getLocation('1');
                String weatherName = _getWeatherName(1);
                return Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            SizedBox(width: 80, height: 80),
                            Positioned(
                              top: -36,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 14, 0),
                                child: Text(
                                  curTemp,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 48,
                                    fontFamily: 'MideaType',
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1)
                                            .withOpacity(0.79),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weatherName,
                              style: TextStyle(
                                  letterSpacing: 1.33,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: const Color.fromRGBO(255, 255, 255, 1)
                                      .withOpacity(0.79)),
                            ),
                            Text(
                              location,
                              style: TextStyle(
                                  letterSpacing: 1.33,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color: const Color.fromRGBO(255, 255, 255, 1)
                                      .withOpacity(0.64)),
                            ),
                          ],
                        )
                      ],
                    ));
              },
            ),
            Positioned(
              left: 98,
              top: -4,
              child: Text(
                '°',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontFamily: 'MideaType',
                  color:
                      const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.79),
                ),
              ),
            )
          ])),
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

  String _getLocation(String code) {
    return '顺德区';
  }

  SizedBox _getWeatherIcon(int weatherCode) {
    return const SizedBox(
        width: 110,
        height: 110,
        child: Image(image: AssetImage('assets/newUI/weather/sun_cloud.png')));
  }

  String _getWeatherName(int weekday) {
    return '雾霾天';
  }
}
