import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/mz_metal_card.dart';

class CurtainControl extends StatefulWidget {
  final bool? disabled;

  const CurtainControl({super.key, this.disabled});

  @override
  CurtainControlState createState() => CurtainControlState();
}

class CurtainControlState extends State<CurtainControl> {
  void curtainHandle(bool onOff) {
    if (widget.disabled ?? false) return;
    CenterControlService.curtainControl(context, onOff);
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
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(55, 55, 55, 0.50)),
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
              ],
      ),
    );
  }
}
