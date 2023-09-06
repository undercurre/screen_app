
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/setting.dart';
import '../../states/standby_notifier.dart';
import '../../widgets/mz_cell.dart';
import '../../widgets/mz_switch.dart';

class StandbySettingPage extends StatefulWidget {
  const StandbySettingPage({super.key});

  @override
  StandbySettingPageState createState() => StandbySettingPageState();
}

class StandbySettingPageState extends State<StandbySettingPage> {
  late bool isEnable;
  late int screenSaverId;

  @override
  void initState() {
    super.initState();
    screenSaverId = Setting.instant().screenSaverId;
    isEnable = !Setting.instant().screenSaverReplaceToOff;
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
                    const Text("待机设置",
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
                height: 72,
                width: 432,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                    color: const Color(0x19FFFFFF),
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Consumer<StandbyChangeNotifier>(builder: (_, model, child) {
                  return MzCell(
                    title: "待机时间",
                    titleSize: 24,
                    hasArrow: true,
                    rightText: model.standbyTimeOpt.title,
                    rightTextColor: const Color(0x99FFFFFF),
                    bgColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    onTap: () {
                      Navigator.pushNamed(context, 'StandbyTimeChoicePage');
                    },
                  );
                }),
              ),

              Container(
                height: 105,
                width: 432,
                margin: const EdgeInsets.only(top: 18),
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
                      title: "待机屏保",
                      titleSize: 24,
                      bgColor: Colors.transparent,
                      padding: const EdgeInsets.all(0),
                      rightSlot: MzSwitch(
                        value: isEnable,
                        onTap: (e) {
                          setState(() {
                            isEnable = e;
                          });
                          Setting.instant().screenSaverReplaceToOff = !e;
                          Provider.of<StandbyChangeNotifier>(context, listen: false).setTimerByNum = Setting.instant().standbyTimeOptNum;
                        },
                      ),
                    ),

                    const Text("关闭时，进入待机后则自动熄屏",
                        style: TextStyle(
                            color: Color(0X6CFFFFFF),
                            fontSize: 16,
                            height: 1,
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
                  title: "待机样式",
                  titleSize: 24,
                  hasArrow: true,
                  rightText: parseScreenSaverName(screenSaverId),
                  rightTextColor: const Color(0x99FFFFFF),
                  bgColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  onTap: () {
                    Navigator.of(context).pushNamed('SelectStandbyStylePage').then((value) {
                      if (value != null) {
                        setState(() {
                          screenSaverId = value as int;
                        });
                      }
                    });
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  String parseScreenSaverName(int index) {
    if(index < 3) {
      return '时钟${index + 1}';
    } else if(index < 6) {
      return '星空${index - 3 + 1}';
    } else {
      return '自然${index - 6 + 1}';
    }
  }

  @override
  void didUpdateWidget(StandbySettingPage oldWidget) {
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

