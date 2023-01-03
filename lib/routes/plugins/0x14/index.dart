import 'dart:async';
import '../../../common/global.dart';
import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/mixins/auto_sniffer.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/widgets/index.dart';

class CurtainPageState extends State<CurtainPage> with AutoSniffer {
  String deviceId = '178120883713504'; // 暂时写死设备编码
  String deviceName = '窗帘';
  double curtainPosition = 1;
  String curtainStatus = 'stop';
  String curtainDirection = 'positive';

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      curtainStatus = mode.key;
    });
    await CurtainApi.setMode(deviceId, mode.key, curtainDirection);
    // TODO 定时回显返回值
  }

  Future<void> curtainHandle(num value) async {
    // 控制值即时响应
    setState(() {
      curtainPosition = double.parse('$value');
    });
    await CurtainApi.changePosition(deviceId, value, curtainDirection);
    // TODO 控制返回值回显
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[curtainStatus] = true;
    debugPrint('$selectKeys');
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        var t = args as Map;
        deviceId = t['deviceId'];
        deviceName = t['deviceName'];
      }

      var res = await CurtainApi.getDetail(deviceId);

      setState(() {
        curtainPosition = double.parse(res.result['curtain_position']);
        curtainStatus = res.result['curtain_status'];
        curtainDirection = res.result['curtain_direction'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          // 窗帘动画
          Positioned(
              left: -16, // 向左偏移
              top: 0,
              child: AnimationCurtain(
                position: curtainPosition,
              )),
          Column(
            children: <Widget>[
              // 顶部导航
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: MzNavigationBar(
                  onLeftBtnTap: goBack,
                  title: deviceName,
                  hasPower: false,
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    // 卡片位置限制
                    const Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: Alignment(-1.0, -0.63),
                      child: SizedBox(
                        width: 152,
                        height: 303,
                      ),
                    ),
                    // 卡片
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            children: [
                              SliderButtonCard(
                                  unit: '%',
                                  value: num.parse('$curtainPosition') ,
                                  min: 1,
                                  max: 100,
                                  onChanged: curtainHandle),
                              ModeCard(
                                title: "模式",
                                spacing: 40,
                                modeList: curtainModes,
                                selectedKeys: getSelectedKeys(),
                                onTap: modeHandle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurtainPage extends StatefulWidget {
  const CurtainPage({super.key});

  @override
  State<CurtainPage> createState() => CurtainPageState();
}
