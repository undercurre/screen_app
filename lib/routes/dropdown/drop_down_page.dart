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

class _DropDownPageState extends State<DropDownPage> with SingleTickerProviderStateMixin {
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
                      color: Colors.black,
                    ),
                    child: Column(children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(25, 24, 25, 0),
                        width: 432,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF1a1a1a),
                        ),
                        child: Row(
                          children: [
                            Container(
                                margin: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                                child: RotationTransition(
                                    turns: animation,
                                    child: ClipOval(
                                        //圆形头像
                                        child: SizedBox(
                                            width: 120.0,
                                            height: 120.0,
                                            child: CachedNetworkImage(
                                              imageUrl: musicIconUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Image.asset(
                                                "assets/imgs/dropDown/music-default.png",
                                              ),
                                              errorWidget: (context, url, error) => Image.asset(
                                                "assets/imgs/dropDown/music-default.png",
                                              ),
                                            ))))),
                            Container(
                              alignment: Alignment.center,
                              width: 290,
                              height: 150,
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(soundName,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: 24.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                  Text(singer,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Color(0XFF8e8e8e),
                                        fontSize: 16.0,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      )),
                                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    IconButton(
                                      onPressed: () {
                                        controller.repeat();
                                        aiMethodChannel.musicPrev();
                                      },
                                      iconSize: 50.0,
                                      icon: Image.asset(
                                        "assets/imgs/dropDown/left-icon.png",
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        if (await aiMethodChannel.musicIsPaying()) {
                                          musicStartIcon = "assets/imgs/dropDown/pause-icon.png";
                                          aiMethodChannel.musicPause();
                                          controller.stop();
                                          setState(() {});
                                        } else {
                                          musicStartIcon = "assets/imgs/dropDown/start-icon.png";
                                          aiMethodChannel.musicStart();
                                          controller.repeat();
                                          setState(() {});
                                        }
                                      },
                                      iconSize: 50.0,
                                      icon: Image.asset(
                                        musicStartIcon,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        controller.repeat();
                                        aiMethodChannel.musicNext();
                                      },
                                      iconSize: 50.0,
                                      icon: Image.asset(
                                        "assets/imgs/dropDown/right-icon.png",
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            )
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
                                    margin: const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                    width: 130,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFF1a1a1a),
                                    ),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      spacing: 5,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/imgs/dropDown/ai-icon.png",
                                          width: 60,
                                          height: 60,
                                        ),
                                        const Text("智能语音",
                                            style: TextStyle(
                                              color: Color(0XFF8e8e8e),
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
                                  margin: const EdgeInsets.fromLTRB(25, 16, 0, 0),
                                  width: 130,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF1a1a1a),
                                  ),
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 5,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/imgs/dropDown/setting-icon.png",
                                        width: 60,
                                        height: 60,
                                      ),
                                      const Text("系统设置",
                                          style: TextStyle(
                                            color: Color(0XFF8e8e8e),
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
                                  height: 224.0,
                                  width: 130.0,
                                  max: 15,
                                  value: soundValue.toDouble(),
                                  padding: const EdgeInsets.all(0),
                                  activeColors: const [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                                  onChanging: (newValue, actieColor) async => {
                                    await settingMethodChannel.setSystemVoice(newValue.toInt()),
                                    soundValue = newValue,
                                    Global.soundValue = newValue,
                                    if (newValue > 7) {soundLogo = "assets/imgs/dropDown/sound-black.png"} else {soundLogo = "assets/imgs/dropDown/sound-white.png"},
                                    setState(() {})
                                  },
                                  onChanged: (newValue, actieColor) async => {
                                    await settingMethodChannel.setSystemVoice(newValue.toInt()),
                                    soundValue = newValue,
                                    Global.soundValue = newValue,
                                    if (newValue > 7) {soundLogo = "assets/imgs/dropDown/sound-black.png"} else {soundLogo = "assets/imgs/dropDown/sound-white.png"},
                                    setState(() {})
                                  },
                                ),
                              ),
                              IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
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
                                  height: 224.0,
                                  width: 130.0,
                                  max: 255,
                                  value: lightValue.toDouble(),
                                  padding: const EdgeInsets.all(0),
                                  activeColors: const [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                                  onChanged: (newValue, actieColor) async => {
                                    await settingMethodChannel.setSystemLight(newValue.toInt()),
                                    lightValue = newValue,
                                    Global.lightValue = lightValue,
                                    if (newValue > 128)
                                      {lightLogo = "assets/imgs/dropDown/light-black.png"}
                                    else
                                      {lightLogo = "assets/imgs/dropDown/light-white.png"},
                                    setState(() {})
                                  },
                                  onChanging: (newValue, actieColor) async => {
                                    await settingMethodChannel.setSystemLight(newValue.toInt()),
                                    lightValue = newValue,
                                    Global.lightValue = lightValue,
                                    if (newValue > 128)
                                      {lightLogo = "assets/imgs/dropDown/light-black.png"}
                                    else
                                      {lightLogo = "assets/imgs/dropDown/light-white.png"},
                                    setState(() {})
                                  },
                                ),
                              ),
                              IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
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
                              color: Colors.black,
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
