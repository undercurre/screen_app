import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/routes/sniffer/device_item.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/global.dart';
import '../../../common/utils.dart';
import '../../../models/device_entity.dart';
import '../../../widgets/business/dropdown_menu.dart' as ui;
import '../../../widgets/event_bus.dart';
import '../../../widgets/mz_metal_card.dart';
import '../../../widgets/mz_notice.dart';
import '../../../widgets/plugins/slider_button_content.dart';

class AirConditionControl extends StatefulWidget {
  final bool? disabled;
  final bool computedPower;
  final num computedTemp;
  final num computedGear;
  final String computedMode;

  const AirConditionControl({super.key, this.disabled, required this.computedPower, required this.computedTemp, required this.computedGear, required this.computedMode});

  @override
  AirConditionControlState createState() => AirConditionControlState();
}

class AirConditionControlState extends State<AirConditionControl> with Throttle {
  bool disabled = false;
  num temperature = 26;
  num gear = 1;
  String modeValue = 'auto';
  bool power = false;

  bool menuVisible = false;

  // true为温度盘 false为风速盘
  bool airConditionPanel = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setData();
    });
  }

  List<Map<String, String>> btnList = [
    {
      'icon': 'assets/imgs/plugins/0xAC/zidong_icon.png',
      'text': '自动',
      'key': 'auto'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhileng_icon.png',
      'text': '制冷',
      'key': 'cool'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhire_icon.png',
      'text': '制热',
      'key': 'heat'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/songfeng_icon.png',
      'text': '送风',
      'key': 'fan'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/chushi_icon.png',
      'text': '除湿',
      'key': 'dry'
    },
  ];

  void switchACPanel(bool onOff) {
    if (!power) return;
    setState(() {
      airConditionPanel = onOff;
    });
  }

  Map<String, String> getCurACMode() {
    return btnList.where((element) => element["key"] == modeValue).toList()[0];
  }

  Future<void> airConditionPowerHandle(bool onOff) async {
    if (disabled) return;
    setState(() {
      power = !power;
    });
    var res = await CenterControlService.ACPowerControl(context, power);
    if (res) {
      TipsUtils.toast(content: '执行成功');
    } else {
      TipsUtils.toast(content: '执行失败');
      setState(() {
        power = !power;
      });
    }
  }

  void disableHandle() {
    MzNotice mzNotice = MzNotice(
        icon: const SizedBox(width: 0, height: 0),
        btnText: '我知道了',
        title: '房间内没有相关设备',
        backgroundColor: const Color(0XFF575757),
        onPressed: () {});

    mzNotice.show(context);
  }

  Future<void> airConditionValueHandle(num value) async {
    if (disabled) return;
    if (airConditionPanel) {
      var exValue = temperature;
      setState(() {
        temperature = value;
      });
      var res = await CenterControlService.ACTemperatureControl(context, value);
      if (res) {
        throttle(() {
          TipsUtils.toast(content: '执行成功');
        }, durationTime: const Duration(milliseconds: 2000));
      } else {
        throttle(() {
          TipsUtils.toast(content: '执行失败');
        }, durationTime: const Duration(milliseconds: 2000));
        setState(() {
          temperature = exValue;
        });
      }
    } else {
      var exValue = gear;
      setState(() {
        gear = value;
      });
      var res = await CenterControlService.ACFengsuControl(context, value);
      if (res) {
        throttle(() {
          TipsUtils.toast(content: '执行成功');
        }, durationTime: const Duration(milliseconds: 2000));
      } else {
        throttle(() {
          TipsUtils.toast(content: '执行失败');
        }, durationTime: const Duration(milliseconds: 2000));
        setState(() {
          gear = exValue;
        });
      }
    }
  }

  Future<void> airConditionModeHandle(String mode) async {
    if (disabled) return;
    var exValue = mode;
    setState(() {
      modeValue = mode;
    });
    var res = await CenterControlService.ACModeControl(context, mode);
    if (res) {
      TipsUtils.toast(content: '执行成功');
    } else {
      TipsUtils.toast(content: '执行失败');
      setState(() {
        modeValue = exValue;
      });
    }
  }

  sliderPart() {
    return airConditionPanel
        ? SliderButtonContent(
            unit: '℃',
            min: 17,
            max: 30,
            value: temperature,
            sliderWidth: 400,
            onChanged: (value) {
              airConditionValueHandle(value);
            },
            disabled: !power,
          )
        : SliderButtonContent(
            unit: '档',
            min: 1,
            max: 6,
            value: gear,
            sliderWidth: 400,
            onChanged: (value) {
              airConditionValueHandle(value);
            },
            disabled: !power,
          );
  }

  setData() {
    setState(() {
      disabled = widget.disabled ?? false;
      temperature = widget.computedTemp;
      gear = widget.computedGear;
      modeValue = widget.computedMode;
      power = widget.computedPower;
      debugPrint('装载空调中控数据');
    });
  }

  @override
  void didUpdateWidget(covariant AirConditionControl oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.computedPower != oldWidget.computedPower) {
      setState(() {
        power = widget.computedPower;
      });
    }
    if (widget.disabled != oldWidget.disabled) {
      setState(() {
        disabled = widget.disabled ?? false;
      });
    }
    if (widget.computedMode != oldWidget.computedMode) {
      setState(() {
        modeValue = widget.computedMode;
      });
    }
    if (widget.computedTemp != oldWidget.computedTemp) {
      setState(() {
        temperature = widget.computedTemp;
      });
    }
    if (widget.computedGear != oldWidget.computedGear) {
      setState(() {
        gear = widget.computedGear;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: disabled
            ? [
                MzMetalCard(
                  width: 440,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                child: SizedBox(
                                  width: 36,
                                )),
                            GestureDetector(
                              onTap: () => switchACPanel(true),
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          'assets/imgs/device/wendu.png'),
                                      const Text(
                                        '温度',
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 14,
                                            fontFamily: 'MideaType-Regular'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => switchACPanel(false),
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          'assets/imgs/device/songfeng.png'),
                                      const Text(
                                        '风速',
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 14,
                                            fontFamily: 'MideaType-Regular'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.3),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ui.DropdownMenu(
                                  disabled: !power,
                                  menuWidth: 84,
                                  arrowSize: 20,
                                  menu: btnList.map(
                                    (item) {
                                      return PopupMenuItem<String>(
                                        enabled: power,
                                        padding: EdgeInsets.zero,
                                        value: item['key'],
                                        child: Center(
                                          child: Container(
                                            width: 80,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: getCurACMode()["key"] ==
                                                      item['key'] // TODO: 完善
                                                  ? const Color(0xff575757)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Opacity(
                                              opacity: getCurACMode()["key"] ==
                                                      item['key'] // TODO: 完善
                                                  ? 1
                                                  : 0.7,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(item['icon']!,
                                                      width: 30, height: 30),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(7, 0, 7, 0),
                                                    child: Text(
                                                      item['text']!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "MideaType",
                                                        fontWeight:
                                                            FontWeight.w200,
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
                                  trigger: Opacity(
                                    opacity: menuVisible ? 0.5 : 1,
                                    child: Row(
                                      children: [
                                        Image.asset(getCurACMode()["icon"]!,
                                            width: 30, height: 30),
                                        Text(
                                          getCurACMode()["text"]!,
                                          style: const TextStyle(
                                            color: Color(0X7FFFFFFF),
                                            fontSize: 14.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.w200,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onVisibleChange: (visible) {
                                    setState(() {
                                      menuVisible = visible;
                                    });
                                  },
                                  onSelected: (dynamic mode) {
                                    airConditionModeHandle(mode);
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => airConditionPowerHandle(!power),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  power
                                      ? 'assets/imgs/device/on.png'
                                      : 'assets/imgs/device/off.png',
                                  alignment: Alignment.centerRight,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      sliderPart()
                    ],
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => disableHandle(),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(55, 55, 55, 0.50)),
                    ),
                  ),
                ),
                const Positioned(
                  left: 14,
                  top: 23,
                  child: Text(
                    '空调',
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'MideaType-Regular',
                        letterSpacing: 1.0),
                  ),
                )
              ]
            : [
                MzMetalCard(
                  width: 440,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: Text(
                                '空调',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 18,
                                    fontFamily: 'MideaType-Regular'),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => switchACPanel(true),
                              child: Stack(children: [
                                airConditionPanel
                                    ? const Positioned(
                                        child: Image(
                                          image: AssetImage(
                                              'assets/imgs/center/lanse.png'),
                                        ),
                                      )
                                    : Container(color: Colors.transparent),
                                Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(0, 0, 0, 0.3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/imgs/device/wendu.png'),
                                        const Text(
                                          '温度',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 14,
                                              fontFamily: 'MideaType-Regular'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            GestureDetector(
                              onTap: () => switchACPanel(false),
                              child: Stack(
                                children: [
                                  !airConditionPanel
                                      ? const Positioned(
                                          child: Image(
                                            image: AssetImage(
                                                'assets/imgs/center/lanse.png'),
                                          ),
                                        )
                                      : Container(color: Colors.transparent),
                                  Container(
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/imgs/device/songfeng.png'),
                                          const Text(
                                            '风速',
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 14,
                                                fontFamily:
                                                    'MideaType-Regular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.3),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ui.DropdownMenu(
                                  disabled: !power,
                                  menuWidth: 84,
                                  arrowSize: 20,
                                  menu: btnList.map(
                                    (item) {
                                      return PopupMenuItem<String>(
                                        enabled: power,
                                        padding: EdgeInsets.zero,
                                        value: item['key'],
                                        child: Center(
                                          child: Container(
                                            width: 80,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: getCurACMode()["key"] ==
                                                      item['key'] // TODO: 完善
                                                  ? const Color(0xff575757)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Opacity(
                                              opacity: getCurACMode()["key"] ==
                                                      item['key'] // TODO: 完善
                                                  ? 1
                                                  : 0.7,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(item['icon']!,
                                                      width: 30, height: 30),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(7, 0, 7, 0),
                                                    child: Text(
                                                      item['text']!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "MideaType",
                                                        fontWeight:
                                                            FontWeight.w200,
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
                                  trigger: Opacity(
                                    opacity: menuVisible ? 0.5 : 1,
                                    child: Row(
                                      children: [
                                        Image.asset(getCurACMode()["icon"]!,
                                            width: 30, height: 30),
                                        Text(
                                          getCurACMode()["text"]!,
                                          style: const TextStyle(
                                            color: Color(0X7FFFFFFF),
                                            fontSize: 14.0,
                                            fontFamily: "MideaType",
                                            fontWeight: FontWeight.w200,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onVisibleChange: (visible) {
                                    setState(() {
                                      menuVisible = visible;
                                    });
                                  },
                                  onSelected: (dynamic mode) {
                                    airConditionModeHandle(mode);
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => airConditionPowerHandle(power),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  power
                                      ? 'assets/imgs/device/on.png'
                                      : 'assets/imgs/device/off.png',
                                  alignment: Alignment.centerRight,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      airConditionPanel
                          ? SliderButtonContent(
                              unit: '℃',
                              min: 17,
                              max: 30,
                              value: temperature,
                              sliderWidth: 380,
                              onChanged: (value) {
                                airConditionValueHandle(value);
                              },
                              disabled: !power,
                            )
                          : SliderButtonContent(
                              unit: '',
                              min: 1,
                              max: 6,
                              value: gear,
                              sliderWidth: 380,
                              onChanged: (value) {
                                airConditionValueHandle(value);
                              },
                              disabled: !power,
                            )
                    ],
                  ),
                )
              ],
      ),
    );
  }
}
