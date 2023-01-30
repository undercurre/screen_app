import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../channel/index.dart';
import '../../common/helper.dart';
import '../../common/setting.dart';
import '../../states/standby_notifier.dart';
import '../../widgets/mz_slider.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({super.key});

  @override
  DisplaySettingPageState createState() => DisplaySettingPageState();
}

class DisplaySettingPageState extends State<DisplaySettingPage> {
  late double po;
  bool autoLight = true;
  bool nearWakeup = true;
  num lightValue = 0;
  String duration = '';

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("initState");
    initial();

  }

  initial() async {
    setState(() {
      duration = Setting.instant().getScreedDurationDetail();
    });
    lightValue = await settingMethodChannel.getSystemLight();
    autoLight = await settingMethodChannel.getAutoLight();
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
            Expanded(
                child: ListView(
              scrollDirection: Axis.vertical,
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
                          settingMethodChannel.setAutoLight(autoLight);
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
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.fromLTRB(15, 9, 0, 9),
                      child: IconButton(
                        onPressed: () {},
                        iconSize: 40.0,
                        icon: Image.asset(
                          "assets/imgs/setting/liangdu01.png",
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 9, 0, 9),
                      width: 320,
                      child: MzSlider(
                        width: 320,
                        value: lightValue,
                        activeColors: const [
                          Color(0xFF267AFF),
                          Color(0xFF267AFF)
                        ],
                        onChanging: (value, actieColor) => {
                          settingMethodChannel.setSystemLight(value),
                          lightValue = value,
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.fromLTRB(0, 9, 15, 9),
                      child: IconButton(
                        onPressed: () {},
                        iconSize: 40.0,
                        icon: Image.asset(
                          "assets/imgs/setting/liangdu.png",
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
                  child: const Text(
                      '当人靠近距离50cm时，从待机状态进入到首页状态。                     ',
                      style: TextStyle(
                        color: Color(0XFF979797),
                        fontSize: 14.0,
                        fontFamily: "MideaType",
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      )),
                ),
                Consumer<StandbyChangeNotifier>(
                    builder: (_, model, child) {
                      return settingItem(
                          "待机设置",
                          model.standbyTimeOpt.title, () {
                        Navigator.pushNamed(
                          context,
                          'StandbyTimeChoicePage',
                        );
                      });
                    }),
                const Divider(height: 1, indent: 0 , endIndent: 0, color: Color(0xff232323)),
                settingItem("待机样式", "表盘1", () { }),
                const Divider(height: 1, indent: 0, endIndent: 0, color: Color(0xff232323)),
                settingItem("息屏时间段", duration, () {
                  Navigator.of(context)
                      .pushNamed("SelectTimeDurationPage")
                      .then((value) {
                        final result = value as Pair<int, int>;
                        final startTime = result.value1;
                        final endTime = result.value2;
                        debugPrint("开始时间：$startTime 结束时间: $endTime");
                        Setting.instant().setScreedDuration(result);
                        setState(() {
                          duration = Setting.instant().getScreedDurationDetail();
                        });
                      }
                  );
                })
              ],
            ))
          ],
        ),
      )),
    );
  }


  Widget settingItem(String name, String value, GestureTapCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(28, 18, 0, 18),
            child: Text(name,
                style: const TextStyle(
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
                child: Text(value,
                    style: const TextStyle(
                      color: Color(0XFF0091FF),
                      fontSize: 18.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 18, 10, 18),
                child: Image.asset(
                  "assets/imgs/icon/arrow-right.png",
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
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
