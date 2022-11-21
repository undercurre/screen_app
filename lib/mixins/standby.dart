import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/widgets/event_bus.dart';

mixin Standby<T extends StatefulWidget> on State<T> {
  late Timer _timer;

  void noMoveTimer() {
    logger.i('noMoveTimer trigger');

    _timer = Timer.periodic(Duration(seconds: StandbySetting.standbyTime), (timer) {
      _timer.cancel();
      Navigator.of(context).pushNamed('Weather');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 永不待机
    if (StandbySetting.standbyTime == -1) {
      return;
    }

    noMoveTimer();

    bus.on("onPointerDown", (arg) {
      logger.i('bus.onPointerDown trigger in standby');

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
