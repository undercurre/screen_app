import 'package:flutter/material.dart';

mixin Throttle<T extends StatefulWidget> on State<T> {
  Map<String, DateTime?> startTimeMap = {};

  void throttle(Function cb, {String throttleKey = 'deFaultThrottleId', durationTime = const Duration(seconds: 1)}) {
    DateTime currentTime = DateTime.now();
    if (startTimeMap[throttleKey] == null) {
      cb.call();
      startTimeMap[throttleKey] = currentTime;
    } else {
      if (currentTime.difference(startTimeMap[throttleKey]!) > durationTime) {
        cb.call();
        startTimeMap[throttleKey] = currentTime;
      }
    }
  }
}