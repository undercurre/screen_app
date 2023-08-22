
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/gateway_platform.dart';
import '../../../widgets/event_bus.dart';
import './mode_list.dart';
import 'data_adapter.dart';

class WifiCurtainPageState extends State<WifiCurtainPage> {
  WIFICurtainDataAdapter? dataAdapter;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[dataAdapter?.device.curtainStatus ?? "stop"] = true;
    debugPrint('$selectKeys');
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      dataAdapter = args?['adapter'];
      dataAdapter?.bindDataUpdateFunction(updateCallback);
    });
  }

  @override
  void dispose() {
    super.dispose();
    dataAdapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
          // 窗帘动画
          Positioned(
              left: -32, // 向左偏移
              top: 0,
              child: AnimationCurtain(
                position: dataAdapter?.device.curtainPosition ?? 0,
              )
          ),
          Column(
            children: <Widget>[
              // 顶部导航
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: MzNavigationBar(
                  onLeftBtnTap: goBack,
                  title: dataAdapter?.device.deviceName ?? "",
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
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: SliderButtonCard(
                                    unit: '%',
                                    value: dataAdapter?.device.curtainPosition ?? 0,
                                    min: 0,
                                    max: 100,
                                    onChanged: dataAdapter?.controlCurtain,
                                ),
                              ),
                              ModeCard(
                                title: "模式",
                                spacing: 40,
                                modeList: curtainModes,
                                selectedKeys: getSelectedKeys(),
                                onTap: dataAdapter?.controlMode,
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

class WifiCurtainPage extends StatefulWidget {
  const WifiCurtainPage({super.key});

  @override
  State<WifiCurtainPage> createState() => WifiCurtainPageState();
}
