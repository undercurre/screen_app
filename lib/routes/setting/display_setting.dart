import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/AdvancedSeekBar.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({Key? key});

  @override
  _DisplaySettingPageState createState() => _DisplaySettingPageState();
}

class _DisplaySettingPageState extends State<DisplaySettingPage> {
  late double po;
  bool autoLight = true;
  bool nearWakeup = true;


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
            Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("自动亮度",
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
                          value: autoLight,
                          activeColor: Colors.blue,
                          onChanged: (bool value) {
                            setState(() {
                              autoLight = value;
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
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: IconButton(
                          onPressed: () {},
                          iconSize: 80.0,
                          icon: Image.asset(
                            "assets/imgs/setting/liangdu.png",
                          ),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: 320,
                          child: AdvancedSeekBar(
                            const Color(0xff232323),
                            7,
                            lineHeight: 15,
                            Colors.blue,
                            fillProgress: true,
                            seekBarStarted: () {
                              setState(() {});
                            },
                            seekBarProgress: (v) {
                              setState(() {});
                            },
                            seekBarFinished: (v) {
                              setState(() {});
                            },
                          )),
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: IconButton(
                          onPressed: () {},
                          iconSize: 80.0,
                          icon: Image.asset(
                            "assets/imgs/setting/liangdu01.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 464,
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xff232323),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                    child: const Text('开启自动亮度后，屏幕亮度会根据环境亮度自适应，当手动调节亮度的时候会关闭自动亮度。',
                        style: TextStyle(
                          color: Color(0XFF979797),
                          fontSize: 14.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  Container(
                    width: 464,
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xff232323),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("靠近唤醒",
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
                          value: nearWakeup,
                          activeColor: Colors.blue,
                          onChanged: (bool value) {
                            setState(() {
                              nearWakeup = value;
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
                  Container(
                    margin: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                    child: const Text('当人靠近距离50cm时，从待机状态进入到首页状态。                     ',
                        style: TextStyle(
                          color: Color(0XFF979797),
                          fontSize: 14.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  Container(
                    width: 464,
                    height: 1,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xff232323),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                        child: const Text("待机设置",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                            child: const Text("30s 后",
                                style: TextStyle(
                                  color: Color(0XFF0091FF),
                                  fontSize: 18.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                          ),

                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 18, 10, 0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  'StandbyTimeChoicePage',
                                );
                              },
                              iconSize: 20.0,
                              icon: Image.asset(
                                "assets/imgs/icon/arrow-right.png",
                              ),
                            ),
                          ),

                        ],
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
                        child: const Text("待机样式",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(28, 18, 0, 0),
                            child: const Text("表盘1",
                                style: TextStyle(
                                  color: Color(0XFF0091FF),
                                  fontSize: 18.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                          ),

                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 18, 10, 0),
                            child: IconButton(
                              onPressed: () {},
                              iconSize: 20.0,
                              icon: Image.asset(
                                "assets/imgs/icon/arrow-right.png",
                              ),
                            ),
                          ),

                        ],
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
                        margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
                        child: const Text("息屏时间段",
                            style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 24.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
                            child: const Text("20:00-08：00",
                                style: TextStyle(
                                  color: Color(0XFF0091FF),
                                  fontSize: 18.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                          ),

                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 18, 10, 18),
                            child: IconButton(
                              onPressed: () {},
                              iconSize: 20.0,
                              icon: Image.asset(
                                "assets/imgs/icon/arrow-right.png",
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
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
