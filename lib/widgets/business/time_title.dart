import 'package:flutter/material.dart';

class TimeTitle extends StatefulWidget {
  const TimeTitle({super.key});

  @override
  State<TimeTitle> createState() => TimeTitleState();
}

class TimeTitleState extends State<TimeTitle> {

  // 获取现在日期
  String time = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontFamily: 'MideaType',
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      ),
    );
  }
}
