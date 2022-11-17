import 'dart:async';
import 'package:flutter/material.dart';
import '../common/index.dart';
import '../widgets/event_bus.dart';

mixin Standby<T extends StatefulWidget> on State<T> {
  late Timer _timer;

  void noMoveTimer() {
    logger.i('noMoveTimer trigger');

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _timer.cancel();
      Navigator.of(context).pushNamed('Weather');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    super.dispose();
  }
}
