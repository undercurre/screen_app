import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiSettingPage extends StatefulWidget {
  const AiSettingPage({Key? key});

  @override
  _AiSettingPageState createState() => _AiSettingPageState();
}

class _AiSettingPageState extends State<AiSettingPage> {
  late double po;
  bool AiEnable = true;

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
                  const Text("小美语音",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                  child: const Text("语音控制",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
                  child: CupertinoSwitch(
                    value: AiEnable,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      setState(() {
                        AiEnable = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                  child: const Text("唤醒词",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
                  child: const Text("小美小美",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ),
              ],
            ),
            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                  child: const Text("小美语音授权",
                      style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: 24.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ),
                GestureDetector(
                  onTap: () => {

                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                    margin: const EdgeInsets.fromLTRB(0, 18, 20, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      color: const Color(0x2f0091FF),
                      border: const Border(
                        top: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                        left: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                        right: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                        bottom: BorderSide(width: 1.0, color: Color(0xff0091FF)),
                      ),
                    ),
                    child: const Text("授权",
                        style: TextStyle(
                          color: Color(0XFFFFFFFF),
                          fontSize: 22.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                  ),
                ),
              ],
            ),
            Container(
              width: 464,
              height: 1,
              margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
              decoration: const BoxDecoration(
                color: Color(0xff232323),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(28, 18, 25, 0),
              child: const Text("注:开启语音控制后，可语音唤醒小美AI；关闭时不能通过语音唤醒，仅支持首页语音图标手动唤醒。开启静音模式后，所有有关声音全部关闭。",
                  style: TextStyle(
                    color: Color(0XFF8e8e8e),
                    fontSize: 14.0,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  )),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(AiSettingPage oldWidget) {
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
