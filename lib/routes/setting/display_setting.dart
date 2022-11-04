import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({Key? key});

  @override
  _DisplaySettingPageState createState() => _DisplaySettingPageState();
}

class _DisplaySettingPageState extends State<DisplaySettingPage> {
  late double po;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("initState");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        width: 480,
        height: 480,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 480,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 60.0,
                    icon: Image.asset(
                      "assets/imgs/setting/fanhui.png",
                    ),
                  ),
                  const Text("显示设置",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 30.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        'Home',
                      );
                    },
                    iconSize: 60.0,
                    icon: Image.asset(
                      "assets/imgs/setting/zhuye.png",
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 480,
              height: 1,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(DisplaySettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }
}
