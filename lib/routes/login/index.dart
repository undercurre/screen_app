import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_app/models/index.dart';

import '../../common/index.dart';
import 'link_network.dart';
import 'scan_code.dart';
import '../../widgets/business/select_home.dart';
import '../../widgets/business/select_room.dart';
import '../../mixins/index.dart';

class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> with Standby {
  /// 当前步骤，1-4
  var stepNum = Global.isLogin ? 3 : 1;

  /// 上一步
  void prevStep() {
    if (stepNum == 1) {
      return;
    }
    setState(() {
      --stepNum;
    });
  }

  /// 下一步
  void nextStep() async {
    if (stepNum == 4 && Global.profile.roomInfo != null) {
      Global.saveProfile();
      //导航到新路由
      await Navigator.pushNamed(
        context,
        'Home',
      );
      return;
    }
    setState(() {
      ++stepNum;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var stepList = [
      Step('连接网络', const LinkNetwork()),
      Step('扫码登录', ScanCode(onSuccess: nextStep)),
      Step(
          '选择家庭',
          SelectHome(
              value: Global.profile.homeInfo?.homegroupId ?? '',
              onChange: (HomeEntity home) {
                debugPrint('Select: ${home.toJson()}');
                Global.profile.homeInfo = home;
              })),
      Step(
          '选择房间',
          SelectRoom(
              value: Global.profile.roomInfo?.roomId ?? '',
              onChange: (RoomEntity room) {
                debugPrint('SelectRoom: ${room.toJson()}');
                Global.profile.roomInfo = room;
              })),
    ];

    var stepItem = stepList[stepNum - 1];

    var buttonStyle = TextButton.styleFrom(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.all(20.0),
      textStyle: const TextStyle(
          fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
    );

    return DecoratedBox(
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1)),
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginHeader(
                stepSum: stepList.length,
                stepNum: stepNum,
                title: stepItem.title),
            Expanded(flex: 1, child: stepItem.view),
            Row(children: [
              if (stepNum > 1)
                Expanded(
                    child: TextButton(
                  style: buttonStyle,
                  onPressed: () async {
                    prevStep();
                  },
                  child: const Text('上一步',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.85),
                      )),
                )),
              if (stepNum > 2)
                const SizedBox(
                  width: 4,
                ),
              if (stepNum != 2)
                Expanded(
                    child: TextButton(
                  style: buttonStyle,
                  onPressed: () async {
                    nextStep();
                  },
                  child: stepNum == 4
                      ? const Text('完成',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 145, 255, 1),
                          ))
                      : const Text('下一步',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.85),
                          )),
                )),
              Expanded(
                  child: TextButton(
                style: buttonStyle,
                onPressed: () async {
                  System.loginOut();
                  setState(() {
                    stepNum = 2;
                  });
                },
                child: const Text('注销(测试）',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                    )),
              )),
              Expanded(
                  child: TextButton(
                style: buttonStyle,
                onPressed: () async {
                  exit(0);
                },
                child: const Text('退出(测试）',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                    )),
              )),
            ])
          ],
        )));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class LoginHeader extends StatelessWidget {
  /// 当前索引
  final int stepNum;

  /// 步骤总数
  final int stepSum;

  /// 标题
  final String title;

  const LoginHeader(
      {super.key,
      required this.stepSum,
      required this.stepNum,
      required this.title});

  @override
  Widget build(BuildContext context) {
    var stepNumView = Positioned(
      top: 10,
      left: -15,
      child: Text(
        stepNum.toString().padLeft(2, '0'),
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 60.0,
          height: 1,
          fontFamily: "MideaType",
          decoration: TextDecoration.none,
        ),
      ),
    );

    var titleView = Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
      child: Text(title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 26.0,
            height: 1,
            fontFamily: "MideaType",
            decoration: TextDecoration.none,
          )),
    );

    const stepActiveImg =
        Image(image: AssetImage("assets/imgs/login/step-active.png"));
    const stepFinishedImg =
        Image(image: AssetImage("assets/imgs/login/step-finished.png"));
    const stepPassiveImg =
        Image(image: AssetImage("assets/imgs/login/step-passive.png"));
    const lineActiveImg =
        Image(image: AssetImage("assets/imgs/login/line-active.png"));
    const linePassiveImg =
        Image(image: AssetImage("assets/imgs/login/line-active.png"));

    var stepList = <Widget>[];

    for (var i = 1; i <= stepSum; i++) {
      if (stepNum >= i && i > 1) {
        stepList.add(lineActiveImg);
      } else if (stepNum < i && i > 1) {
        stepList.add(linePassiveImg);
      }

      if (stepNum > i) {
        stepList.add(stepFinishedImg);
      } else if (stepNum == i) {
        stepList.add(stepActiveImg);
      } else {
        stepList.add(stepPassiveImg);
      }
    }
    var stepBarView = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stepList,
    );

    var tempIcon = Positioned(
      left: 100.0,
      top: 2.0,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pushNamed('SettingPage'),
        label: const Text(''),
        icon: const Icon(Icons.settings),
      ),
    );
    // var tempIcon = Positioned(
    //   left: 100.0,
    //   top: 2.0,
    //   child: TextButton.icon(
    //     onPressed: () => exit(0),
    //     label: const Text(''),
    //     icon: const Icon(Icons.exit_to_app),
    //   ),
    // );

    var headerView = DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/login/header-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [titleView, stepBarView],
        ));

    return Stack(alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
        children: [headerView, stepNumView, tempIcon]);
  }
}
