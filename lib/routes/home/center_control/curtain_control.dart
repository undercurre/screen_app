import 'package:flutter/cupertino.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/mz_metal_card.dart';

class CurtainControl extends StatefulWidget {
  @override
  CurtainControlState createState() => CurtainControlState();
}

class CurtainControlState extends State<CurtainControl> {

  void curtainHandle(bool onOff) {
    CenterControlService.curtainControl(context, onOff);
  }

  @override
  Widget build(BuildContext context) {
    return MzMetalCard(
      width: 103,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 23),
        child: SizedBox(
          height: 164,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => curtainHandle(false),
                child: Column(
                  children: [
                    !CenterControlService.isCurtainPower(context)
                        ? Image.asset(
                            "assets/imgs/device/chuanglian_icon_on.png",
                            width: 42,
                            height: 42)
                        : Image.asset(
                            "assets/imgs/device/chuanglian_icon_off.png",
                            width: 42,
                            height: 42),
                    Text(
                      '窗帘关',
                      style: TextStyle(
                          color: !CenterControlService.isCurtainPower(context)
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x7AFFFFFF)),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => curtainHandle(true),
                child: Column(
                  children: [
                    CenterControlService.isCurtainPower(context)
                        ? Image.asset(
                            "assets/imgs/device/chuanglian_icon_on.png",
                            width: 42,
                            height: 42)
                        : Image.asset(
                            "assets/imgs/device/chuanglian_icon_off.png",
                            width: 42,
                            height: 42),
                    Text(
                      '窗帘开',
                      style: TextStyle(
                          color: CenterControlService.isCurtainPower(context)
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x7AFFFFFF)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
