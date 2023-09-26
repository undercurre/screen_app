import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';
import '../../channel/index.dart';
import '../../common/gateway_platform.dart';
import '../../common/setting.dart';

class HomluxAiSettingPage extends StatefulWidget {
  const HomluxAiSettingPage({Key? key});

  @override
  _HomluxAiSettingPage createState() => _HomluxAiSettingPage();
}

class _HomluxAiSettingPage extends State<HomluxAiSettingPage> {
  late double po;
  bool AiEnable = Setting.instant().homluxAiEnable;

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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF272F41),
                Color(0xFF080C14),
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 480,
                height: 84,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTapDown: (e) {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/newUI/back.png",
                      ),
                    ),
                    const Text("语音设置",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.85),
                            fontSize: 28,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)),
                    GestureDetector(
                      onTapDown: (e) {
                        Navigator.popUntil(
                            context, (route) => route.settings.name == 'Home');
                      },
                      child: Image.asset(
                        "assets/newUI/back_home.png",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 432,
                        height: 72,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.05),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("语音控制",
                                style: TextStyle(
                                  color: Color(0XFFFFFFFF),
                                  fontSize: 24.0,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                            MzSwitch(
                              value: AiEnable,
                              onTap: (bool value) {
                                Setting.instant().homluxAiEnable = value;
                                aiMethodChannel.enableAi(value);
                                setState(() {
                                  AiEnable = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 432,
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.05),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 432,
                                height: 72,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("唤醒词",
                                        style: TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    Text("小美小美",
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.60),
                                          fontSize: 20.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ],
                                ),
                              ),
                              if (MideaRuntimePlatform.platform.inMeiju())
                                Container(
                                  width: 392,
                                  height: 1,
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.05),
                                ),
                            ],
                          )),
                      Container(
                          width: 432,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.05),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 392,
                                height: 0,
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.05),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(HomluxAiSettingPage oldWidget) {
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
