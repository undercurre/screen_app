import 'package:flutter/material.dart';
import '../../common/api/index.dart';
import 'link_network.dart';
import 'scan_code.dart';

class Step {
  String title;
  Widget view;

  Step(this.title, this.view);
}

class _LoginPage extends State<LoginPage> {
  bool wifi = true;

  /// 当前步骤，1-4
  var stepNum = 1;
  var stepList = [
    Step('连接网络', const LinkNetwork()),
    Step('扫码登录', const ScanCode()),
    Step('选择家庭', const LinkNetwork()),
    Step('选择房间', const LinkNetwork()),
  ];

  get stepItem => stepList[stepNum - 1];

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
    if (stepNum == 2) {
      IotApi.getHomeList();
    }

    if (stepNum == 4) {
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
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginHeader(
            stepSum: stepList.length, stepNum: stepNum, title: stepItem.title),
        Expanded(flex: 1, child: stepItem.view),
        Row(children: [
          Expanded(
              child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              padding: const EdgeInsets.all(20.0),
              textStyle: const TextStyle(
                  fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
            ),
            onPressed: () async {
              prevStep();
            },
            child: const Text('上一步',
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                )),
          )),
          Expanded(
              child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              padding: const EdgeInsets.all(20.0),
              textStyle: const TextStyle(
                  fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
            ),
            onPressed: () async {
              nextStep();
              //导航到新路由
              // var result = await Navigator.pushNamed(
              //   context,
              //   'ScanCode',
              // );
            },
            child: const Text('下一步',
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                )),
          ))
        ])
      ],
    ));
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
          fontFamily: "MideaType-Bold",
          decoration: TextDecoration.none,
        ),
      ),
    );

    var titleView = Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 26.0,
            height: 1,
            fontFamily: "MideaType-Bold",
            decoration: TextDecoration.none,
          )
        ),
    );

    const stepActiveImg =
        Image(image: AssetImage("assets/imgs/scanCode/step-active.png"));
    const stepFinishedImg =
        Image(image: AssetImage("assets/imgs/scanCode/step-finished.png"));
    const stepPassiveImg =
        Image(image: AssetImage("assets/imgs/scanCode/step-passive.png"));
    const lineActiveImg =
        Image(image: AssetImage("assets/imgs/scanCode/line-active.png"));
    const linePassiveImg =
        Image(image: AssetImage("assets/imgs/scanCode/line-active.png"));

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

    var tempIcon = TextButton.icon(
      onPressed: () => {
        Navigator.of(context).pushNamed('Weather')
      },
      label: const Text(''),
      icon: const Icon(Icons.sunny_snowing),
    );

    var headerView = DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/scanCode/header-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [titleView, stepBarView],
        ));

    return Stack(alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
        children: [headerView, stepNumView, Positioned(
          right: 18.0,
          top: 18.0,
          child: tempIcon,
        )]);
  }
}
