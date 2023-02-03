import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/business/dropdown_menu.dart';
import '../../../widgets/mz_metal_card.dart';
import '../../../widgets/plugins/slider_button_content.dart';

class AirConditionControl extends StatefulWidget {
  final bool? disabled;

  const AirConditionControl({super.key, this.disabled});

  @override
  AirConditionControlState createState() => AirConditionControlState();
}

class AirConditionControlState extends State<AirConditionControl> {
  bool menuVisible = false;

  // true为温度盘 false为风速盘
  bool airConditionPanel = true;

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
    setState(() {
      airConditionPanel = onOff;
    });
  }

  Map<String, String> getCurACMode() {
    return btnList
        .where((element) =>
            element["key"] == CenterControlService.airConditionMode(context))
        .toList()[0];
  }

  void airConditionPowerHandle(bool onOff) {
    CenterControlService.ACPowerControl(context, onOff);
  }

  void airConditionValueHandle(num value) {
    if (airConditionPanel) {
      CenterControlService.ACTemperatureControl(context, value);
    } else {
      CenterControlService.ACFengsuControl(context, value);
    }
  }

  void airConditionModeHandle(String mode) {
    CenterControlService.ACModeControl(context, mode);
  }

  sliderPart() {
    return airConditionPanel
        ? SliderButtonContent(
            unit: '℃',
            min: 17,
            max: 30,
            value: CenterControlService.airConditionTemperature(context),
            sliderWidth: 400,
            onChanged: (value) {
              airConditionValueHandle(value);
            },
          )
        : SliderButtonContent(
            unit: '档',
            min: 1,
            max: 6,
            value: CenterControlService.airConditionGear(context),
            sliderWidth: 400,
            onChanged: (value) {
              airConditionValueHandle(value);
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: widget.disabled ?? false
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
                                child: DropdownMenu(
                                  menuWidth: 84,
                                  arrowSize: 20,
                                  menu: btnList.map(
                                    (item) {
                                      return PopupMenuItem<String>(
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
                              onTap: () => airConditionPowerHandle(
                                  !CenterControlService.isAirConditionPower(
                                      context)),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  CenterControlService.isAirConditionPower(
                                          context)
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
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(55, 55, 55, 0.50)),
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
                                child: DropdownMenu(
                                  menuWidth: 84,
                                  arrowSize: 20,
                                  menu: btnList.map(
                                    (item) {
                                      return PopupMenuItem<String>(
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
                              onTap: () => airConditionPowerHandle(
                                  !CenterControlService.isAirConditionPower(
                                      context)),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  CenterControlService.isAirConditionPower(
                                          context)
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
                              value:
                                  CenterControlService.airConditionTemperature(
                                      context),
                              sliderWidth: 380,
                              onChanged: (value) {
                                airConditionValueHandle(value);
                              },
                            )
                          : SliderButtonContent(
                              unit: '',
                              min: 1,
                              max: 6,
                              value: CenterControlService.airConditionGear(
                                  context),
                              sliderWidth: 380,
                              onChanged: (value) {
                                airConditionValueHandle(value);
                              },
                            )
                    ],
                  ),
                )
              ],
      ),
    );
  }
}
