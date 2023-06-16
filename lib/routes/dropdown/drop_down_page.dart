import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../channel/index.dart';
import '../../channel/models/music_state.dart';
import '../../common/global.dart';
import '../../common/utils.dart';
import '../../widgets/mz_vslider.dart';

class DropDownPage extends StatefulWidget {
  const DropDownPage({Key? key});

  @override
  _DropDownPageState createState() => _DropDownPageState();
}

class _DropDownPageState extends State<DropDownPage>
    with SingleTickerProviderStateMixin {
  late double po;

  late final AnimationController controller;
  late final Animation<double> animation;
  num lightValue = Global.lightValue;
  num soundValue = Global.soundValue;
  var soundName = "暂无歌曲";
  var singer = "暂无歌手";
  var musicIconUrl = "";

  var musicStartIcon = "assets/imgs/dropDown/pause-icon.png";
  var lightLogo = "assets/imgs/dropDown/light-black.png";
  var soundLogo = "assets/imgs/dropDown/sound-black.png";

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
    lightValue = Global.lightValue;
    soundValue = Global.soundValue;
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
      body: GestureDetector(
        // 点击遮罩层隐藏弹框
        child: Material(
            type: MaterialType.transparency, // 配置透明度
            child: Center(
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
                    child: Column(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 31, 24, 0),
                        width: 432,
                        height: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => {
                                Navigator.pop(context),
                                Navigator.pushNamed(
                                  context,
                                  'SnifferPage',
                                )
                              },
                              child: Container(
                                width: 130,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: const Color(0x19FFFFFF),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/newUI/add_device.png",
                                      width: 48,
                                      height: 48,
                                    ),
                                    const Text("添加设备",
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.5),
                                          fontSize: 18.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 280,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: const Color(0x19FFFFFF),
                              ),
                              margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('语音电话',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(255, 255, 255, 0.85),
                                            fontSize: 28.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none,
                                          )),
                                      Text('拨通互通屏',
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(255, 255, 255, 0.31),
                                            fontSize: 24.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none,
                                          )),
                                    ],
                                  ),

                                  GestureDetector(
                                    child: Image.asset(
                                      "assets/newUI/phone.png",
                                    ),
                                    onTapDown: (e) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                              onTapDown: (e) {
                                                logger.i('sjsjad');
                                                Navigator.pop(context);
                                              },
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 5, sigmaY: 5), // 设置高斯模糊程度
                                                child: Stack(children: [
                                                  Center(
                                                      child: Container(
                                                    width: 250,
                                                    height: 178,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromRGBO(151,156,166,0.46),
                                                      borderRadius: BorderRadius.circular(24),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 24),
                                                          child: Text('卧室屏',
                                                              style: TextStyle(
                                                                  fontSize: 24,
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                          0.85))),
                                                        ),
                                                        Container(
                                                          width: 198,
                                                          height: 1,
                                                          color: const Color.fromRGBO(
                                                              255, 255, 255, 0.16),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 24),
                                                          child: Text('二楼屏',
                                                              style: TextStyle(
                                                                  fontSize: 24,
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                          0.85))),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: Container(
                                                      color: Colors.black.withOpacity(
                                                          0.2), // 设置背景颜色和透明度
                                                    ),
                                                  ),
                                                ]),
                                              ));
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  //手动开启语音
                                  if (Global.profile.aiEnable)
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
                                    margin:
                                        const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 16, 0, 10),
                                    width: 130,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: const Color(0x19FFFFFF),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/newUI/yuyin.png",
                                          width: 48,
                                          height: 48,
                                        ),
                                        const Text("小美语音",
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.5),
                                              fontSize: 18.0,
                                              fontFamily: "MideaType",
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            )),
                                      ],
                                    )),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.pop(context),
                                  Navigator.pushNamed(
                                    context,
                                    'SettingPage',
                                  )
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 10),
                                  width: 130,
                                  height: 110,
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
                                            color: Color.fromRGBO(
                                                255, 255, 255, 0.5),
                                            fontSize: 18.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                alignment: Alignment.center,
                                child: MzVSlider(
                                  height: 240.0,
                                  width: 130.0,
                                  max: 15,
                                  value: soundValue.toDouble(),
                                  padding: const EdgeInsets.all(0),
                                  activeColors: const [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFFFFFFF)
                                  ],
                                  radius: 24,
                                  onChanging: (newValue, actieColor) async => {
                                    await settingMethodChannel
                                        .setSystemVoice(newValue.toInt()),
                                    soundValue = newValue,
                                    Global.soundValue = newValue,
                                    if (newValue > 7)
                                      {
                                        soundLogo =
                                            "assets/imgs/dropDown/sound-black.png"
                                      }
                                    else
                                      {
                                        soundLogo =
                                            "assets/imgs/dropDown/sound-white.png"
                                      },
                                    setState(() {})
                                  },
                                  onChanged: (newValue, actieColor) async => {
                                    await settingMethodChannel
                                        .setSystemVoice(newValue.toInt()),
                                    soundValue = newValue,
                                    Global.soundValue = newValue,
                                    if (newValue > 7)
                                      {
                                        soundLogo =
                                            "assets/imgs/dropDown/sound-black.png"
                                      }
                                    else
                                      {
                                        soundLogo =
                                            "assets/imgs/dropDown/sound-white.png"
                                      },
                                    setState(() {})
                                  },
                                ),
                              ),
                              IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      soundLogo,
                                      width: 60,
                                      height: 60,
                                    ),
                                  )),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                alignment: Alignment.center,
                                child: MzVSlider(
                                  height: 240.0,
                                  width: 130.0,
                                  max: 255,
                                  value: lightValue.toDouble(),
                                  padding: const EdgeInsets.all(0),
                                  radius: 24,
                                  activeColors: const [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFFFFFFF)
                                  ],
                                  onChanged: (newValue, actieColor) async => {
                                    await settingMethodChannel
                                        .setSystemLight(newValue.toInt()),
                                    lightValue = newValue,
                                    Global.lightValue = lightValue,
                                    if (newValue > 128)
                                      {
                                        lightLogo =
                                            "assets/imgs/dropDown/light-black.png"
                                      }
                                    else
                                      {
                                        lightLogo =
                                            "assets/imgs/dropDown/light-white.png"
                                      },
                                    setState(() {})
                                  },
                                  onChanging: (newValue, actieColor) async => {
                                    await settingMethodChannel
                                        .setSystemLight(newValue.toInt()),
                                    lightValue = newValue,
                                    Global.lightValue = lightValue,
                                    if (newValue > 128)
                                      {
                                        lightLogo =
                                            "assets/imgs/dropDown/light-black.png"
                                      }
                                    else
                                      {
                                        lightLogo =
                                            "assets/imgs/dropDown/light-white.png"
                                      },
                                    setState(() {})
                                  },
                                ),
                              ),
                              IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      lightLogo,
                                      width: 60,
                                      height: 60,
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                          // 点击遮罩层关闭弹框，并且点击非遮罩区域禁止关闭
                          onVerticalDragDown: (details) {
                            po = details.globalPosition.dy;
                          },
                          onVerticalDragUpdate: (details) {
                            if (po - details.globalPosition.dy > 50) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            width: 480,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                width: 137,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => {Navigator.pop(context)}),
                    ])))),
      ),
    );
  }

  @override
  void didUpdateWidget(DropDownPage oldWidget) {
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
    controller.dispose();
    super.dispose();
    aiMethodChannel.unregisterAiCallBack(_aiMusicStateCallback);
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
