
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../channel/index.dart';
import '../../channel/models/music_state.dart';
import '../../common/global.dart';
import '../../widgets/AdvancedVerticalSeekBar.dart';

class DropDownDialogState extends State<DropDownDialog> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  num lightValue = Global.lightValue;
  num soundValue = Global.soundValue;
  var soundName = "暂无歌曲";
  var singer = "暂无歌手";
  var musicIconUrl = "";

  var musicStartIcon = "assets/imgs/dropDown/pause-icon.png";

  initial() async {
    lightValue = await settingMethodChannel.getSystemLight();
    soundValue = await settingMethodChannel.getSystemVoice();
    aiMethodChannel.registerAiCallBack(_aiMusicStateCallback);
    logger.i("注册监听");
  }

  void _aiMusicStateCallback(AiMusicState state) {
    setState(() {
      soundName = state.songName;
      singer = state.singerName;
      musicIconUrl = state.imgUrl;
      logger.i("歌曲名称:${state.songName}");
      if(state.playState==1){
        controller.stop();
      }else{
        controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    aiMethodChannel.unregisterAiCallBack(_aiMusicStateCallback);
    logger.i("注销监听");

  }

  @override
  Widget build(BuildContext context) {
    late double po;
    return GestureDetector(
      // 点击遮罩层隐藏弹框
      child: Material(
          type: MaterialType.transparency, // 配置透明度
          child: Center(
              child: GestureDetector(
                  // 点击遮罩层关闭弹框，并且点击非遮罩区域禁止关闭
                  onVerticalDragDown: (details) {
                    po = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) {
                    if (po - details.globalPosition.dy > 150) {
                      Navigator.pop(context);
                    }
                  },
                  onTap: () => {Navigator.pop(context)},
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
                                          child: CachedNetworkImage(
                                            imageUrl: musicIconUrl,
                                            placeholder: (context, url) => Image.asset(
                                              "assets/imgs/dropDown/music-default.png",
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              "assets/imgs/dropDown/music-default.png",
                                            ),
                                          )))),
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
                                        style: const TextStyle(
                                          color: Color(0XFFFFFFFF),
                                          fontSize: 24.0,
                                          fontFamily: "MideaType",
                                          fontWeight: FontWeight.normal,
                                          decoration: TextDecoration.none,
                                        )),
                                    Text(singer,
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
                                    Navigator.pop(context),
                                    aiMethodChannel.wakeUpAi(),
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
                                  child: AdvancedVerticalSeekBar(
                                    height: 224.0,
                                    width: 130.0,
                                    max: 15,
                                    value: soundValue.toDouble(),
                                    onValueChanged: (newValue) => {
                                      settingMethodChannel.setSystemVoice(newValue.toInt()),
                                      soundValue = newValue,
                                      Global.soundValue = soundValue,
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/imgs/dropDown/sound-black.png",
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: AdvancedVerticalSeekBar(
                                    height: 224.0,
                                    width: 130.0,
                                    max: 255,
                                    value: lightValue.toDouble(),
                                    onValueChanged: (newValue) => {
                                      settingMethodChannel.setSystemLight(newValue.toInt()),
                                      lightValue = newValue,
                                      Global.lightValue = lightValue,
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(21, 16, 0, 0),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/imgs/dropDown/light-black.png",
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                          width: 137,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        )
                      ]))))),
    );
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
    initial();
  }

}

class DropDownDialog extends StatefulWidget {
  final DropDownDialogState state = DropDownDialogState();

  DropDownDialog({Key? key}) : super(key: key);

  @override
  DropDownDialogState createState() => DropDownDialogState();
}

class MFDropDownDialog {
  static DropDownDialogState showDropDownDialog(BuildContext context) {
    var widget = DropDownDialog();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return widget;
          },
        );
      },
    );

    return widget.state;
  }
}
