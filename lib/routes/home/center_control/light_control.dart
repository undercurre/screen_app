import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/center_control/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../widgets/mz_slider.dart';

class LightControl extends StatefulWidget {
  final bool? disabled;

  const LightControl({super.key, this.disabled});

  @override
  LightControlState createState() => LightControlState();
}

class LightControlState extends State<LightControl> {
  num lightnessValue = 0;
  num colorTempValue = 0;
  bool dataLock = false;

  void lightPowerHandle(bool onOff) {
    if (widget.disabled ?? false) return;
    CenterControlService.lightPowerControl(context, onOff);
  }

  void lightBrightHandle(num value, Color color) {
    setState(() {
      lightnessValue = value;
    });
    CenterControlService.lightBrightnessControl(context, value);
  }

  void lightColorHandle(num value, Color color) {
    setState(() {
      colorTempValue = value;
    });
    CenterControlService.lightColorTemperatureControl(context, value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        lightnessValue = CenterControlService.lightTotalBrightness(context);
        colorTempValue = CenterControlService.lightTotalColorTemperature(context);
      });
    });
  }

@override
Widget build(BuildContext context) {
  var lightList = context
      .watch<DeviceListModel>()
      .deviceList;
  return Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 16),
    child: Stack(
      children: widget.disabled ?? false
          ? [
        Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
                image: AssetImage('assets/imgs/center/zhuwo.png'),
                fit: BoxFit.cover),
          ),
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
                      '',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontFamily: 'MideaType-Regular',
                          letterSpacing: 1.0),
                    ),
                    GestureDetector(
                      onTap: () =>
                          lightPowerHandle(
                              !CenterControlService.isLightPower(lightList)),
                      child: Image.asset(
                        CenterControlService.isLightPower(lightList)
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
                        '亮度 | $lightnessValue%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    MzSlider(
                      value: lightnessValue,
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD185),
                        Color(0xFFFFD185)
                      ],
                      onChanged: lightBrightHandle,
                      onChanging: lightBrightHandle,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 14)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '色温 | ${(3000 + (5700 - 3000) * colorTempValue / 100)
                            .toInt()}K',
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'MideaType-Regular'),
                      ),
                    ),
                    MzSlider(
                      value: colorTempValue,
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD39F),
                        Color(0xFF55A2FA)
                      ],
                      onChanged: lightColorHandle,
                      onChanging: lightColorHandle,
                    )
                  ],
                ),
              ],
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
        const Positioned(
          left: 14,
          top: 16,
          child: Text(
            '灯光',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontFamily: 'MideaType-Regular',
                letterSpacing: 1.0),
          ),
        )
      ]
          : [
        Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
                image: AssetImage('assets/imgs/center/zhuwo.png'),
                fit: BoxFit.cover),
          ),
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
                      onTap: () =>
                          lightPowerHandle(
                              !CenterControlService.isLightPower(lightList)),
                      child: Image.asset(
                        CenterControlService.isLightPower(lightList)
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
                        '亮度 | $lightnessValue%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    MzSlider(
                      value: lightnessValue,
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD185),
                        Color(0xFFFFD185)
                      ],
                      onChanged: lightBrightHandle,
                      onChanging: lightBrightHandle,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 14)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '色温 | ${(3000 + (5700 - 3000) *
                            colorTempValue / 100).toInt()}K',
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'MideaType-Regular'),
                      ),
                    ),
                    MzSlider(
                      value: colorTempValue,
                      width: 290,
                      padding: const EdgeInsets.all(0),
                      activeColors: const [
                        Color(0xFFFFD39F),
                        Color(0xFF55A2FA)
                      ],
                      onChanged: lightColorHandle,
                      onChanging: lightColorHandle,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}}
