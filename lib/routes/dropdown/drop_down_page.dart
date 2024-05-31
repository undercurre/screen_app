import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/device/grid_container.dart';
import '../../channel/index.dart';
import '../../channel/models/music_state.dart';
import '../../common/global.dart';
import '../../common/logcat_helper.dart';
import '../../common/setting.dart';
import '../../common/system.dart';
import '../../common/utils.dart';
import '../../services/layout/method.dart';
import '../../states/layout_notifier.dart';
import '../../widgets/mz_dialog.dart';
import '../../widgets/mz_vslider.dart';
import '../login/index.dart';

class DropDownPage extends StatefulWidget {
  const DropDownPage({Key? key});

  @override
  _DropDownPageState createState() => _DropDownPageState();
}

class _DropDownPageState extends State<DropDownPage> with SingleTickerProviderStateMixin {

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

  int lastTimeSetVolume = 0;
  int lastTimeSetBrightness = 0;

  initial() async {
    aiMethodChannel.registerAiSetVoiceCallBack(_aiSetVoiceCallback);
    aiMethodChannel.registerAiCallBack(_aiMusicStateCallback);
    await aiMethodChannel.musicInforGet();
  }

  void _aiSetVoiceCallback(int voice) {
    logger.i("语音音量调整:$voice");
    Setting.instant().volume = voice;
    Setting.instant().showVolume = (voice / 15 * 100).toInt();
    setState(() {
      soundValue = voice;
      if (soundValue > 7) {
        soundLogo = "assets/imgs/dropDown/sound-black.png";
      } else {
        soundLogo = "assets/imgs/dropDown/sound-white.png";
      }
    });
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
    initViewData();
    initial();
  }

