import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../channel/index.dart';
import '../../common/global.dart';
import '../../common/helper.dart';
import '../../common/setting.dart';
import '../../states/standby_notifier.dart';
import '../../widgets/mz_switch.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({super.key});

  @override
  DisplaySettingPageState createState() => DisplaySettingPageState();
}

class DisplaySettingPageState extends State<DisplaySettingPage> {
  late double po;
  bool autoLight = Global.autoLight;
  bool nearWakeup = Global.nearWakeup;
  num lightValue = Global.lightValue;
  String duration = '';
  late int screenSaverId;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("initState");
    initial();
    screenSaverId = Setting.instant().screenSaverId;
  }

  initial() async {
    setState(() {
      duration = Setting.instant().getScreedDurationDetail();
    });
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
                    const Text("显示设置",
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
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      width: 432,
                      height: 72,
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 20,
                            top: 12,
                            child: Text("自动调节屏幕亮度",
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
                            child: MzSwitch(
                              value: autoLight,
                              onTap: (e) => onAutoLightClick(!autoLight),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 432,
                      height: 144,
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20,
                            top: 12,
                            child: Text("屏幕亮度 | ${(lightValue / 255 * 100).toInt()}%",
                                style: const TextStyle(
                                    color: Color(0XFFFFFFFF),
                                    fontSize: 24,
                                    fontFamily: "MideaType",
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none)
                            ),
                          ),
                          Positioned(
                            top: 72,
                            left: 20,
                            child: Container(
                              width: 392,
                              height: 1,
                              decoration: const BoxDecoration(
                                  color: Color(0x19FFFFFF)
                              ),
                            ),
                          ),

                          Positioned(
                            top: 80,
                            left: 0,
                            child: SizedBox(
                              width: 432,
                              height: 50,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: const Color(0xFF51555E),
                                  thumbColor: Colors.white,
                                  thumbShape: CustomThumbShape(12, Colors.white),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 255,
                                  value: lightValue.toDouble(),
                                  onChanged: (value) {
                                    num val = value.toInt();
                                    settingMethodChannel.setSystemLight(val);
                                    setState(() {
                                      lightValue = val;
                                      Global.lightValue = lightValue;
                                    });
                                  }),
                              )
                            )
                          )
                        ],
                      ),
                    ),

                    Container(
                      width: 432,
                      height: 72,
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 20,
                            top: 12,
                            child: Text("靠近唤醒",
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
                            child: MzSwitch(
                              value: nearWakeup,
                              onTap: (e) => onNearWakeupClick(!nearWakeup),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 432,
                      height: 218,
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Column(
                        children: [
                          Consumer<StandbyChangeNotifier>(builder: (_, model, child) {
                            return settingItem("待机设置", model.standbyTimeOpt.title, () {
                              Navigator.pushNamed(
                                context,
                                'StandbyTimeChoicePage',
                              );
                            });
                          }),
                          Container(
                            width: 392,
                            height: 1,
                            decoration: const BoxDecoration(
                                color: Color(0x19FFFFFF)
                            ),
                          ),
                          Consumer<StandbyChangeNotifier>(builder: (_, model, child) {
                            return settingItem("待机样式", parseScreenSaverName(screenSaverId), () {
                              Navigator.of(context)
                                  .pushNamed('SelectStandbyStylePage')
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    screenSaverId = value as int;
                                  });
                                }
                              });
                            }, model.standbyTimeOpt.value != -1);
                          }
                          ),
                          Container(
                            width: 392,
                            height: 1,
                            decoration: const BoxDecoration(
                                color: Color(0x19FFFFFF)
                            ),
                          ),
                          settingItem("夜间模式", duration, () {
                            Navigator.of(context).pushNamed("SelectTimeDurationPage").then((value) {
                              final result = value as Pair<int, int>;
                              final startTime = result.value1;
                              final endTime = result.value2;
                              debugPrint("开始时间：$startTime 结束时间: $endTime");
                              () async {
                                await Setting.instant().setScreedDuration(result);
                              }().then((value) => setState((){
                                duration = Setting.instant().getScreedDurationDetail();
                              }));
                            });
                          })
                        ],
                      ),
                    ),

                ],
              ))
          ],
        ),
      )),
    );
  }

  Widget settingItem(String name, String value, GestureTapCallback? onTap, [bool enable = true]) {
    return GestureDetector(
      onTap: () {
        if(enable) {
          onTap?.call();
        }
      },
      child: Opacity(
        opacity: enable? 1.0: 0.3,
        child: SizedBox(
          width: 432,
          height: 72,
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
                          color: Color(0X96FFFFFF),
                          fontSize: 18.0,
                          fontFamily: "MideaType",
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 18, 10, 18),
                    child: Image.asset(
                      "assets/newUI/arrow_right.png",
                      width: 36,
                      height: 36,
                    ),
                  ),
                ],
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

  void onAutoLightClick(bool isOn) {
    settingMethodChannel.setAutoLight(isOn);
    setState(() {
      autoLight = isOn;
      Global.autoLight = isOn;
    });
  }

  void onNearWakeupClick(bool isOn) {
    settingMethodChannel.setAutoLight(isOn);
    setState(() {
      nearWakeup = isOn;
      Global.nearWakeup = isOn;
    });
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

class CustomThumbShape extends SliderComponentShape {
  /// 滑块半径
  final double _thumbRadius;
  /// 滑块颜色
  final Color _thumbColor;

  CustomThumbShape(this._thumbRadius, this._thumbColor);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(_thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center, {required Animation<double> activationAnimation, required Animation<double> enableAnimation, required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox, required SliderThemeData sliderTheme, required TextDirection textDirection, required double value, required double textScaleFactor, required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    // 圆圈
    final Paint paint = Paint()
    // 抗锯齿
      ..isAntiAlias = true
    // 描边宽度
      ..strokeWidth = 4.0
      ..color = _thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      _thumbRadius,
      paint,
    );

  }
}
