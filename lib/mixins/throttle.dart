import 'dart:async';

import 'package:flutter/material.dart';

mixin Throttle<T extends StatefulWidget> on State<T> {
  Map<String, DateTime?> startTimeMap = {};
  Map<String, Timer?> timerMap = {};

  void throttle(Function cb, {String throttleKey = 'deFaultThrottleId', durationTime = const Duration(seconds: 1)}) {
    DateTime currentTime = DateTime.now();
    if (startTimeMap[throttleKey] == null) {
      cb.call();
      startTimeMap[throttleKey] = currentTime;
    } else {
      if (timerMap[throttleKey] != null) {
        timerMap[throttleKey]!.cancel();
      }
      if (currentTime.difference(startTimeMap[throttleKey]!) > durationTime) {
        cb.call();
        startTimeMap[throttleKey] = currentTime;
      } else {
        timerMap[throttleKey] = Timer(durationTime - currentTime.difference(startTimeMap[throttleKey]!), () {
          cb.call();
          startTimeMap[throttleKey] = DateTime.now();
        });
      }
    }
  }
}
