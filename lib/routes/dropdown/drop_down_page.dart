import 'dart:async';

import 'package:flutter/material.dart';
import '../../channel/index.dart';
import '../../channel/models/music_state.dart';
import '../../common/setting.dart';
import '../../common/utils.dart';
import '../../widgets/mz_vslider.dart';

class DropDownPage extends StatefulWidget {
  const DropDownPage({Key? key});

  @override
  _DropDownPageState createState() => _DropDownPageState();
}

class _DropDownPageState extends State<DropDownPage>
    with SingleTickerProviderStateMixin {
  late double yOffset;

  late final AnimationController controller;
  late final Animation<double> animation;
  num lightValue = Setting.instant().screenBrightness;
  num soundValue = Setting.instant().volume;
  var soundName = "暂无歌曲";
  var singer = "暂无歌手";
  var musicIconUrl = "";

  var musicStartIcon = "assets/imgs/dropDown/pause-icon.png";
  var lightLogo = "assets/imgs/dropDown/light-black.png";
  var soundLogo = "assets/imgs/dropDown/sound-black.png";

  Timer? sliderTimer1;
  Timer? sliderTimer2;

  initial() async {
    aiMethodChannel.registerAiCallBack(_aiMusicStateCallback);
    await aiMethodChannel.musicInforGet();
  }

  void _aiMusicStateCallback(AiMusicState state) {
    setState(() {
      soundName = state.songName;
      singer = state.singerName;
      musicIconUrl = state.imgUrl;
      if (state.playState == 1) {
        musicStartIcon = "assets/imgs/dropDown/start-icon.png";
        controller.repeat();
      } else {
        musicStartIcon = "assets/imgs/dropDown/pause-icon.png";
        controller.stop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: false);

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );
    controller.stop();
    lightValue = Setting.instant().screenBrightness;
    soundValue = Setting.instant().volume;
    if (soundValue > 7) {
      soundLogo = "assets/imgs/dropDown/sound-black.png";
    } else {
      soundLogo = "assets/imgs/dropDown/sound-white.png";
    }
    if (lightValue > 128) {
      lightLogo = "assets/imgs/dropDown/light-black.png";
    } else {
      lightLogo = "assets/imgs/dropDown/light-white.png";
    }
    initial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: GestureDetector(
        onVerticalDragDown: (DragDownDetails detail) {
          yOffset = detail.globalPosition.dy;
        },
        onVerticalDragUpdate: (DragUpdateDetails detail) {
          if (yOffset - detail.globalPosition.dy > 40) {
            Navigator.pop(context);
          }
        },
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
          child: Stack(
            children: [
              /// 自定义
              Positioned(
                left: 24,
                top: 32,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.pop(context),
                    Navigator.pushNamed(
                      context,
                      'Custom'
                    )
                  },
                  child: Container(
                    width: 130,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0x19FFFFFF),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/newUI/custom.png",
                          width: 48,
                          height: 48,
                        ),
                        const Text(
                          "自定义",
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                            fontSize: 18.0,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// 小美语音
              Positioned(
                left: 24,
                top: 144,
                child: GestureDetector(
                  onTap: () => {
                    //手动开启语音
                    if (Setting.instant().aiEnable)
                      {
                        Navigator.pop(context),
                        aiMethodChannel.wakeUpAi(),
                      }
                    else
                      {
                        TipsUtils.toast(content: "请先开启小美语音"),
                      }
                  },
                  child: Container(
                      width: 130,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0x19FFFFFF),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/newUI/yuyin.png",
                            width: 48,
                            height: 48,
                          ),
                          const Text("小美语音",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.5),
                                fontSize: 18.0,
                                fontFamily: "MideaType",
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      )),
                ),
              ),

              /// 系统设置
              Positioned(
                left: 24,
                top: 260,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.pop(context),
                    Navigator.pushNamed(
                      context,
                      'SettingPage',
                    )
                  },
                  child: Container(
                    width: 130,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0x19FFFFFF),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/newUI/shezhi.png",
                          width: 48,
                          height: 48,
                        ),
                        const Text("系统设置",
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5),
                              fontSize: 18.0,
                              fontFamily: "MideaType",
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            )),
                      ],
                    ),
                  ),
                ),
              ),

              /// 声音调节
              Positioned(
                left: 175,
                top: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: MzVSlider(
                        height: 322.0,
                        width: 130.0,
                        max: 15,
                        value: soundValue.toDouble(),
                        padding: const EdgeInsets.all(0),
                        activeColors: const [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF)
                        ],
                        radius: 24,
                        onChanging: (newValue, actieColor) {
                          soundValue = newValue;
                          if (newValue > 7) {
                            soundLogo = "assets/imgs/dropDown/sound-black.png";
                          } else {
                            soundLogo = "assets/imgs/dropDown/sound-white.png";
                          }
                          setState(() {});
                          sliderToSetVol();
                        },
                        onChanged: (newValue, actieColor) {
                          soundValue = newValue;
                          if (newValue > 7) {
                            soundLogo = "assets/imgs/dropDown/sound-black.png";
                          } else {
                            soundLogo = "assets/imgs/dropDown/sound-white.png";
                          }
                          setState(() {});
                          sliderToSetVolEnd();
                        },
                      ),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: Image.asset(
                        soundLogo,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ),

              /// 亮度调节
              Positioned(
                left: 326,
                top: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: MzVSlider(
                        height: 322.0,
                        width: 130.0,
                        max: 255,
                        value: lightValue.toDouble(),
                        padding: const EdgeInsets.all(0),
                        radius: 24,
                        activeColors: const [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF)
                        ],
                        onChanged: (newValue, actieColor) {
                          lightValue = newValue;
                          if (newValue > 128) {
                            lightLogo = "assets/imgs/dropDown/light-black.png";
                          } else {
                            lightLogo = "assets/imgs/dropDown/light-white.png";
                          }
                          setState(() {});
                          sliderToSetLight();
                        },
                        onChanging: (newValue, actieColor) {
                          lightValue = newValue;
                          if (newValue > 128) {
                            lightLogo = "assets/imgs/dropDown/light-black.png";
                          } else {
                            lightLogo = "assets/imgs/dropDown/light-white.png";
                          }
                          setState(() {});
                          sliderToSetLightEnd();
                        },
                      ),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: Image.asset(
                        lightLogo,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 172,
                bottom: 10,
                child: Container(
                  height: 4,
                  width: 137,
                  decoration: const BoxDecoration(
                      color: Color(0xFFD8D8D8),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  void sliderToSetVol() {
    sliderTimer1 ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
      settingMethodChannel.setSystemVoice(soundValue.toInt());
    });
  }

  void sliderToSetVolEnd() {
    if (sliderTimer1 != null) {
      if (sliderTimer1!.isActive) {
        sliderTimer1!.cancel();
      }
      sliderTimer1 = null;
    }
    settingMethodChannel.setSystemVoice(soundValue.toInt());
    Setting.instant().volume = soundValue.toInt();
  }

  void sliderToSetLight() {
    sliderTimer2 ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
      settingMethodChannel.setSystemLight(lightValue.toInt());
    });
  }

  void sliderToSetLightEnd() {
    if (sliderTimer2 != null) {
      if (sliderTimer2!.isActive) {
        sliderTimer2!.cancel();
      }
      sliderTimer2 = null;
    }
    settingMethodChannel.setSystemLight(lightValue.toInt());
    Setting.instant().screenBrightness = lightValue.toInt();
  }

  @override
  void didUpdateWidget(DropDownPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    aiMethodChannel.unregisterAiCallBack(_aiMusicStateCallback);
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
