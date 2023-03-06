import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../common/utils.dart';
import '../../../widgets/mz_metal_card.dart';
import '../../../widgets/mz_notice.dart';

class CurtainControl extends StatefulWidget {
  final bool? disabled;
  final bool computedPower;

  const CurtainControl({super.key, this.disabled, required this.computedPower});

  @override
  CurtainControlState createState() => CurtainControlState();
}

class CurtainControlState extends State<CurtainControl> {
  bool disabled = false;
  bool powerValue = false;

  Future<void> curtainHandle(bool onOff) async {
    if (disabled) {
      disableHandle();
      return;
    }
    setState(() {
      powerValue = !powerValue;
    });
    var res = await CenterControlService.curtainControl(context, onOff);
    if (res) {
    } else {
      setState(() {
        powerValue = !powerValue;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    disabled = widget.disabled ?? false;
    powerValue = widget.computedPower;
  }

  @override
  void didUpdateWidget(covariant CurtainControl oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.computedPower != oldWidget.computedPower) {
      setState(() {
        powerValue = widget.computedPower;
      });
    }
    if (widget.disabled != oldWidget.disabled) {
      setState(() {
        disabled = widget.disabled ?? false;
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
                  width: 103,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 23),
                    child: SizedBox(
                      height: 168,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => curtainHandle(false),
                            child: Opacity(
                              opacity:
                                  CenterControlService.isCurtainPower(context)
                                      ? 1
                                      : 0.48,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/imgs/device/chuanglian-kai.png",
                                    width: 42,
                                    height: 42,
                                  ),
                                  const Text(
                                    '窗帘开',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => curtainHandle(true),
                            child: Opacity(
                              opacity:
                                  !CenterControlService.isCurtainPower(context)
                                      ? 1
                                      : 0.48,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/imgs/device/chuanglian-guan.png",
                                    width: 42,
                                    height: 42,
                                  ),
                                  const Text(
                                    '窗帘关',
                                    style: TextStyle(color: Color(0xFFFFFFFF)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              ]
            : [
                MzMetalCard(
                  width: 103,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 23),
                    child: SizedBox(
                      height: 168,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => curtainHandle(true),
                            child: Opacity(
                              opacity:
                                  powerValue
                                      ? 1
                                      : 0.48,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/imgs/device/chuanglian-kai.png",
                                    width: 42,
                                    height: 42,
                                  ),
                                  const Text(
                                    '窗帘开',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => curtainHandle(false),
                            child: Opacity(
                              opacity:
                                  !powerValue
                                      ? 1
                                      : 0.48,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/imgs/device/chuanglian-guan.png",
                                    width: 42,
                                    height: 42,
                                  ),
                                  const Text(
                                    '窗帘关',
                                    style: TextStyle(color: Color(0xFFFFFFFF)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
