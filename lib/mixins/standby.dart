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
      var standbyNotifier =
          Provider.of<StandbyChangeNotifier>(context, listen: false);

      debugPrint(
          'standbyTimeOpt: ${standbyNotifier.standbyTimeOpt.value}');

      if (standbyNotifier.standbyTimer != null) {
        standbyNotifier.standbyTimer!.cancel();
      }

      // 永不待机
      if (standbyNotifier.standbyTimeOpt.value == -1) {
        return;
      }

      standbyNotifier.standbyTimer = Timer.periodic(
          Duration(seconds: standbyNotifier.standbyTimeOpt.value), (_) {
        var routePath = ModalRoute.of(context)?.settings.name;
        debugPrint(
            "current route: $routePath, 'getNetState(): ${NetUtils.getNetState()}, standbyPageActive: ${standbyNotifier.standbyPageActive}, standbyTimeOpt: ${standbyNotifier.standbyTimeOpt.value}");

        //临时注释
        //if (NetUtils.getNetState() == null) {
        // return;
        //}

        if (standbyNotifier.standbyPageActive) {
          return;
        }

        standbyNotifier.standbyPageActive = true;
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
    var standbyNotifier =
    Provider.of<StandbyChangeNotifier>(context, listen: false);

    if (standbyNotifier.standbyTimer != null) {
      standbyNotifier.standbyTimer!.cancel();
    }
    bus.off("onPointerDown");
    super.dispose();
  }
}
