import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/mode_card/index.dart';
import 'package:screen_app/widgets/plugins/param_card/index.dart';
import 'package:screen_app/widgets/plugins/nav_bar/index.dart' as nav_bar;
import 'package:screen_app/common/device_mode/0x13/index.dart';
import 'package:screen_app/widgets/plugins/single_function/index.dart';

import '../../../common/device_mode/mode.dart';

class WifiLightPageState extends State<WifiLightPage> {
  bool power = true;
  num brightness = 0;
  num colorTemperature = 0;
  String screenModel = 'mannel';
  String timeOff = '0';

  void goBack() {
    Navigator.pop(context);
  }

  void powerHandle() {
    setState(() {
      power = !power;
    });
  }

  void delayHandle() {
    setState(() {
      if (timeOff == '0') {
        timeOff = '3';
      } else {
        timeOff = '0';
      }
    });
  }

  void modeHandle(Mode mode) {
    setState(() {
      screenModel = mode.key;
    });
    print(screenModel);
  }

  void brightnessHandle(num value, Color activeColor) {
    print(value);
    setState(() {
      brightness = value;
    });
  }

  void colorTemperatureHandle(num value, Color activeColor) {
    print(colorTemperature);
    setState(() {
      colorTemperature = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/imgs/plugins/0x13/BG.png'),
        ),
      ),
      child: Flex(direction: Axis.vertical, children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              maxHeight: 60.0,
            ),
            child: nav_bar.NavigationBar(
              onLeftBtnClick: goBack,
              onPowerBtnClick: powerHandle,
              title: 'Wi-Fi吸顶灯',
              power: power,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const Align(
                widthFactor: 1,
                heightFactor: 2,
                alignment: Alignment(-1.0, -0.63),
                child: Image(
                  image: AssetImage('assets/imgs/plugins/0x13/dengguang.png'),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    ParamCard(
                      title: '亮度',
                      value: brightness,
                      activeColors: const [
                        Color(0xFFFFD185),
                        Color(0xFFFFD185)
                      ],
                      onChanged: brightnessHandle,
                    ),
                    ParamCard(
                      title: '色温',
                      value: colorTemperature,
                      activeColors: const [
                        Color(0xFFFFD39F),
                        Color(0xFF55A2FA)
                      ],
                      onChanged: colorTemperatureHandle,
                    ),
                    ModeCard(
                      modeList: lightModes,
                      selectedKey: screenModel,
                      onClick: modeHandle,
                    ),
                    SingleFunction(
                      title: '延时关灯',
                      desc:
                          timeOff == '0' ? '未设置' : '${int.parse(timeOff)}分钟后关灯',
                      child: Listener(
                        onPointerDown: (e) => delayHandle(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: timeOff == '0'
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Image(
                            image: AssetImage(timeOff == '0'
                                ? 'assets/imgs/plugins/0x13/delay_on.png'
                                : 'assets/imgs/plugins/0x13/delay_off.png'),
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
      ]),
    );
  }
}

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}