  Future<void> initViewData() async {
    num lightVal = await settingMethodChannel.getSystemLight();
    num soundVal = await settingMethodChannel.getSystemVoice();

    Setting.instant().screenBrightness = lightVal.toInt();
    Setting.instant().volume = soundVal.toInt();
    lightValue = lightVal;
    soundValue = soundVal;
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
                  onTap: () {
                    CustomLayoutHelper.showToLayout(context);
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
                          "一键布局",
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
                        activeColors: const [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                        radius: 24,
                        onChanging: (newValue, actieColor) {
                          soundValue = newValue;
                          if (newValue > 7) {
                            soundLogo = "assets/imgs/dropDown/sound-black.png";
                          } else {
                            soundLogo = "assets/imgs/dropDown/sound-white.png";
                          }
                          setState(() {});
                          // sliderToSetVol();
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
                        activeColors: const [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                        onChanged: (newValue, actieColor) {
                          lightValue = newValue;
                          if (newValue > 128) {
                            lightLogo = "assets/imgs/dropDown/light-black.png";
                          } else {
                            lightLogo = "assets/imgs/dropDown/light-white.png";
                          }
                          setState(() {});
                          sliderToSetLightEnd();
                        },
                        onChanging: (newValue, actieColor) {
                          lightValue = newValue;
                          if (newValue > 128) {
                            lightLogo = "assets/imgs/dropDown/light-black.png";
                          } else {
                            lightLogo = "assets/imgs/dropDown/light-white.png";
                          }
                          setState(() {});
                          sliderToSetLight();
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
                  decoration: const BoxDecoration(color: Color(0xFFD8D8D8), borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  void sliderToSetVol() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastTimeSetVolume > 500) {
      lastTimeSetVolume = now;
      settingMethodChannel.setSystemVoice(soundValue.toInt());
      Setting.instant().volume = soundValue.toInt();
    }
  }

  void sliderToSetVolEnd() {
    lastTimeSetVolume = DateTime.now().millisecondsSinceEpoch;
    settingMethodChannel.setSystemVoice(soundValue.toInt());
    Setting.instant().volume = soundValue.toInt();
    Setting.instant().showVolume = (soundValue / 15 * 100).toInt();
  }

  void sliderToSetLight() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastTimeSetBrightness > 500) {
      lastTimeSetBrightness = now;
      settingMethodChannel.setSystemLight(lightValue.toInt());
      Setting.instant().screenBrightness = lightValue.toInt();
    }
  }

  void sliderToSetLightEnd() {
    lastTimeSetBrightness = DateTime.now().millisecondsSinceEpoch;
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
    aiMethodChannel.unregisterAiSetVoiceCallBack(_aiSetVoiceCallback);
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

class CustomLayoutHelper {

  static void showToLayout(BuildContext context) {
    GlobalKey<_LoadingLayoutDialogState> loadingKey = GlobalKey<_LoadingLayoutDialogState>();
    callback(int position, BuildContext context) async {
      Navigator.pop(context);
      if (context.mounted) {
        if (position == 0) {
          Navigator.of(context).pushNamed('Custom');
        }
        if (position == 1) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            // false = user must tap button, true = tap outside dialog
            builder: (BuildContext dialogContext) {
              return LoadingLayoutDialog(key: loadingKey);
            },
          );
          // 执行智能排序
          // final layoutModel = context.read<LayoutModel>();
          // Log.i('目前的布局数据', layoutModel.layouts.where((element) => element.cardType != CardType.Null).map((e) => '${e.cardType}${e.pageIndex}${e.grids}'));
          // await layoutModel.removeLayouts();
          bool autoRes = await auto2LayoutNew(context);
          if (autoRes) {
            await Future.delayed(const Duration(seconds: 5), () => {loadingKey.currentState?.showSucStyle()});
          } else {
            await Future.delayed(const Duration(seconds: 5), () => {loadingKey.currentState?.showErrorStyle()});
          }
          await Future.delayed(const Duration(seconds: 2), () {
            if (System.isLogin()) {
              Navigator.popUntil(
                  context, (route) => route.settings.name == 'Home');
            } else {
              Navigator.pop(context);
            }
          });
        }
      }
    }
    MzDialog(
        title: '一键布局',
        titleSize: 28,
        maxWidth: 432,
        backgroundColor: const Color(0xFF494E59),
        contentPadding: const EdgeInsets.fromLTRB(33, 24, 33, 0),
        contentSlot: const Text('小美将会为您创建“当前房间”里设备和场景的最优体验布局，您也可以选择手动添加进行自定义布局',
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              color: Color(0xFFB6B8BC),
              fontSize: 24,
              height: 1.6,
              fontFamily: "MideaType",
              decoration: TextDecoration.none,
            )),
        btns: ['手动添加', '确定'],
        closeAble: true,
        onPressed: (_, position, context) => callback(position, context)).show(context);
  }

}

class LoadingLayoutDialog extends StatefulWidget {
  LoadingLayoutDialog({super.key});

  @override
  State<LoadingLayoutDialog> createState() => _LoadingLayoutDialogState();
}

class _LoadingLayoutDialogState extends State<LoadingLayoutDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late int state;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    state = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showLoadingStyle() {
    setState(() {
      state = 0;
    });
  }

  showSucStyle() {
    setState(() {
      state = 1;
    });
  }

  showErrorStyle() {
    setState(() {
      state = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    var contentWidget = switch (state) {
      1 => Column(children: [
          Image.asset('assets/newUI/login/binding_suc.png'),
          const Text(
            '创建成功',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ]),
      2 => Column(children: [
          Image.asset('assets/newUI/login/binding_err.png'),
          const Text(
            '失败',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ]),
      _ => Column(children: [
          const SizedBox(
            width: 150,
            height: 150,
            child: Align(
              child: CupertinoActivityIndicator(radius: 25),
            ),
          ),
          Text(
            '正在创建中，请稍后',
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.72),
              fontSize: 24,
            ),
          ),
        ])
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (state != 0) {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 412,
              height: 270,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF494E59),
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
              ),
              child: Column(
                children: [
                  Expanded(flex: 1, child: Container(alignment: Alignment.topCenter, child: contentWidget)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
