import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/main.dart';
import 'package:screen_app/channel/index.dart';

import '../common/setting.dart';

class ShowStandby {
  static void startTimer() async {
    debugPrint('[ShowStandby]standbyTimer begin');
    settingMethodChannel.noticeNativeStandbySate(false);
    await Future.delayed(const Duration(seconds: 0));

    var standbyNotifier = Provider.of<StandbyChangeNotifier>(
        navigatorKey.currentContext!,
        listen: false);

    debugPrint('standbyTimeOpt: ${standbyNotifier.standbyTimeOpt.value}');

    if (standbyNotifier.standbyTimer != null) {
      standbyNotifier.standbyTimer!.cancel();
      debugPrint('previous Timer cancelled');
    }

    standbyNotifier.standbyTimer =
        Timer(Duration(seconds: getStandbyTimeOpt(standbyNotifier)), () {

          debugPrint('standbyPageActive = ${standbyNotifier.standbyPageActive}');

      if (standbyNotifier.standbyPageActive) {
        return;
      }

      if (standbyNotifier.standbyTimeOpt.value == -1) {
        /// 设置为永不待机模式
        /// 如果当前时间段为息屏，则启动特殊的屏保
        if(Setting.instant().isStandByDuration()) {
          standbyNotifier.standbyPageActive = true;
          navigatorKey.currentState?.pushNamed("SpecialBlackBgSaverScreen");
          settingMethodChannel.noticeNativeStandbySate(true);
        }
      } else {
        if(Setting.instant().screenSaverReplaceToOff) {
          /// 待机改为直接熄屏
          settingMethodChannel.setScreenClose(true);
        } else {
          /// 普通待机模式
          standbyNotifier.standbyPageActive = true;
          navigatorKey.currentState?.pushNamed("ScreenSaver");
          settingMethodChannel.noticeNativeStandbySate(true);
        }
        debugPrint('StandbyPage pushed');
      }

    });
  }

  static int getStandbyTimeOpt(StandbyChangeNotifier notifier) {
    /// 如果待机时间为-1 ，则默认设置为3分钟
    /// 因为这种情况也需要进入待机，当有设置息屏时间的时候
    debugPrint('timeOpt ${notifier.standbyTimeOpt.value}');
    return notifier.standbyTimeOpt.value == -1 ? 3 * 60 : notifier.standbyTimeOpt.value;
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
