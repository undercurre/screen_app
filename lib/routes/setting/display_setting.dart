import 'dart:async';

import 'package:flutter/material.dart';

import '../../channel/index.dart';
import '../../common/setting.dart';
import '../../widgets/mz_cell.dart';
import '../../widgets/mz_switch.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({super.key});

  @override
  DisplaySettingPageState createState() => DisplaySettingPageState();
}

class DisplaySettingPageState extends State<DisplaySettingPage> {
  bool autoLight = Setting.instant().screenAutoEnable;
  bool nearWakeup = Setting.instant().nearWakeupEnable;
  num lightValue = Setting.instant().screenBrightness;
  String duration = '';
  late int screenSaverId;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();
    //初始化状态
    initial();
    screenSaverId = Setting.instant().screenSaverId;

    /// 取消自动调光
    onAutoLightClick(false);
  }

  initial() async {
    num lightVal = await settingMethodChannel.getSystemLight();
    bool screenAutoEnable = await settingMethodChannel.getAutoLight();
    Setting.instant().screenBrightness = lightVal.toInt();
    Setting.instant().screenAutoEnable = screenAutoEnable;
    lightValue = lightVal;
    autoLight = screenAutoEnable;

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
                    // Container(
                    //   width: 432,
                    //   height: 72,
                    //   margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    //   decoration: const BoxDecoration(
                    //       color: Color(0x0DFFFFFF),
                    //       borderRadius: BorderRadius.all(Radius.circular(16))
                    //   ),
                    //   child: Stack(
                    //     children: [
                    //       const Positioned(
                    //         left: 20,
                    //         top: 12,
                    //         child: Text("自动调节屏幕亮度",
                    //             style: TextStyle(
                    //                 color: Color(0XFFFFFFFF),
                    //                 fontSize: 24,
                    //                 fontFamily: "MideaType",
                    //                 fontWeight: FontWeight.normal,
                    //                 decoration: TextDecoration.none)
                    //         ),
                    //       ),
                    //       Positioned(
                    //         right: 20,
                    //         top: 20,
                    //         child: MzSwitch(
                    //           value: autoLight,
                    //           onTap: (e) => onAutoLightClick(!autoLight),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Column(
                        children: [
                            MzCell(
                              title: "自动亮度",
                              desc: "开启自动亮度之后，屏幕亮度会根据环境亮度自适应调整",
                              titleSize: 24,
                              hasArrow: false,
                              hasBottomBorder: false,
                              bgColor: Colors.transparent,
                              padding: const EdgeInsets.all(0),
                              hasSwitch: true,
                              initSwitchValue: autoLight,
                              onSwitch: (valueChange) {
                                setState(() {
                                  autoLight = valueChange;
                                  Setting.instant().screenAutoEnable = valueChange;
                                });
                              },
                            ),
                          SizedBox(
                              width: 432,
                              height: 50,
                              child: SliderTheme(
                                data: const SliderThemeData(
                                    trackHeight: 3,
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFF51555E),
                                    thumbColor: Colors.white,
                                    disabledThumbColor: const Color(0xFF51555E),
                                    disabledActiveTrackColor: const Color(0xFF51555E),
                                    disabledInactiveTrackColor: const Color(0xFF51555E)
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 255,
                                  value: lightValue.toDouble(),
                                  // The slider will be disabled if onChanged is null or if the range given by min..max is empty (i.e. if min is equal to max).
                                  onChanged: autoLight ? null : (value) {
                                    setState(() {
                                      lightValue = value.toInt();
                                    });
                                    sliderToSetLight();
                                  },
                                  onChangeEnd: (value) {
                                    sliderToSetLightEnd();
                                  },
                                ),
                              )
                          )
                        ],
                      ),
                    ),

                    Container(
                      width: 432,
                      height: 72,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: MzCell(
                        title: '靠近唤醒',
                        hasSwitch: true,
                        bgColor: Colors.transparent,
                        padding: const EdgeInsets.all(0),
                        initSwitchValue: nearWakeup,
                        onSwitch: onNearWakeupClick,
                      ),
                    ),

                    Container(
                      width: 432,
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration: const BoxDecoration(
                          color: Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Column(
                        children: [
                          MzCell(
                            title: "待机设置",
                            titleSize: 24,
                            hasArrow: true,
                            hasBottomBorder: true,
                            bgColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            onTap: () {
                              Navigator.of(context).pushNamed("StandbySettingPage");
                            },
                          ),

                          MzCell(
                            title: "夜间模式",
                            titleSize: 24,
                            hasArrow: true,
                            bgColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            onTap: () {
                              Navigator.of(context).pushNamed("NightModePage");
                            },
                          ),

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
      Setting.instant().screenAutoEnable = isOn;
    });
  }

  void onNearWakeupClick(bool isOn) {
    settingMethodChannel.setNearWakeup(isOn);
    setState(() {
      nearWakeup = isOn;
      Setting.instant().nearWakeupEnable = isOn;
    });
  }

  void sliderToSetLight() {
    sliderTimer ??= Timer.periodic(const Duration(milliseconds: 500) , (timer) {
        settingMethodChannel.setSystemLight(lightValue.toInt());
      });
  }

  void sliderToSetLightEnd() {
    if (sliderTimer != null) {
      if (sliderTimer!.isActive) {
        sliderTimer!.cancel();
      }
      sliderTimer = null;
    }
    settingMethodChannel.setSystemLight(lightValue.toInt());
    Setting.instant().screenBrightness = lightValue.toInt();
  }

  @override
  void didUpdateWidget(DisplaySettingPage oldWidget) {
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
