import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../channel/index.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/setting.dart';
import '../../../main.dart';
import '../../../states/standby_notifier.dart';
import '../../../widgets/event_bus.dart';

/// 息屏设置
abstract class AbstractSaverScreen extends StatefulWidget {

  const AbstractSaverScreen({super.key});

  /// 对外暴露定时器每次执行的回调方法
  void onTick(){}

  /// 组件退出
  void exit(){}

}

mixin StandbyOnSaverScreen on AbstractSaverScreen {

  final List<bool?> array = List.generate(10, (index) => null);
  bool registerScreenBroadcast = false;

  @override
  void onTick() {
    super.onTick();

    () async {
      if(Setting.instant().nightModeEnable) {
        bool toBeClose = Setting.instant().isStandByDuration();

        List.copyRange(array, 0, array, 1, array.length);
        array[array.length - 1] = toBeClose;

        debugPrint('toBeClose = $toBeClose');

        if(array.every((element) => element == false) || array.every((element) => element == true)) {
          settingMethodChannel.setScreenClose(toBeClose);
          // 重新复位数组，纠正上面方法设置的频率
          array.fillRange(0, array.length, !toBeClose);
        }
      }
    }();

  }

  @override
  void exit() {
    settingMethodChannel.setScreenClose(false);
  }

}

/// 靠近唤醒
mixin NeaWakeUpState<T extends StatefulWidget> on State<T> {
  bool _dispose = false;
  late Timer _timer;

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 60), () {
      settingMethodChannel.getNearWakeup().then((value) {
        if(!_dispose && value) {
          settingMethodChannel.nearWakeupCallback = (result) {
            if(result) {
              Log.w("被唤醒，即将退出待机页");
              // 设置退出待机状态
              Provider.of<StandbyChangeNotifier>(context, listen: false).standbyPageActive = false;
              // 启动待机倒计时器
              bus.emit("onPointerDown");
              Navigator.of(context).pop();
            }
          };
          settingMethodChannel.registerNearWakeup();
        }
      });
    });

  }

  @override
  @mustCallSuper
  void dispose() {
    _dispose = true;
    _timer.cancel();
    settingMethodChannel.unregisterNearWakeup();
    super.dispose();
  }

}

/// AI语音唤醒处理
mixin AiWakeUPScreenSaverState<T extends StatefulWidget> on State<T> {

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    aiMethodChannel.registerAiStateCallBack(dropStandby);
  }

  // 退出待机页
  void dropStandby(int? state) {
    debugPrint("begin of dropStandby");

    // 若不带state，则直接退出
    if (state != null && state != 1) {
      return;
    }

    debugPrint("语音状态: state==1, 退出待机页");

    Navigator.of(context).pop();
    // 设置待机状态退出
    Provider.of<StandbyChangeNotifier>(context, listen: false)
        .standbyPageActive = false;

    debugPrint("end of dropStandby");
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    aiMethodChannel.unregisterAiStateCallBack(dropStandby);
  }

}