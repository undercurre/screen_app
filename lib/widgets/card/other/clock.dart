import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DigitalClockWidget extends StatefulWidget {
  final bool disabled;

  DigitalClockWidget({
    this.disabled = false,
  });

  @override
  _DigitalClockWidgetState createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalClockWidget> {
  late ValueNotifier<DateTime> _currentTimeNotifier;

  @override
  void initState() {
    super.initState();
    _currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
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
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x33616A76),
            Color(0x33434852),
          ],
          stops: [0.06, 1.0],
          transform: GradientRotation(213 * (3.1415926 / 360.0)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ValueListenableBuilder<DateTime>(
            valueListenable: _currentTimeNotifier,
            builder: (BuildContext context, DateTime value, Widget? child) {
              String hour = value.hour.toString().padLeft(2, '0');
              String minute = value.minute.toString().padLeft(2, '0');
              String second = value.second.toString().padLeft(2, '0');
              return Text(
                '$hour:$minute',
                style: const TextStyle(fontSize: 65),
              );
            },
          ),
          ValueListenableBuilder<DateTime>(
            valueListenable: _currentTimeNotifier,
            builder: (BuildContext context, DateTime value, Widget? child) {
              String formattedDate = _getFormattedDate(value);
              String weekday = _getWeekday(value.weekday);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        fontFamily: 'MideaType',
                        color: const Color.fromRGBO(255, 255, 255, 0.80)
                            .withOpacity(0.79)),
                  ),
                  const SizedBox(
                    width: 10,
                    height: 30,
                  ),
                  Text(
                    weekday,
                    style: TextStyle(
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: const Color.fromRGBO(255, 255, 255, 0.80)
                            .withOpacity(0.79)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    String month = dateTime.month.toString();
    String day = dateTime.day.toString().padLeft(2, '0');
    return "$month月$day日";
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      case 7:
        return '星期日';
      default:
        return '';
    }
  }
}
