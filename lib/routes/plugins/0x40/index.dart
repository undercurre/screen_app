import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class CoolMaster extends StatefulWidget {
  const CoolMaster({super.key});

  @override
  State<StatefulWidget> createState() => _CoolMasterState();
}

class _CoolMasterState extends State<CoolMaster> {
  Map<String, bool?> mode = <String, bool?>{};
  bool nightlight = false;
  bool delayOff = false;
  String title = '浴霸';

  @override
  void initState() {
    super.initState();
  }

  // 卡片逻辑处理
  void handleModeTap(Mode m) {
    setState(() {
      if (m.key == 'strong') {
        if (mode['strong'] != null && mode['strong']!) {
          mode['strong'] = false;
        } else {
          mode['strong'] = true;
        }
        mode['weak'] = false;
      } else if (m.key == 'weak') {
        if (mode['weak'] != null && mode['weak']!) {
          mode['weak'] = false;
        } else {
          mode['weak'] = true;
        }
        mode['strong'] = false;
      } else {
        mode[m.key] = mode[m.key] == null ? true : !mode[m.key]!;
      }
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
            title: title,
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
                        ? 'assets/imgs/plugins/0x40/liangba_light_on.png'
                        : 'assets/imgs/plugins/0x40/liangba_light_off.png'),
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
                            height: 50,
                          ),
                          ModeCard(
                            modeList: coolMasterMode,
                            selectedKeys: mode,
                            onTap: (e) => handleModeTap(e),
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
                                image: AssetImage(
                                    'assets/imgs/plugins/0x40/swing.png'),
                              ),
                            ),
                            title: '摆风',
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
                                image: AssetImage(
                                    'assets/imgs/plugins/0x40/smell.png'),
                              ),
                            ),
                            title: '异味感知',
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
