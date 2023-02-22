import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../channel/index.dart';
import '../../common/global.dart';
import '../../widgets/mz_slider.dart';
import '../../widgets/mz_slider_noball.dart';

class SoundSettingPage extends StatefulWidget {
  const SoundSettingPage({Key? key});

  @override
  _SoundSettingPageState createState() => _SoundSettingPageState();
}

class _SoundSettingPageState extends State<SoundSettingPage> {
  late double po;
  num soundValue = Global.soundValue;

  @override
  void initState() {
    super.initState();
    //初始化状态
    print("初始化initState");
    initial();
  }

  initial() async {
    soundValue = Global.soundValue;
    aiMethodChannel.registerAiSetVoiceCallBack(_aiSetVoiceCallback);

  }

  void _aiSetVoiceCallback(int voice) {
    setState(() {
      Global.soundValue=voice;
      soundValue = Global.soundValue;
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
                  const Text("声音设置",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                  child: Image.asset(
                    "assets/imgs/setting/yinliang-empty.png",
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                  child: mz_slider_noball(
                    width: 360,
                    value: soundValue,
                    max: 15,
                    activeColors: const [Color(0xFF267AFF), Color(0xFF267AFF)],
                    onChanged: (value, actieColor) => {
                      settingMethodChannel.setSystemVoice(value),
                      soundValue = value,
                      Global.soundValue = soundValue,
                    },
                    onChanging: (value, actieColor) => {
                      settingMethodChannel.setSystemVoice(value),
                      soundValue = value,
                      Global.soundValue = soundValue,
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                  child: Image.asset(
                    "assets/imgs/setting/yinliang-full.png",
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
          ],
        ),
      )),
    );
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
