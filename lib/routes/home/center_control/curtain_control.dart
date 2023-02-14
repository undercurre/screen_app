import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/mz_metal_card.dart';
import '../../../widgets/mz_notice.dart';

class CurtainControl extends StatefulWidget {
  final bool? disabled;

  const CurtainControl({super.key, this.disabled});

  @override
  CurtainControlState createState() => CurtainControlState();
}

class CurtainControlState extends State<CurtainControl> {
  void curtainHandle(bool onOff) {
    if (widget.disabled ?? false) {
      disableHandle();
      return;
    }
    CenterControlService.curtainControl(context, onOff);
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: widget.disabled ?? false
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
                            onTap: () => curtainHandle(false),
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
              ],
      ),
    );
  }
}
