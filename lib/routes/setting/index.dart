import 'package:flutter/material.dart';
import '../../common/global.dart';

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
            image: DecorationImage(
              image: ExactAssetImage('assets/newUI/bg.png'),
              fit: BoxFit.cover
            ),
          ),
          child: Column(
            children: [
              /// 标题栏
              SizedBox(
                width: 480,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 64,
                      icon: Image.asset(
                        "assets/newUI/back.png",
                      ),
                    ),
                    const Text("系统设置",
                        style: TextStyle(
                          color: Color(0XD8FFFFFF),
                          fontSize: 28,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none)
                    ),
                    const SizedBox(
                      width: 32,
                      height: 32,
                    ),
                  ],
                ),
              ),

              /// 用户信息栏
              GestureDetector(
                onTap: () => {
                  // Navigator.pushNamed(
                  //   context,
                  //   'DisplaySettingPage',
                  // )
                },
                child: Container(
                  width: 432,
                  height: 96,
                  decoration: const BoxDecoration(
                      color: Color(0x33FFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        left: 20,
                        top: 17,
                        child: CircleAvatar(
                          backgroundImage: AssetImage("assets/imgs/weather/icon-rainy.png"),
                          backgroundColor: Color(0x00FFFFFF),
                          radius: 30,
                        ),
                      ),
                      Positioned(
                        left: 97,
                        top: 9,
                        child: Text(Global.profile.homeInfo?.name ?? '--',
                            style: const TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 24,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)
                        ),
                      ),
                      const Positioned(
                        left: 97,
                        top: 53,
                        child: Text("家庭、账号、成员",
                            style: TextStyle(
                                color: Color(0X99FFFFFF),
                                fontSize: 18,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)
                        ),
                      ),
                      const Positioned(
                        right: 20,
                        top: 36,
                        child: Image(
                          width: 24,
                          height: 24,
                          image: AssetImage("assets/newUI/arrow_right.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 无线局域网
              GestureDetector(
                onTap: () => {
                  Navigator.pushNamed(
                    context,
                    'NetSettingPage',
                  )
                },
                child: Container(
                  width: 432,
                  height: 71,
                  margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  decoration: const BoxDecoration(
                      color: Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  child: const Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 17,
                        child: Image(
                          width: 36,
                          height: 36,
                          image: AssetImage("assets/newUI/WiFi_setting.png"),
                        ),
                      ),
                      Positioned(
                        left: 72,
                        top: 12,
                        child: Text("无线局域网",
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: 24,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none)
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 24,
                        child: Image(
                          width: 24,
                          height: 24,
                          image: AssetImage("assets/newUI/arrow_right.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 432,
                height: 200,
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                decoration: const BoxDecoration(
                    color: Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// 显示设置
                    GestureDetector(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          'DisplaySettingPage',
                        )
                      },
                      child: Container(
                        width: 432,
                        height: 65,
                        decoration: const BoxDecoration(
                          color: Color(0x00FFFFFF)
                        ),
                        child: const Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 17,
                              child: Image(
                                width: 36,
                                height: 36,
                                image: AssetImage("assets/newUI/display_setting.png"),
                              ),
                            ),
                            Positioned(
                              left: 72,
                              top: 8,
                              child: Text("显示设置",
                                  style: TextStyle(
                                      color: Color(0XFFFFFFFF),
                                      fontSize: 24,
                                      fontFamily: "MideaType",
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none)
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: Image(
                                width: 24,
                                height: 24,
                                image: AssetImage("assets/newUI/arrow_right.png"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: 392,
                      height: 1,
                      decoration: const BoxDecoration(
                        color: Color(0x19FFFFFF)
                      ),
                    ),

                    /// 音量设置
                    GestureDetector(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          'SoundSettingPage',
                        )
                      },
                      child: Container(
                        width: 432,
                        height: 65,
                        decoration: const BoxDecoration(
                            color: Color(0x00FFFFFF)
                        ),
                        child: const Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 17,
                              child: Image(
                                width: 36,
                                height: 36,
                                image: AssetImage("assets/newUI/volume_setting.png"),
                              ),
                            ),
                            Positioned(
                              left: 72,
                              top: 8,
                              child: Text("音量设置",
                                  style: TextStyle(
                                      color: Color(0XFFFFFFFF),
                                      fontSize: 24,
                                      fontFamily: "MideaType",
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none)
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: Image(
                                width: 24,
                                height: 24,
                                image: AssetImage("assets/newUI/arrow_right.png"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: 392,
                      height: 1,
                      decoration: const BoxDecoration(
                          color: Color(0x19FFFFFF)
                      ),
                    ),

                    /// 关于本机
                    GestureDetector(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          'AboutSettingPage',
                        )
                      },
                      child: Container(
                        width: 432,
                        height: 65,
                        decoration: const BoxDecoration(
                            color: Color(0x00FFFFFF)
                        ),
                        child: const Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 17,
                              child: Image(
                                width: 36,
                                height: 36,
                                image: AssetImage("assets/newUI/about.png"),
                              ),
                            ),
                            Positioned(
                              left: 72,
                              top: 8,
                              child: Text("关于本机",
                                  style: TextStyle(
                                      color: Color(0XFFFFFFFF),
                                      fontSize: 24,
                                      fontFamily: "MideaType",
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none)
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: Image(
                                width: 24,
                                height: 24,
                                image: AssetImage("assets/newUI/arrow_right.png"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
