import 'dart:convert';

import 'package:flutter/material.dart';

import './center_control/index.dart';
import './device/index.dart';
import './scene/index.dart';
import '../../channel/index.dart';
import '../../common/global.dart';

export './center_control/index.dart';
export './device/index.dart';
export './scene/index.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.initValue = 0});

  final int initValue;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double po;
  var children = <Widget>[];
  late PageController _pageController;
  String pressPath = "assets/imgs/icon/button_press.png";
  String unPressPath = "assets/imgs/icon/button_normal.png";
  String selectDevice = "assets/imgs/icon/button_press.png";
  String selectScene = "assets/imgs/icon/button_normal.png";

  @override
  void initState() {
    super.initState();
    //初始化状态
    _pageController = PageController(initialPage: 1);
    children.add(const ScenePage(text: "场景页"));
    children.add(const DevicePage(text: "设备页"));
    children.add(const CenterControlPage(text: '中控页'));
    initial();
  }

  initial() async {
    num lightValue = await settingMethodChannel.getSystemLight();
    num soundValue = await settingMethodChannel.getSystemVoice();
    Global.soundValue = soundValue;
    Global.lightValue = lightValue;
    String? deviceSn =await aboutSystemChannel.getGatewaySn();
    String? deviceId =Global.profile.deviceId;
    String macAddress = await aboutSystemChannel.getMacAddress();
    var jsonData = '{ "deviceSn" : "$deviceSn", "deviceId" : "$deviceId", "macAddress" : "$macAddress","aiEnable":${Global.profile.aiEnable}}';
    var parsedJson = json.decode(jsonData);
    await aiMethodChannel.initialAi(parsedJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
                onVerticalDragDown: (details) {
                  po = details.globalPosition.dy;
                },
                onVerticalDragUpdate: (details) {
                  debugPrint("onVerticalDragUpdate---${details.globalPosition}---${details.localPosition}---${details.delta}");
                  if (po <= 14) {
                    Navigator.pushNamed(
                      context,
                      'DropDownPage',
                    );
                  }
                },
                child: Stack(
                  children: [
                    PageView(
                      // physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          if (index == 0) {
                            selectDevice = unPressPath;
                            selectScene = pressPath;
                          } else {
                            selectDevice = pressPath;
                            selectScene = unPressPath;
                          }
                        });
                      },
                      children: children,
                    ),
                    Positioned(
                        width: 480,
                        bottom: 14,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              selectScene,
                              width: 30,
                              height: 2,
                            ),
                            Image.asset(
                              selectDevice,
                              width: 30,
                              height: 2,
                            ),
                          ],
                        )),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("didUpdateWidget ");
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint("deactivate");
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    debugPrint("reassemble");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("didChangeDependencies");
  }
}
