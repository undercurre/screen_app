import 'package:flutter/material.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_bg_clock.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_hand_clock.dart';
import 'package:screen_app/routes/weather/index.dart';

import '../../../common/setting.dart';

class ScreenSaver extends StatelessWidget {
  const ScreenSaver({super.key});

  /// 获取所有的屏保页
  static List<Widget> getAll() {
    return const <Widget>[
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
class ScreenSaverHandClock1 extends ScreenSaverHandClock {

  const ScreenSaverHandClock1({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_1_disc.png",
          imgSecond: "assets/imgs/setting/hand_clock_3_second.png",
          imgMinute: "assets/imgs/setting/hand_clock_1_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_1_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_1_point.png");

}

/// 指针时钟二
class ScreenSaverHandClock2 extends ScreenSaverHandClock {

  const ScreenSaverHandClock2({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_2_disc.png",
          imgSecond: "assets/imgs/setting/hand_clock_2_second.png",
          imgMinute: "assets/imgs/setting/hand_clock_2_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_2_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_2_point.png",
          imgBackground: "assets/imgs/setting/hand_clock_2_bg.png",
          secondDistance: 100
      );

}

/// 指针时钟三
class ScreenSaverHandClock3 extends ScreenSaverHandClock {

  const ScreenSaverHandClock3({super.key});

  @override
  HandClockConfig buildConfig() =>
      HandClockConfig(
          imgDisc: "assets/imgs/setting/hand_clock_3_disc.png",
          imgMinute: "assets/imgs/setting/hand_clock_3_minute.png",
          imgHour: "assets/imgs/setting/hand_clock_3_hour.png",
          imgPoint: "assets/imgs/setting/hand_clock_3_point.png");

}

/// 背景时钟四
class ScreenSaverBgClock4 extends ScreenSaverBgClock {
  const ScreenSaverBgClock4({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
    'assets/imgs/setting/hand_clock_4_bg.png',
    Colors.white
  );

}

/// 背景时钟五
class ScreenSaverBgClock5 extends ScreenSaverBgClock {
  const ScreenSaverBgClock5({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_5_bg.png',
      Colors.white
  );

}

/// 背景时钟六
class ScreenSaverBgClock6 extends ScreenSaverBgClock {
  const ScreenSaverBgClock6({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_6_bg.png',
      Colors.white
  );

}

/// 天气时钟七
/// [WeatherPage]

/// 背景时钟八
class ScreenSaverBgClock8 extends ScreenSaverBgClock {
  const ScreenSaverBgClock8({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_8_bg.png',
      Colors.black
  );

}

/// 背景时钟九
class ScreenSaverBgClock9 extends ScreenSaverBgClock {
  const ScreenSaverBgClock9({super.key});

  @override
  ScreenSaverBgClockConfig buildConfig() => ScreenSaverBgClockConfig(
      'assets/imgs/setting/hand_clock_9_bg.png',
      Colors.white
  );

}