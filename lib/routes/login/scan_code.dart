import 'package:flutter/material.dart';

class _ScanCode extends State<ScanCode> {
  bool wifi = true;

  @override
  Widget build(BuildContext context) {
    const stepNum = Positioned(
      top: 10,
      left: -15,
      child: Text(
        '02',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.white24,
          fontSize: 60.0,
          height: 1,
          fontFamily: "MideaType-Bold",
          decoration: TextDecoration.none,
        ),
      ),
    );

    const title = Padding(
        padding: EdgeInsets.fromLTRB(0, 18, 0, 6),
        child: Text(
          '扫码登录',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white24,
            fontSize: 26.0,
            height: 1,
            fontFamily: "MideaType-Bold",
            decoration: TextDecoration.none,
          ),
        ));

    var stepBar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Image(
          image: AssetImage("assets/imgs/scanCode/step-finished.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-active.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-active.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/line-passive.png"),
        ),
        Image(
          image: AssetImage("assets/imgs/scanCode/step-passive.png"),
        ),
      ],
    );

    var header = DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imgs/scanCode/header-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [title, stepBar],
        ));

    return Center(
        child: Container(
      width: 490,
      decoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: Colors.white,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
              children: [header, stepNum]),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
              padding: const EdgeInsets.all(20.0),
              textStyle: const TextStyle(fontSize: 17, color: Color.fromRGBO(1, 255, 255, 0.85)),
            ),
            onPressed: () {
              Navigator.pop(context, '返回值');
            },
            child: const Text('上一步', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.85),)),
          ),
        ],
      ),
    ));
  }
}

class ScanCode extends StatefulWidget {
  const ScanCode({super.key});

  @override
  State<ScanCode> createState() => _ScanCode();
}
