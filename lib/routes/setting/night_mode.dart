
import 'package:flutter/material.dart';

import '../../common/helper.dart';
import '../../common/setting.dart';
import '../../widgets/mz_cell.dart';
import '../../widgets/mz_switch.dart';

class NightModePage extends StatefulWidget {
  const NightModePage({super.key});

  @override
  NightModePageState createState() => NightModePageState();
}

class NightModePageState extends State<NightModePage> {
  String duration = '';
  bool isEnable = false;

  @override
  void initState() {
    super.initState();
    duration = Setting.instant().getScreedDurationDetail();
    isEnable = Setting.instant().nightModeEnable;
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    const Text("夜间模式",
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
                height: 129,
                width: 432,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                  color: const Color(0x19FFFFFF),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MzCell(
                      title: "夜间模式",
                      titleSize: 24,
                      bgColor: Colors.transparent,
                      padding: const EdgeInsets.all(0),
                      rightSlot: MzSwitch(
                        value: isEnable,
                        onTap: (e) {
                          // Setting.instant().nightModeEnable = e;
                          // if(e == false) {
                          //   /// 暂时逻辑，关闭开关就清除设置时间段
                          //   Setting.instant().setScreedDuration(Pair.of(23, 7));
                          // }
                          setState(() {
                            isEnable = e;
                            duration = Setting.instant().getScreedDurationDetail();
                          });
                        },
                      ),
                    ),

                    const Text("处于“夜间模式”，将自动熄屏同时关闭除告\n警消息以外的其它声音。",
                        style: TextStyle(
                            color: Color(0X6CFFFFFF),
                            fontSize: 16,
                            height: 1.4,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none)
                    )
                  ],
                ),
              ),

              if(isEnable) Container(
                height: 72,
                width: 432,
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                    color: const Color(0x19FFFFFF),
                    borderRadius: BorderRadius.circular(16)
                ),
                child: MzCell(
                  title: "设置时间段",
                  titleSize: 24,
                  hasArrow: true,
                  rightText: duration,
                  rightTextColor: const Color(0x99FFFFFF),
                  bgColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  onTap: () {
                    Navigator.of(context).pushNamed("SelectTimeDurationPage").then((value) {
                      setState(() {
                        duration = Setting.instant().getScreedDurationDetail();
                      });
                    });
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(NightModePage oldWidget) {
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

