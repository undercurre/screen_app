import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/business/dropdown_menu.dart' as ui;
import '../../../../widgets/plugins/air_485_condition.dart';
import 'cac_data_adapter.dart';

class AirCondition485PageState extends State<AirCondition485Page> {
  String targetTemp = "26";
  String currentTemp = "30";
  String windSpeed = "1";
  String mode = "1";
  String OnOff = "0";
  CACDataAdapter? adapter;
  String name = "";
  bool menuVisible = false;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    if (adapter!.data!.OnOff == '1') {
      adapter!.data!.OnOff = "0";
      OnOff="0";
      setState(() {});
      adapter?.orderPower(0);
    } else {
      adapter!.data!.OnOff = "1";
      OnOff="1";
      setState(() {});
      adapter?.orderPower(1);
    }
  }

  Future<void> gearHandle(num value) async {
    if(value==1){
      value=4;
    }else if(value==3){
      value=1;
    }
    windSpeed = value.toString();
    adapter!.data!.windSpeed = windSpeed;
    setState(() {});
    adapter?.orderSpeed(value.toInt());

  }

  Future<void> temperatureHandle(num value) async {
    adapter?.orderTemp(value.toInt());
    targetTemp = value.toString();
    adapter!.data!.targetTemp = targetTemp;
  }

  Future<void> modeHandle(String mode) async {
    adapter!.orderMode(int.tryParse(mode)!.toInt());
    adapter!.data!.operationMode = mode;
    this.mode = mode;
  }

  List<Map<String, dynamic>> modeList = [];

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[mode] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    adapter?.fetchData();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        name = args?['name'] ?? "";
        adapter = args?['adapter'];
        targetTemp = adapter!.data!.targetTemp;
        currentTemp = adapter!.data!.currTemp;
        windSpeed = adapter!.data!.windSpeed;
        mode = adapter!.data!.operationMode;
        OnOff = adapter!.data!.OnOff;
        adapter!.bindDataUpdateFunction(updateData);
      });
      updateDetail();
    });
  }

  void updateData() {
    if (mounted) {
      setState(() {
        adapter?.data = adapter!.data!;
        targetTemp = adapter!.data!.targetTemp;
        currentTemp = adapter!.data!.currTemp;
        windSpeed = adapter!.data!.windSpeed;
        mode = adapter!.data!.operationMode;
        OnOff = adapter!.data!.OnOff;
      });
    }
  }

  int setWinSpeed(String wind) {
    int speed = int.parse(wind);
    if (speed == 1) {
      speed = 3;
    } else if (speed == 2) {
      speed = 2;
    } else if (speed == 4) {
      speed = 1;
    } else {
      speed = 3;
    }
    return speed;
  }

  @override
  void dispose() {
    adapter!.unBindDataUpdateFunction(updateData);
    super.dispose();
  }

  List<Map<String, String>> btnList = [
    {
      'icon': 'assets/imgs/plugins/0xAC/zhileng_icon.png',
      'text': '制冷',
      'key': '1'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhire_icon.png',
      'text': '制热',
      'key': '8'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/songfeng_icon.png',
      'text': '送风',
      'key': '4'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/chushi_icon.png',
      'text': '除湿',
      'key': '2'
    },
  ];

  Map<String, String> getCurModeConfig() {
    Map<String, String> curMode =
        btnList.where((element) => element["key"] == mode).toList()[0];
    return curMode;
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
           Positioned(
              left: 0,
              top: 0,
              child: AirCondition485(
                temperature: currentTemp.toString(),
                windSpeed: 2,
                mode: "cool",
              )),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    maxHeight: 60.0,
                  ),
                  child: MzNavigationBar(
                    onLeftBtnTap: goBack,
                    onRightBtnTap: powerHandle,
                    title: name,
                    power: OnOff == '1',
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: EasyRefresh(
                      header: const ClassicHeader(
                        dragText: '下拉刷新',
                        armedText: '释放执行刷新',
                        readyText: '正在刷新...',
                        processingText: '正在刷新...',
                        processedText: '刷新完成',
                        noMoreText: '没有更多信息',
                        failedText: '失败',
                        messageText: '上次更新 %T',
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      onRefresh: () async {
                        updateDetail();
                      },
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            const Align(
                              widthFactor: 1,
                              heightFactor: 1,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 303,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: FunctionCard(
                                      title: '模式',
                                      child: ui.DropdownMenu(
                                        disabled: OnOff == '0',
                                        menu: btnList.map(
                                          (item) {
                                            return PopupMenuItem<String>(
                                              padding: EdgeInsets.zero,
                                              value: item['key'],
                                              child: MouseRegion(
                                                child: Center(
                                                  child: Container(
                                                    width: 130,
                                                    height: 50,
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: mode == item['key']
                                                          ? const Color(
                                                              0x26101010)
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                            item['icon']!),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  7, 0, 7, 0),
                                                          child: Text(
                                                            item['text']!,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  "MideaType",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        trigger: Row(
                                          children: [
                                            Image.asset(getCurModeConfig()[
                                                    "icon"] ??
                                                "assets/imgs/plugins/0xAC/zidong_icon.png"),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      7, 0, 7, 0),
                                              child: Text(
                                                getCurModeConfig()["text"] ??
                                                    '制冷',
                                                style: const TextStyle(
                                                  color: Color(0XFFFFFFFF),
                                                  fontSize: 18.0,
                                                  fontFamily: "MideaType",
                                                  fontWeight: FontWeight.w200,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onVisibleChange: (visible) {
                                          setState(() {
                                            menuVisible = visible;
                                          });
                                        },
                                        onSelected: (dynamic mode) {
                                          if (mode != null &&
                                              mode != getSelectedKeys()) {
                                            modeHandle(mode);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: SliderButtonCard(
                                      disabled: OnOff == '0',
                                      min: 16,
                                      max: 30,
                                      step: 1,
                                      value: int.parse(targetTemp),
                                      onChanged: temperatureHandle,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: GearCard(
                                      disabled: OnOff == '0',
                                      value: setWinSpeed(windSpeed),
                                      maxGear: 3,
                                      minGear: 1,
                                      onChanged: gearHandle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AirCondition485Page extends StatefulWidget {
  const AirCondition485Page({super.key});

  @override
  State<AirCondition485Page> createState() => AirCondition485PageState();
}
