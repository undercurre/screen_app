import 'package:flutter/material.dart';
import 'package:screen_app/widgets/plugins/param_card/index.dart';
import 'package:screen_app/widgets/plugins/nav_bar/index.dart' as nav_bar;

class WifiLightPageState extends State<WifiLightPage> {
  bool power = true;
  double brightness = 0;
  double colorTemperature = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
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
                children: const [
                  ParamCard(
                    title: '亮度',
                    value: 60.0,
                    activeColors: [Color(0xFFFFD185), Color(0xFFFFD185)],
                  ),
                  ParamCard(
                    title: '色温',
                    value: 60.0,
                    activeColors: [Color(0xFFFFD39F), Color(0xFF55A2FA)],
                  )
                  // GlassCard(
                  //   child: Column(
                  //     children: const [
                  //       GradientSlider(
                  //         value: 70,
                  //         activeColors: [
                  //           Color(0xFFFABC55),
                  //           Color(0xFFFFF4E8),
                  //         ],
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // GlassCard(
                  //   child: Scaffold(
                  //     backgroundColor: Colors.transparent,
                  //     body: Row(
                  //       children: [
                  //         Container(
                  //           width: 40,
                  //           height: 40,
                  //           decoration: const BoxDecoration(
                  //             borderRadius:
                  //                 BorderRadius.all(Radius.circular(20),),
                  //             color: Color(0x3FFFFFFF),
                  //           ),
                  //           child: const Icon(Icons.close,
                  //               color: Color(0x7FFFFFFF), size: 36),
                  //         ),
                  //         Container(
                  //           width: 40,
                  //           height: 40,
                  //           decoration: const BoxDecoration(
                  //             borderRadius:
                  //                 BorderRadius.all(Radius.circular(20),),
                  //             color: Color(0x3FFFFFFF),
                  //           ),
                  //           child: const Icon(
                  //             Icons.close,
                  //             color: Color(0x7FFFFFFF),
                  //             size: 36,
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
