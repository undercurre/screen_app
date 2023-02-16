
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_help.dart';

import '../../../states/standby_notifier.dart';
import 'index.dart';

class ScreenSaverBgClockConfig {
  String imgBg;
  Color textColor;
  ScreenSaverBgClockConfig(this.imgBg, this.textColor);
}

abstract class ScreenSaverBgClock extends AbstractSaverScreen {

  const ScreenSaverBgClock({super.key});

  @override
  State<StatefulWidget> createState() => ScreenSaverBgClockState();

  ScreenSaverBgClockConfig buildConfig();

}

class ScreenSaverBgClockState extends State<ScreenSaverBgClock> with AiWakeUPScreenSaverState {

  late Timer _timer;
  late String clock;
  late String date;
  /// 数字格式化器
  var numberFormat = NumberFormat('00', 'en_US');

  @override
  void initState() {
    super.initState();
    updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateTime();
      widget.onTick();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    widget.exit();
  }

  void updateTime() {
    final dateTime = DateTime.now();
    clock = '${numberFormat.format(dateTime.hour)}:${numberFormat.format(dateTime.minute)}';
    date = DateFormat('M月dd日 EEEE', 'zh_CN').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    ScreenSaverBgClockConfig config = widget.buildConfig();
    return GestureDetector(
      onTap: () {
        Provider.of<StandbyChangeNotifier>(context, listen: false).standbyPageActive = false;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(config.imgBg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(clock, style: TextStyle(
                  fontSize: 100,
                  color: config.textColor
                ),),
                Text(date, style: TextStyle(
                    fontSize: 20,
                    color: config.textColor
                ))
              ],
            )
          ],
        ),
      ),
    );
  }

}