import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../channel/index.dart';
import '../../common/setting.dart';

class SoundSettingPage extends StatefulWidget {
  const SoundSettingPage({Key? key});

  @override
  _SoundSettingPageState createState() => _SoundSettingPageState();
}

class _SoundSettingPageState extends State<SoundSettingPage> {
  late num soundValue;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("初始化initState");
    initial();
  }

  initial() async {
    soundValue = Setting.instant().volume;
    aiMethodChannel.registerAiSetVoiceCallBack(_aiSetVoiceCallback);
  }

  void _aiSetVoiceCallback(int voice) {
    setState(() {
      soundValue = voice;
    });
    Setting.instant().volume = voice;
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
                    const Text("声音设置",
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
                      child: Text("声音 | ${(soundValue / 15 * 100).toInt()}%",
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
                                thumbShape: CustomThumbShape2(12, Colors.white),
                              ),
                              child: Slider(
                                min: 0,
                                max: 15,
                                value: soundValue.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                      soundValue = value;
                                  });
                                  sliderToSetVol();
                                },
                                onChangeEnd: (value) {
                                  sliderToSetVolEnd();
                                },
                              ),
                            )
                        )
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void sliderToSetVol() {
    sliderTimer ??= Timer.periodic(const Duration(milliseconds: 500) , (timer) {
      settingMethodChannel.setSystemVoice(soundValue.toInt());
    });
  }

  void sliderToSetVolEnd() {
    if (sliderTimer != null) {
      if (sliderTimer!.isActive) {
        sliderTimer!.cancel();
      }
      sliderTimer = null;
    }
    settingMethodChannel.setSystemVoice(soundValue.toInt());
    Setting.instant().volume = soundValue.toInt();
  }

  @override
  void didUpdateWidget(SoundSettingPage oldWidget) {
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
    aiMethodChannel.unregisterAiSetVoiceCallBack(_aiSetVoiceCallback);
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

class CustomThumbShape2 extends SliderComponentShape {
  /// 滑块半径
  final double _thumbRadius;
  /// 滑块颜色
  final Color _thumbColor;

  CustomThumbShape2(this._thumbRadius, this._thumbColor);

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
