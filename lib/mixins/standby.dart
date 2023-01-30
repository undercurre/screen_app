import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/event_bus.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

mixin Standby<T extends StatefulWidget> on State<T> {
  void noMoveTimer() {
    debugPrint('noMoveTimer begin');

    // onPointerDown 早于 onTap，故等待下一Frame再执行，以免 standbyTime 未更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var weatherNotifier =
          Provider.of<WeatherChangeNotifier>(context, listen: false);

      debugPrint(
          'weatherNotifier.standbyTime: ${weatherNotifier.standbyTimer.value}');

      if (weatherNotifier.weatherTimer != null) {
        weatherNotifier.weatherTimer!.cancel();
      }

      // 永不待机
      if (weatherNotifier.standbyTimer.value == -1) {
        return;
      }

      weatherNotifier.weatherTimer = Timer.periodic(
          Duration(seconds: weatherNotifier.standbyTimer.value), (_) {
        var routePath = ModalRoute.of(context)?.settings.name;
        debugPrint(
            "current route: $routePath, 'getNetState(): ${NetUtils.getNetState()}, weatherPageActive: ${weatherNotifier.weatherPageActive}, standbyTimer: ${weatherNotifier.standbyTimer.value}");

        //临时注释
        //if (NetUtils.getNetState() == null) {
        // return;
        //}

        if (weatherNotifier.weatherPageActive) {
          return;
        }

        weatherNotifier.weatherPageActive = true;
        Navigator.of(context).pushNamed('Weather');
        debugPrint('WeatherPage pushed');
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    noMoveTimer();

    // 有用户操作，则取消原有定时，重新生成定时器
    // ! 特别地，如果用户设置了新的待机等待时间，也会触发此处操作，重新生成定时器
    bus.on("onPointerDown", (arg) {
      debugPrint('onPointerDown');

      noMoveTimer();
    });
  }

  @override
  void dispose() {
    var weatherNotifier =
    Provider.of<WeatherChangeNotifier>(context, listen: false);

    if (weatherNotifier.weatherTimer != null) {
      weatherNotifier.weatherTimer!.cancel();
    }
    bus.off("onPointerDown");
    super.dispose();
  }
}
