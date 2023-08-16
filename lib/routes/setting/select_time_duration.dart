
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_app/common/helper.dart';
import 'package:screen_app/common/index.dart';

import '../../common/setting.dart';
import '../../widgets/mz_switch.dart';

class SelectTimeDurationPage extends StatefulWidget {

  const SelectTimeDurationPage({super.key});

  @override
  State<StatefulWidget> createState() => _SelectTimeDurationState();

}

class _SelectTimeDurationState extends State<SelectTimeDurationPage> {
  /// 数字格式化器
  var numberFormat = NumberFormat('00', 'en_US');
  /// 开始时间 -- 小时
  int startHour = 0;
  /// 开始时间 -- 分钟
  int startMinute = 0;
  /// 结束时间 -- 小时
  int endHour = 0;
  /// 结束时间 -- 分钟
  int endMinute = 0;
  /// 是否显示第二天
  bool _showNextDay = false;


  /// 所有小时
  List<int> hours = List.generate(24, (index) => index);
  /// 所有分钟
  List<int> minutes = List.generate(60, (index) => index);
  /// 持有_ShowNextState实例对象
  GlobalKey<_ShowNextState> globalKey = GlobalKey();

  bool isValidTime = true;

  @override
  void initState() {
    super.initState();
    Pair<int, int> startTime = Setting.instant().getScreedDetailTime(Setting.instant().getScreedDuration().value1);
    Pair<int, int> endTime = Setting.instant().getScreedDetailTime(Setting.instant().getScreedDuration().value2);
    if(startTime.value1 < 0 || startTime.value2 < 0 || endTime.value1 < 0 || endTime.value2 < 0){
      isValidTime = false;
      return;
    }

    startHour = startTime.value1 % 24;
    startMinute = startTime.value2;
    endHour = endTime.value1 % 24;
    endMinute = endTime.value2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(" _SelectTimeDurationState => build");
    return Scaffold(
      body: Center(
        child: Container(
          width: 480,
          height: 480,
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
          child: Column(
            children: [
              Container(
                width: 480,
                height: 70,
                padding: const EdgeInsets.fromLTRB(0, 0, 32, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 64,
                      icon: Image.asset(
                        "assets/newUI/back.png",
                      ),
                    ),
                    const Text("夜间模式",
                        style: TextStyle(
                            color: Color(0XD8FFFFFF),
                            fontSize: 28,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none)
                    ),
                    MzSwitch(
                      value: isValidTime,
                      onTap: (e) {
                        setState(() {
                          isValidTime = e;
                        });
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 480,
                height: 10,
              ),

              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      left: 32,
                      top: 128,
                      child: Container(
                        width: 176,
                        height: 1,
                        color: const Color(0x4C979797),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 176,
                      child: Container(
                        width: 176,
                        height: 1,
                        color: const Color(0x4C979797),
                      ),
                    ),
                    Positioned(
                      right: 32,
                      top: 128,
                      child: Container(
                        width: 176,
                        height: 1,
                        color: const Color(0x4C979797),
                      ),
                    ),
                    Positioned(
                      right: 32,
                      top: 176,
                      child: Container(
                        width: 176,
                        height: 1,
                        color: const Color(0x4C979797),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),

                        child: twoWheel(hours, minutes)
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            width: 480,
                            height: 88,
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.1),
                            child: GestureDetector(
                              onTap: () {
                                if (!isValidTime) {
                                  Navigator.of(context).pop(
                                      Pair.of(-1, -1)
                                  );
                                  return;
                                }
                                final startTime = generateTime(startHour, startMinute, 0);
                                final endTime = generateTime(endHour, endMinute, _showNextDay ? 24 * 60 : 0);
                                if(startTime >= endTime) {
                                  TipsUtils.toast(content: "请选择正确的时间段");
                                } else {
                                  Navigator.of(context).pop(
                                      Pair.of(startTime, endTime)
                                  );
                                }
                              },
                              child: Container(
                                width: 240,
                                height: 56,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(28)),
                                  color: Color(0xFF267AFF),
                                ),
                                alignment: Alignment.center,
                                child: const Text('确定',
                                    style: TextStyle(
                                        color: Color(0XD8FFFFFF),
                                        fontSize: 24,
                                        fontFamily: "MideaType",
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget twoWheel(List<int> hours, List<int> minutes) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text(
                '开始时间',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
              const SizedBox(
                width: 1,
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 50,
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.007,
                          useMagnifier: true,
                          controller: FixedExtentScrollController(initialItem: startHour),
                          magnification: 1.2,
                          offAxisFraction: 0.05,
                          overAndUnderCenterOpacity: 0.65,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            debugPrint("位置：$index");
                            startHour = hours[index];
                            checkIfNextDay(startHour, startMinute, endHour, endMinute);
                          },
                          childDelegate:ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Text(
                                  numberFormat.format(hours[index]),
                                  style: const TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 24
                                  ),
                                );
                              },
                              childCount: hours.length
                          )
                      )),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
                    child: Text(
                      " : ",
                      style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 24
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 50,
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.007,
                          useMagnifier: true,
                          magnification: 1.2,
                          controller: FixedExtentScrollController(initialItem: startMinute),
                          physics: const FixedExtentScrollPhysics(),
                          overAndUnderCenterOpacity: 0.65,
                          onSelectedItemChanged: (index) {
                            debugPrint("位置：$index");
                            startMinute = minutes[index];
                            checkIfNextDay(startHour, startMinute, endHour, endMinute);
                          },
                          childDelegate:ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Text(
                                  numberFormat.format(minutes[index]),
                                  style: const TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 24
                                  ),
                                );
                              },
                              childCount: minutes.length
                          )
                      )),
                ],
              )
            ],
          ),
        ),
        const VerticalDivider(
          width: 1,
          indent: 10,
          endIndent: 100,
          color: Color(0xff979797),
        ),
        Expanded(
            child: Column(
              children: [
                const Text(
                  '结束时间',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                  ),
                ),
                const SizedBox(
                  width: 1,
                  height: 10,
                ),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ShowNextDay(key: globalKey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 50,
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                perspective: 0.007,
                                useMagnifier: true,
                                magnification: 1.2,
                                offAxisFraction: 0.05,
                                controller: FixedExtentScrollController(initialItem: endHour),
                                overAndUnderCenterOpacity: 0.65,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  debugPrint("位置：${numberFormat.format(index)}");
                                  endHour = hours[index];
                                  checkIfNextDay(startHour, startMinute, endHour, endMinute);
                                },
                                childDelegate:ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      return Text(
                                        numberFormat.format(hours[index]),
                                        style: const TextStyle(
                                            color: Color(0xffffffff),
                                            fontSize: 24
                                        ),
                                      );
                                    },
                                    childCount: hours.length
                                )
                            )),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: Text(
                            " : ",
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontSize: 24
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 50,
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                perspective: 0.007,
                                useMagnifier: true,
                                magnification: 1.2,
                                controller: FixedExtentScrollController(initialItem: endMinute),
                                physics: const FixedExtentScrollPhysics(),
                                overAndUnderCenterOpacity: 0.65,
                                onSelectedItemChanged: (index) {
                                  debugPrint("位置：$index");
                                  endMinute = minutes[index];
                                  checkIfNextDay(startHour, startMinute, endHour, endMinute);
                                },
                                childDelegate:ListWheelChildBuilderDelegate(
                                    builder: (context, index) {
                                      return Text(
                                        numberFormat.format(minutes[index]),
                                        style: const TextStyle(
                                            color: Color(0xffffffff),
                                            fontSize: 24
                                        ),
                                      );
                                    },
                                    childCount: minutes.length
                                )
                            )),
                      ],
                    )
                  ],
                ),
              ],
            )
        )
      ],
    );
  }

  void checkIfNextDay(int startHour, int startMinute, int endHour, int endMinute) {
    final startTime = generateTime(startHour, startMinute, 0);
    final endTime = generateTime(endHour, endMinute, 0);
    debugPrint('startTime = $startTime endTime = $endTime}');
    globalKey.currentState!.control(_showNextDay = startTime > endTime);
  }

  int generateTime(int hour, int minute, int offset) {
    return (hour * 60 + minute).floor() + offset;
  }

}

@immutable
class ShowNextDay extends StatefulWidget {

  const ShowNextDay({super.key});

  @override
  State<StatefulWidget> createState() => _ShowNextState();

}

class _ShowNextState extends State<ShowNextDay> {
  /// 是否显示第二天
  bool showNextDay = false;
  /// 控制是否显示
  void control(bool show) {
    setState(() {
      showNextDay = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(" _ShowNextState => build");
    return Visibility(
      visible: showNextDay,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 32),
        child: Text(
          "第二天",
          style: TextStyle(
              color: Colors.blue,
              fontSize: 16
          ),
        ),
      ),
    );
  }

}