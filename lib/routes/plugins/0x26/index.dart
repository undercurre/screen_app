import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class BathroomMaster extends StatefulWidget {
  const BathroomMaster({super.key});

  @override
  State<StatefulWidget> createState() => _BathroomMasterState();
}

class _BathroomMasterState extends State<BathroomMaster> {
  String deviceId = '0';
  String deviceName = '浴霸';

  Map<String, bool?> mode = <String, bool?>{};
  bool nightlight = false;
  bool delayOff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
      deviceName = args['deviceName'];
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
          image: AssetImage('assets/imgs/plugins/common/BG.png'),
        ),
      ),
      child: Column(
        children: [
          MzNavigationBar(
            title: '浴霸',
            onLeftBtnTap: () => Navigator.pop(context),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 50,
                  child: Image(
                    image: AssetImage(mode['light'] != null && mode['light']!
                        ? 'assets/imgs/plugins/0x26/yuba_light_on.png'
                        : 'assets/imgs/plugins/0x26/yuba_light_off.png'),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 150,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ModeCard(
                            modeList: bathroomMasterMode,
                            selectedKeys: mode,
                            spacing: 40,
                            onTap: (e) => setState(() {
                              mode[e.key] =
                              mode[e.key] == null ? true : !mode[e.key]!;
                            }),
                          ),
                          FunctionCard(
                            icon: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0x38ffffff),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: const Image(
                                height: 22,
                                width: 22,
                                image: AssetImage('assets/imgs/plugins/0x26/night_light.png'),
                              ),
                            ),
                            title: '小夜灯',
                            child: MzSwitch(
                              value: nightlight,
                              onTap: (e) => setState(() {
                                nightlight = !nightlight;
                              }),
                            ),
                          ),
                          FunctionCard(
                            icon: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0x38ffffff),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: const Image(
                                height: 22,
                                width: 22,
                                image: AssetImage('assets/imgs/plugins/0x26/delay_off.png'),
                              ),
                            ),
                            title: '延时关灯',
                            child: MzSwitch(
                              value: delayOff,
                              onTap: (e) => setState(() {
                                delayOff = !delayOff;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
