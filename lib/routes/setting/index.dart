import 'package:flutter/material.dart';

export 'about_setting.dart';
export 'ai_setting.dart';
export 'display_setting.dart';
export 'net_setting.dart';
export 'sound_setting.dart';
export 'standby_time_choice.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
                  const Text("系统设置",
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => {
                    Navigator.pushNamed(
                      context,
                      'NetSettingPage',
                    )
                  },
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 53, 0, 0),
                      width: 96,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0x00000000),
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Image.asset(
                            "assets/imgs/setting/wangluo.png",
                            width: 60,
                            height: 60,
                          ),
                          const Text("网络设置",
                              style: TextStyle(
                                color: Color(0XFF8e8e8e),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.pushNamed(
                      context,
                      'DisplaySettingPage',
                    )
                  },
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 53, 0, 0),
                      width: 96,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0x00000000),
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Image.asset(
                            "assets/imgs/setting/xianshi.png",
                            width: 60,
                            height: 60,
                          ),
                          const Text("显示设置",
                              style: TextStyle(
                                color: Color(0XFF8e8e8e),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.pushNamed(
                      context,
                      'SoundSettingPage',
                    )
                  },
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 53, 0, 0),
                      width: 96,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0x00000000),
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Image.asset(
                            "assets/imgs/setting/shengyin.png",
                            width: 60,
                            height: 60,
                          ),
                          const Text("声音设置",
                              style: TextStyle(
                                color: Color(0XFF8e8e8e),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => {
                    Navigator.pushNamed(
                      context,
                      'AiSettingPage',
                    )
                  },
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 73, 0, 0),
                      width: 96,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0x00000000),
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Image.asset(
                            "assets/imgs/setting/yuyinshezhi.png",
                            width: 60,
                            height: 60,
                          ),
                          const Text("小美语音",
                              style: TextStyle(
                                color: Color(0XFF8e8e8e),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () => {Navigator.pushNamed(
                    context,
                    'AboutSettingPage',
                  )},
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 73, 0, 0),
                      width: 96,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: const Color(0x00000000),
                      ),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        children: [
                          Image.asset(
                            "assets/imgs/setting/benji.png",
                            width: 60,
                            height: 60,
                          ),
                          const Text("关于本机",
                              style: TextStyle(
                                color: Color(0XFF8e8e8e),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
                Visibility(
                  //占位而已
                  visible: false,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: GestureDetector(
                    onTap: () => {},
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 73, 0, 0),
                        width: 96,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: const Color(0x00000000),
                        ),
                        child: Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          children: [
                            Image.asset(
                              "assets/imgs/setting/shengyin.png",
                              width: 60,
                              height: 60,
                            ),
                            const Text("声音设置",
                                style: TextStyle(
                                  color: Color(0XFF8e8e8e),
                                  fontSize: 18.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(SettingPage oldWidget) {
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
