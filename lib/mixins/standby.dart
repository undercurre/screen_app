import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';

mixin Standby<T extends StatefulWidget> on State<T> {
  late Timer _timer;

  void noMoveTimer() {
    // onPointerDown 早于 onTap，故等待下一Frame再执行，以免 standbyTime 未更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var weatherNotifier =
          Provider.of<WeatherChangeNotifier>(context, listen: false);

      debugPrint('weatherNotifier.standbyTime: ${weatherNotifier.standbyTimer.value}');

      // 永不待机
      if (weatherNotifier.standbyTimer.value == -1) {
        _timer.cancel();
        return;
      }

      _timer = Timer.periodic(Duration(seconds: weatherNotifier.standbyTimer.value),
          (_) {
        _timer.cancel();
        Navigator.of(context).pushNamed('Weather');
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    noMoveTimer();

    bus.on("onPointerDown", (arg) {
      _timer.cancel();

      noMoveTimer();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    bus.off("onPointerDown");
    super.dispose();
  }
}
