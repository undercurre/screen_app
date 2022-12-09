import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// 日期时间显示
class DateTimeStrState extends State<DateTimeStr> {
  String datetime = '';
  late Timer _timer;

  // !! E 依赖 initializeDateFormatting 国际化
  String getDatetime() =>
      DateFormat('MM月d日 E kk:mm', 'zh_CN').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    // 国际化日期语言
    initializeDateFormatting('zh_CN', null);

    setState(() => datetime = getDatetime());
    // 每5秒刷新时间
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() => datetime = getDatetime());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(datetime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontFamily: "MideaType",
          fontWeight: FontWeight.normal,
          height: 1,
          decoration: TextDecoration.none,
        ));
  }
}

class DateTimeStr extends StatefulWidget {
  const DateTimeStr({super.key});

  @override
  State<DateTimeStr> createState() => DateTimeStrState();
}
