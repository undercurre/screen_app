
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/channel/index.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_bg_clock.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_hand_clock.dart';
import 'package:screen_app/routes/setting/screen_saver/screen_saver_help.dart';
import 'package:screen_app/routes/weather/index.dart';

import '../../../common/setting.dart';
import '../../../main.dart';
import '../../../states/standby_notifier.dart';

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

/// 特殊的待机屏保
class SpecialBlackBgSaverScreen extends StatefulWidget {

  const SpecialBlackBgSaverScreen({super.key});


  @override
  State<StatefulWidget> createState() => SpecialBlackBgSaverScreenState();

}

class SpecialBlackBgSaverScreenState extends State<SpecialBlackBgSaverScreen> with AiWakeUPScreenSaverState {
  late Timer _timer;
  late bool inClose;

  @override
  void initState() {
    super.initState();

    settingMethodChannel.setScreenClose(true);
    inClose = true;

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {

      bool toBeClose = Setting.instant().isStandByDuration();
      if(inClose != toBeClose) {
        if(toBeClose == false) {
          settingMethodChannel.setScreenClose(false);
          Navigator.pop(context);
        } else {
          settingMethodChannel.setScreenClose(true);
        }
        inClose = toBeClose;
      }
    });

  }
  @override
  void deactivate() {
    Provider.of<StandbyChangeNotifier>(context, listen: false).standbyPageActive = false;
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    settingMethodChannel.setScreenClose(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

}