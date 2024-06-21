import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DigitalClockWidget extends StatefulWidget {
  final bool disabled;
  final bool discriminative;

  const DigitalClockWidget({
    super.key,
    this.disabled = false,
    this.discriminative = false,
  });

  @override
  _DigitalClockWidgetState createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalClockWidget> {
  late ValueNotifier<DateTime> _currentTimeNotifier;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _currentTimeNotifier = ValueNotifier<DateTime>(DateTime.now());
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_currentTimeNotifier != null && mounted) {
        _currentTimeNotifier.value = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFF5C747B),
            Color(0xFF5F7380),
            Color(0xFF616D86),
            Color(0xFF576E87),
            Color(0xFF45617F),
            Color(0xFF33617F),
          ],
          stops: [0.0, 0.2, 0.4, 0.44, 0.7, 1.0]
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
                        color: const Color.fromRGBO(255, 255, 255, 0.80).withOpacity(0.79)),
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
                        color: const Color.fromRGBO(255, 255, 255, 0.80).withOpacity(0.79)),
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
