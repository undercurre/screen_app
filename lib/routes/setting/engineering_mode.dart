
import 'package:flutter/material.dart';

import '../../widgets/mz_switch.dart';

class EngineeringModePage extends StatefulWidget {
  const EngineeringModePage({super.key});

  @override
  EngineeringModePageState createState() => EngineeringModePageState();
}

class EngineeringModePageState extends State<EngineeringModePage> {
  bool isModeOn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 480,
          height: 480,
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
                    const Text("工程模式",
                        style: TextStyle(
                            color: Color(0XD8FFFFFF),
                            fontSize: 28,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.settings.name == 'Home');
                      },
                      iconSize: 64,
                      icon: Image.asset(
                        "assets/newUI/back_home.png",
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 416,
                height: 340,
                decoration: BoxDecoration(
                  color: const Color(0xAA7F7F7F),
                  border: Border.all(color: const Color(0xFFDCDCDC), width: 2),
                  borderRadius: BorderRadius.circular(8)
                ),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 380,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("交付确认",
                              style: TextStyle(
                                color: Color(0xFFDCDCDC),
                                fontSize: 28.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                          MzSwitch(
                            activeColor: const Color(0xFF3C92D6),
                            inactiveColor: const Color(0x33DCDCDC),
                            pointActiveColor: const Color(0xFFDCDCDC),
                            pointInactiveColor: const Color(0xFFDCDCDC),
                            value: isModeOn,
                            onTap: (e) {
                              setState(() {
                                isModeOn = !isModeOn;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 380,
                      color: const Color(0xFFDCDCDC),
                      margin: const EdgeInsets.only(bottom: 20),
                    ),

                    const Expanded(
                        child: SizedBox(
                          width: 380,
                          child: SingleChildScrollView(
                            child: Text("交付确认后\n"
                                "1：关闭OTA升级功能\n"
                                "2：关闭“清除用户数据”功能\n"
                                "3：关闭“退出登录”功能\n"
                                "4：关闭“添加设备”功能\n",
                                style: TextStyle(
                                  height: 1.6,
                                  color: Color(0xFFDCDCDC),
                                  fontSize: 22,
                                  fontFamily: "MideaType",
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.none,
                                )),
                          ),
                        )
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(EngineeringModePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

