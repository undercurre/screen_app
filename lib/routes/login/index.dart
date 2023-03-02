import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/index.dart';

import '../../common/index.dart';
import '../../widgets/business/net_connect.dart';
import '../../widgets/business/select_home.dart';
import '../../widgets/business/select_room.dart';
import '../../widgets/util/net_utils.dart';
import 'scan_code.dart';


class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> with WidgetNetState {
  /// 当前步骤，1-4
  var stepNum = 1;

  /// 上一步
  void prevStep() {
    if (stepNum == 1) {
      return;
    }
    if (stepNum == 3) {
      Global.profile.homeInfo = null;
    }
    if (stepNum == 4) {
      Global.profile.roomInfo = null;
    }
    setState(() {
      --stepNum;
    });
  }

  /// 下一步
  void nextStep() async {
    if (Platform.isAndroid && stepNum == 1 && !isConnected()) {
      TipsUtils.toast(content: '请连接网络');
      return;
    }

    if (stepNum == 3) {
      if(Global.profile.homeInfo == null) {
        // 必须选择家庭信息才能进行下一步
        TipsUtils.toast(content: '请选择家庭');
        return;
      }
    }

    if (stepNum == 4) {
      // 必须选择房间信息才能进行下一步
      if (Global.profile.roomInfo == null) {
        TipsUtils.toast(content: '请选择房间');
        return;
      }
      // todo: linux运行屏蔽，push前解放

      if (Platform.isLinux) {
        // 运行在 Linux 平台上
      } else {
        // 运行在其他平台上
        var bindRes = await UserApi.bindHome(
            sn: Global.profile.deviceSn ?? Global.profile.deviceId ?? '',
            applianceType: '0x16');

        if (!bindRes.isSuccess) {
          TipsUtils.toast(content: '绑定家庭失败');
          return;
        }
      }

      Global.saveProfile();
      //导航到新路由
      if (mounted) {
        Navigator.popAndPushNamed(context, 'Home');
        Push.sseInit();
      }
      return;
    }
    setState(() {
      ++stepNum;
    });
  }

  @override
  void initState() {
    super.initState();

    // 初始化
    if (Global.isLogin) {
      stepNum = 3;
    } else if (Platform.isAndroid && isConnected()) {
      stepNum = 2;
    }
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
            ])
          ],
        )));
  }

  @override
  void netChange(MZNetState? state) {
    debugPrint('netChange: $state');
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
        Image(image: AssetImage("assets/imgs/login/line-passive.png"));

    var stepList = <Widget>[];

    for (var i = 1; i <= stepSum; i++) {
      if (stepNum >= i && i > 1) {
        stepList.add(lineActiveImg);
      } else if (stepNum < i && i > 1) {
        stepList.add(linePassiveImg);
      } else {

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
        children: [headerView, stepNumView]);
  }
}
