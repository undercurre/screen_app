import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutSettingPage extends StatefulWidget {
  const AboutSettingPage({Key? key});

  @override
  _AboutSettingPageState createState() => _AboutSettingPageState();
}

class _AboutSettingPageState extends State<AboutSettingPage> {
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
                  const Text("关于本机",
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
            Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("设备名称",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("Msmart-P4",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("所在家庭",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("佛山",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("系统版本",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("04260117",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("MAC地址",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("f2b0406b43f8",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("IP地址",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("192.168.1.254",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("SN码",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                        child: const Text("3182225902588853220333",
                            style: TextStyle(
                              color: Color(0X7fFFFFFF),
                              fontSize: 18.0,
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
                        child: const Text("应用升级",
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
                          child: const Text("检查更新",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("重启系统",
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
                          child: const Text("重启",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("清除用户数据",
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
                            color: const Color(0x2fFF1B12),
                            border: const Border(
                              top: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                              left: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                              right: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                              bottom: BorderSide(width: 1.0, color: Color(0xffFF1B12)),
                            ),
                          ),
                          child: const Text("清除",
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

                ],
              ),
            ))
          ],
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(AboutSettingPage oldWidget) {
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
