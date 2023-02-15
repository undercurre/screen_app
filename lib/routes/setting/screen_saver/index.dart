import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_bg_clock.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_hand_clock.dart';
import 'package:screen_app/routes/weather/index.dart';

import '../../../common/setting.dart';

class ScreenSaver extends StatelessWidget {
  const ScreenSaver({super.key});

  /// 获取所有的屏保页
  static List<Widget> getAll() {
    return <Widget>[
      ScreenSaverHandClock1(),
      ScreenSaverHandClock2(),
      ScreenSaverHandClock3(),
      ScreenSaverBgClock4(),
      ScreenSaverBgClock5(),
      ScreenSaverBgClock6(),
      WeatherPage(),
      ScreenSaverBgClock8(),
      ScreenSaverBgClock9(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return getAll()[Setting.instant().screenSaverId];
  }
}

/// 指针时钟一
class ScreenSaverHandClock1 extends ScreenSaverHandClock with StandbyOnSaverScreen {

  ScreenSaverHandClock1({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_1_disc.png",
          imgMinute: "assets/imgs/setting/hand_clock_1_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_1_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_1_point.png");

}

/// 指针时钟二
class ScreenSaverHandClock2 extends ScreenSaverHandClock with StandbyOnSaverScreen {

  ScreenSaverHandClock2({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_2_disc.png",
          imgSecond: "assets/imgs/setting/hand_clock_2_second.png",
          imgMinute: "assets/imgs/setting/hand_clock_2_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_2_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_2_point.png",
          secondDistance: 100,
          widgetBg: Stack(
            children: [
              Image.asset("assets/imgs/setting/hand_clock_2_bg.png"),
              Align(
                child: Image.asset("assets/imgs/setting/hand_clock_2_bg_point.png"),
              )
            ],
          )
      );

}

/// 指针时钟三
class ScreenSaverHandClock3 extends ScreenSaverHandClock with StandbyOnSaverScreen {

  ScreenSaverHandClock3({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_3_disc.png",
          imgMinute: "assets/imgs/setting/hand_clock_3_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_3_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_3_point.png");

}

/// 背景时钟四
class ScreenSaverBgClock4 extends ScreenSaverBgClock with StandbyOnSaverScreen {
  ScreenSaverBgClock4({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
    'assets/imgs/setting/hand_clock_4_bg.png',
    Colors.white
  );

}

/// 背景时钟五
class ScreenSaverBgClock5 extends ScreenSaverBgClock with StandbyOnSaverScreen  {
  ScreenSaverBgClock5({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_5_bg.png',
      Colors.white
  );

}

/// 背景时钟六
class ScreenSaverBgClock6 extends ScreenSaverBgClock with StandbyOnSaverScreen {
  ScreenSaverBgClock6({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_6_bg.png',
      Colors.white
  );

}

/// 天气时钟七
/// [WeatherPage]

/// 背景时钟八
class ScreenSaverBgClock8 extends ScreenSaverBgClock with StandbyOnSaverScreen  {
  ScreenSaverBgClock8({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_8_bg.png',
      Colors.black
  );

}

/// 背景时钟九
class ScreenSaverBgClock9 extends ScreenSaverBgClock with StandbyOnSaverScreen {
  ScreenSaverBgClock9({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_9_bg.png',
      Colors.white
  );

}


/// 息屏设置
abstract class AbstractSaverScreen extends StatefulWidget {

  const AbstractSaverScreen({super.key});

  /// 对外暴露定时器每次执行的回调方法
  void onTick(){}

  /// 点击屏幕
  void onClickScreen() {}

  /// 组件退出
  void exit(){}

}

mixin StandbyOnSaverScreen on AbstractSaverScreen {
  final List<bool?> array = [false, true, false, true, false, true, false, true, false, true];
  bool? inClose;

  @override
  void onTick() {
    super.onTick();

    () async {
      bool toBeClose = Setting.instant().isStandByDuration();

      List.copyRange(array, 0, array, 1, array.length);
      array[array.length - 1] = toBeClose;

      debugPrint('toBeClose = $toBeClose');
      debugPrint('inClose = $inClose');

      if(array.every((element) => element == false) && inClose != false
          || array.every((element) => element == true) && inClose != true) {
        settingMethodChannel.setScreenClose(toBeClose);
        inClose = toBeClose;
      }
    }();

  }

  @override
  void exit() {
    settingMethodChannel.setScreenClose(false);
  }

}