import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/main.dart';
import 'package:screen_app/channel/index.dart';

class ShowStandby {
  static void startTimer() async {
    debugPrint('[ShowStandby]standbyTimer begin');

    await Future.delayed(const Duration(seconds: 0));

    var standbyNotifier = Provider.of<StandbyChangeNotifier>(
        navigatorKey.currentContext!,
        listen: false);

    debugPrint('standbyTimeOpt: ${standbyNotifier.standbyTimeOpt.value}');

    if (standbyNotifier.standbyTimer != null) {
      standbyNotifier.standbyTimer!.cancel();
      debugPrint('previous Timer cancelled');
    }

    // 永不待机
    if (standbyNotifier.standbyTimeOpt.value == -1) {
      return;
    }

    standbyNotifier.standbyTimer =
        Timer(Duration(seconds: standbyNotifier.standbyTimeOpt.value), () {
      if (standbyNotifier.standbyPageActive) {
        return;
      }

      // 设置待机页标志为已启用
      standbyNotifier.standbyPageActive = true;

      // 进入待机页
      // TODO 根据系统设置，跳转到对应的待机页
      const currentStandbyPage = 'Weather';
      navigatorKey.currentState?.pushNamed(currentStandbyPage);

      debugPrint('StandbyPage pushed');
    });
  }

  // AI 语音状态置于非激活，则重新生成定时器
  static void aiRestartTimer() {
    aiMethodChannel.registerAiStateCallBack((int state) {
      if (state == 0) {
        debugPrint("语音状态: 0, 重新生成定时器");
        startTimer();
      }
    });
  }

  static void disposeTimer() {
    var standbyNotifier = Provider.of<StandbyChangeNotifier>(
        navigatorKey.currentContext!,
        listen: false);

    if (standbyNotifier.standbyTimer != null) {
      standbyNotifier.standbyTimer!.cancel();
      debugPrint('standbyTimer cancelled');
    }
  }
}
