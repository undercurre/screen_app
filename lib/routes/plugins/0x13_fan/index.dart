import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_list_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'data_adapter.dart';

class WifiLightFanPageState extends State<WifiLightFanPage> with Throttle {
  WIFILightFunDataAdapter? dataAdapter;
  Mode? modeTap;

  int getWindSpeed() {
    if (dataAdapter?.data!.fanSpeed == 1) {
      return 1;
    } else if (dataAdapter?.data!.fanSpeed == 21) {
      return 2;
    } else if (dataAdapter?.data!.fanSpeed == 41) {
      return 3;
    } else if (dataAdapter?.data!.fanSpeed == 61) {
      return 4;
    } else if (dataAdapter?.data!.fanSpeed == 81) {
      return 5;
    } else if (dataAdapter?.data!.fanSpeed == 100) {
      return 6;
    } else {
      return 1;
    }
  }

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        dataAdapter = args?['adapter'];
      });
      dataAdapter?.bindDataUpdateFunction(updateCallback);
    });
  }

  @override
  void dispose() {
    super.dispose();
    dataAdapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {
      // Log.i("刷新数据: ${dataAdapter?.data.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

    String getDeviceName() {
      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return deviceListModel.getDeviceName(
          deviceId: dataAdapter?.getDeviceId(),
          maxLength: 8,
          startLength: 5,
          endLength: 2);
    }

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
          const Positioned(
            top: 137,
            left: 0,
            child: Image(
              width: 140,
              height: 246,
              image: AssetImage("assets/imgs/plugins/0x13/light_fan.png"),
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    maxHeight: 60.0,
                  ),
                  child: MzNavigationBar(
                    onLeftBtnTap: goBack,
                    onRightBtnTap: () {
                      dataAdapter?.controlPower();
                    },
                    title: getDeviceName(),
                    power: dataAdapter?.data!.funPower ?? false,
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
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
                    onRefresh: () {
                      dataAdapter?.fetchData();
                    },
                    child: SingleChildScrollView(
                      child: Row(
                        children: [
                          const Align(
                            widthFactor: 1,
                            heightFactor: 2,
                            alignment: Alignment(-1.0, -0.63),
                            child: SizedBox(
                              width: 152,
                              height: 0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: false),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 15, 20, 15),
                                      decoration: const BoxDecoration(
                                        color: Color(0x19FFFFFF),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image(
                                                    image: AssetImage(
                                                        'assets/imgs/plugins/0x13/led.png'),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 11),
                                                  child: const Text("照明",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0XFFFFFFFF),
                                                        fontSize: 18.0,
                                                        fontFamily: "MideaType",
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        decoration:
                                                            TextDecoration.none,
                                                      )),
                                                )
                                              ]),
                                          MzSwitch(
                                            activeColor:
                                                const Color(0xFF3C92D6),
                                            inactiveColor:
                                                const Color(0x33DCDCDC),
                                            pointActiveColor:
                                                const Color(0xFFDCDCDC),
                                            pointInactiveColor:
                                                const Color(0xFFDCDCDC),
                                            disabled: false,
                                            value:
                                                dataAdapter?.data?.ledPower ??
                                                    false,
                                            onTap: (bool value) {
                                              dataAdapter?.controlLedPower();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (dataAdapter?.sn8 == "79010863")
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          minValue: 1,
                                          maxValue: 100,
                                          title: '亮度',
                                          disabled:
                                              dataAdapter?.data!.ledPower ??
                                                      true
                                                  ? false
                                                  : true,
                                          value: max(
                                              1,
                                              dataAdapter?.data!.brightness ??
                                                  1),
                                          activeColors: const [
                                            Color(0xFFFFD185),
                                            Color(0xFFFFD185)
                                          ],
                                          onChanged:
                                              dataAdapter?.controlBrightness,
                                          onChanging:
                                              dataAdapter?.controlBrightness,
                                        ),
                                      ),
                                    if (dataAdapter?.sn8 == "79010863")
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          title: '色温',
                                          unit: "K",
                                          customMin:
                                              dataAdapter?.data?.minColorTemp ??
                                                  3000,
                                          customMax:
                                              dataAdapter?.data?.maxColorTemp ??
                                                  5700,
                                          disabled:
                                              dataAdapter?.data!.ledPower ??
                                                      true
                                                  ? false
                                                  : true,
                                          value:
                                              dataAdapter?.data!.colorTemp ?? 0,
                                          activeColors: const [
                                            Color(0xFFFFD39F),
                                            Color(0xFF55A2FA)
                                          ],
                                          onChanged: dataAdapter
                                              ?.controlColorTemperature,
                                          onChanging: dataAdapter
                                              ?.controlColorTemperature,
                                        ),
                                      ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: GearCard(
                                        disabled: dataAdapter?.data!.funPower ==
                                            false,
                                        value: getWindSpeed(),
                                        maxGear: 6,
                                        minGear: 1,
                                        onChanged:
                                            dataAdapter?.controlWindSpeed,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 15, 20, 15),
                                      decoration: const BoxDecoration(
                                        color: Color(0x19FFFFFF),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image(
                                                    image: AssetImage(
                                                        'assets/imgs/plugins/0x13/arround_dir.png'),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 11),
                                                  child: const Text("反转",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0XFFFFFFFF),
                                                        fontSize: 18.0,
                                                        fontFamily: "MideaType",
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        decoration:
                                                            TextDecoration.none,
                                                      )),
                                                )
                                              ]),
                                          MzSwitch(
                                            activeColor:
                                                const Color(0xFF3C92D6),
                                            inactiveColor:
                                                const Color(0x33DCDCDC),
                                            pointActiveColor:
                                                const Color(0xFFDCDCDC),
                                            pointInactiveColor:
                                                const Color(0xFFDCDCDC),
                                            disabled:
                                                dataAdapter?.data!.funPower ==
                                                    false,
                                            value:
                                                dataAdapter?.data!.arroundDir !=
                                                    1,
                                            onTap: (bool value) {
                                              dataAdapter?.controlArroundDir();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 15, 20, 15),
                                      decoration: const BoxDecoration(
                                        color: Color(0x19FFFFFF),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: Image(
                                                    image: AssetImage(
                                                        'assets/imgs/plugins/0x13/fan_nature.png'),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 11),
                                                  child: const Text("自然风",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0XFFFFFFFF),
                                                        fontSize: 18.0,
                                                        fontFamily: "MideaType",
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        decoration:
                                                            TextDecoration.none,
                                                      )),
                                                )
                                              ]),
                                          MzSwitch(
                                            activeColor:
                                                const Color(0xFF3C92D6),
                                            inactiveColor:
                                                const Color(0x33DCDCDC),
                                            pointActiveColor:
                                                const Color(0xFFDCDCDC),
                                            pointInactiveColor:
                                                const Color(0xFFDCDCDC),
                                            disabled:
                                                dataAdapter?.data!.funPower ==
                                                    false,
                                            value:
                                                dataAdapter?.data?.fanScene ==
                                                    "breathing_wind",
                                            onTap: (bool value) {
                                              if (value) {
                                                dataAdapter?.controlMode(
                                                    "breathing_wind");
                                              } else {
                                                dataAdapter
                                                    ?.controlMode("fanmanual");
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

class WifiLightFanPage extends StatefulWidget {
  const WifiLightFanPage({super.key});

  @override
  State<WifiLightFanPage> createState() => WifiLightFanPageState();
}

int formatValue(num value) {
  return int.parse((value / 255 * 100).toStringAsFixed(0));
}
