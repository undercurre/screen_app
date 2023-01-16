import 'package:flutter/cupertino.dart';
import 'package:screen_app/routes/home/center_control/service.dart';

import '../../../widgets/mz_slider.dart';

class LightControl extends StatefulWidget {
  const LightControl({super.key});

  @override
  LightControlState createState() => LightControlState();
}

class LightControlState extends State<LightControl> {

  void lightPowerHandle(bool onOff) {
    CenterControlService.lightPowerControl(context, onOff);
  }

  void lightBrightHandle(num value, Color color) {
    CenterControlService.lightBrightnessControl(context, value);
  }

  void lightColorHandle(num value, Color color) {
    CenterControlService.lightColorTemperatureControl(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: SizedBox(
        height: 210,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                  image: AssetImage('assets/imgs/center/zhuwo.png'),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 10, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '灯光',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontFamily: 'MideaType-Regular',
                          letterSpacing: 1.0),
                    ),
                    GestureDetector(
                      onTap: () => lightPowerHandle(
                          !CenterControlService.isLightPower(context)),
                      child: Image.asset(
                        CenterControlService.isLightPower(context)
                            ? 'assets/imgs/device/on.png'
                            : 'assets/imgs/device/off.png',
                        alignment: Alignment.centerRight,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '亮度 | ${CenterControlService.lightTotalBrightness(context)}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    MzSlider(
                      value: CenterControlService.lightTotalBrightness(context),
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD185),
                        Color(0xFFFFD185)
                      ],
                      onChanged: lightBrightHandle,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 14)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '色温 | ${(3000 + (5700 - 3000) * CenterControlService.lightTotalColorTemperature(context) / 100).toInt()}K',
                        style: const TextStyle(
                            fontSize: 14, fontFamily: 'MideaType-Regular'),
                      ),
                    ),
                    MzSlider(
                      value: CenterControlService.lightTotalColorTemperature(
                          context),
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD39F),
                        Color(0xFF55A2FA)
                      ],
                      onChanged: lightColorHandle,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
