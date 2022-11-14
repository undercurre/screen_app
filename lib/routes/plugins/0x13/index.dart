import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/mode_card/index.dart';
import 'package:screen_app/widgets/plugins/param_card/index.dart';
import 'package:screen_app/widgets/plugins/nav_bar/index.dart' as nav_bar;
import 'package:screen_app/common/device_mode/0x13/index.dart';
import 'package:screen_app/widgets/plugins/single_function/index.dart';

class WifiLightPageState extends State<WifiLightPage> {
  bool power = true;
  double brightness = 0;
  double colorTemperature = 0;

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
              onLeftBtnClick: () {
                print('leftTap');
              },
              onPowerBtnClick: () {
                setState(() {
                  power = !power;
                });
              },
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
              Column(
                children: [
                  const ParamCard(
                    title: '亮度',
                    value: 60.0,
                    activeColors: [Color(0xFFFFD185), Color(0xFFFFD185)],
                  ),
                  const ParamCard(
                    title: '色温',
                    value: 60.0,
                    activeColors: [Color(0xFFFFD39F), Color(0xFF55A2FA)],
                  ),
                  ModeCard(
                    modeList: lightModes,
                    selectedKey: 'moon',
                  ),
                  SingleFunction(
                    title: '延时关灯',
                    desc: '3分钟后关灯',
                    power: power,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: power
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Image(
                        image: power
                            ? const AssetImage(
                                'assets/imgs/plugins/0x13/delay_on.png')
                            : const AssetImage(
                                'assets/imgs/plugins/0x13/delay_off.png'),
                      ),
                    ),
                  )
                ],
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
