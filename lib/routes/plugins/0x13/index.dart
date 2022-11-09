import 'package:flutter/material.dart';
import '../../../widgets/plugins/gredientSlider/index.dart';

class WifiLightPageState extends State<WifiLightPage> {
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
                image: AssetImage('assets/imgs/plugins/0x13/BG.png'))),
        child: Flex(direction: Axis.vertical, children: <Widget>[
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 22.0, horizontal: 24.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "照明",
                            style: TextStyle(
                                fontFamily: 'MideaType',
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none),
                          ),
                          Text(
                            "客厅",
                            style: TextStyle(
                                fontFamily: 'MideaType',
                                color: Color(0x91FFFFFF),
                                fontSize: 18,
                                height: 1.2,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none),
                          )
                        ]),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color(0x3FFFFFFF),
                      ),
                      child: const Icon(Icons.close,
                          color: Color(0x7FFFFFFF), size: 36),
                    )
                  ])),
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  const Align(
                    widthFactor: 1,
                    heightFactor: 2,
                    alignment: Alignment(-1.0, -0.63),
                    child: Image(
                        image: AssetImage(
                            'assets/imgs/plugins/0x13/dengguang.png')),
                  ),
                  Column(
                    children: [
                      Container(
                          width: 312,
                          height: 112,
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: const LinearGradient(
                                begin: Alignment(-1, 1), //右上
                                end: Alignment(0, 0.365), //左下
                                stops: [0.0, 1.0], //[渐变起始点, 渐变结束点]
                                colors: [Color(0xFF393E43), Color(0xFF333135)]),
                          ),
                          child: Column(
                            children: [GredientSlider(value: 60)],
                          )),
                      Container(
                          width: 312,
                          height: 112,
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: const LinearGradient(
                                begin: Alignment(-1, 1), //右上
                                end: Alignment(0, 0.365), //左下
                                stops: [0.0, 1.0], //[渐变起始点, 渐变结束点]
                                colors: [Color(0xFF393E43), Color(0xFF333135)]),
                          ),
                          child: Column(
                            children: [
                              GredientSlider(
                                value: 70,
                                activeColors: const [
                                  Color(0xFFFABC55),
                                  Color(0xFFFFF4E8)
                                ],
                              )
                            ],
                          )),
                      Container(
                          width: 312,
                          height: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: const LinearGradient(
                                begin: Alignment(-1, 1), //右上
                                end: Alignment(0, 0.365), //左下
                                stops: [0.0, 1.0], //[渐变起始点, 渐变结束点]
                                colors: [Color(0xFF393E43), Color(0xFF333135)]),
                          ),
                          child: Scaffold(
                              backgroundColor: Colors.transparent,
                              body: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Color(0x3FFFFFFF),
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Color(0x7FFFFFFF), size: 36),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Color(0x3FFFFFFF),
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Color(0x7FFFFFFF), size: 36),
                                  )
                                ],
                              ))),
                    ],
                  )
                ],
              )),
        ]));
  }
}

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}
