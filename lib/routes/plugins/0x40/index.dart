import './api.dart';
import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class CoolMaster extends StatefulWidget {
  const CoolMaster({super.key});

  @override
  State<StatefulWidget> createState() => _CoolMasterState();
}

class _CoolMasterState extends State<CoolMaster> {
  String deviceId = '0';
  String deviceName = '凉霸';

  Map<String, bool?> mode = <String, bool?>{};
  int windSpeed = 0;
  bool swing = false;
  bool smelly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
      deviceName = args['deviceName'] ?? '浴霸';
      final res = await BaseApi.getDetail(deviceId);
      if (res.success) {
        setState(() {
          smelly = res.result['smelly'];
          swing = res.result['windAngle'] == 253; // 253代表摆风 254代表停止
          mode = {
            'strong': res.result['blowing'] && res.result['windSpeed'] >= 67,
            'weak': res.result['blowing'] && res.result['windSpeed'] < 67,
            'light': res.result['light'],
            'ventilation': res.result['ventilation'],
          };
        });
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
            title: deviceName,
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
                              value: swing,
                              disabled: swingDisabled(),
                              onTap: (e) => toggleSwing(),
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
                              value: smelly,
                              onTap: (e) => toggleSmelly(),
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

  bool swingDisabled() {
    if (mode[strong.key] == null || mode[weak.key] == null) {
      return true;
    }
    if (mode[strong.key] == false && mode[weak.key] == false) {
      return true;
    }
    return false;
  }

  void handleModeTap(Mode m) {
    if (m.key == strong.key) {
      if (mode[m.key]!) {
        mode[m.key] = false;
        // 已打开强风，则关闭吹风
        BaseApi.luaControl(deviceId, {'mode': ''});
        setState(() {
          swing = false; // 关闭吹风同时会关闭摆风
        });
      } else if (mode[weak.key]!) {
        // 已打开弱风， 切换至强风
        BaseApi.luaControl(
            deviceId, {'mode': 'blowing', 'blowing_speed': '100'});
        mode[strong.key] = true;
        mode[weak.key] = false;
        mode[ventilation.key] = false; // 打开强风会同时关闭换气
      } else {
        // 打开强风
        BaseApi.luaControl(
            deviceId, {'mode': 'blowing', 'blowing_speed': '100'});
        mode[m.key] = true;
        mode[ventilation.key] = false; // 打开强风会同时关闭换气
      }
      setState(() {
        mode = mode;
      });
    } else if (m.key == weak.key) {
      if (mode[m.key]!) {
        mode[m.key] = false;
        // 已打开弱风，则关闭吹风
        BaseApi.luaControl(
            deviceId, {'mode': mode[ventilation.key]! ? 'ventilation' : ''});
        setState(() {
          swing = false; // 关闭吹风同时会关闭摆风
        });
      } else if (mode[strong.key]!) {
        // 已打开强风， 切换至弱风
        BaseApi.luaControl(deviceId, {'blowing_speed': '1'});
        mode[weak.key] = true;
        mode[strong.key] = false;
      } else {
        // 打开弱风
        BaseApi.luaControl(deviceId, {
          'mode': mode[ventilation.key]! ? 'blowing,ventilation' : 'blowing',
          'blowing_speed': '1'
        });
        mode[m.key] = true;
      }
      setState(() {
        mode = mode;
      });
    } else if (m.key == light.key) {
      mode[m.key] = mode[m.key]! ? false : true;
      BaseApi.luaControl(deviceId, {
        'light_mode': mode[m.key]! ? 'main_light' : 'close_all',
      });
      setState(() {
        mode = mode;
      });
    } else if (m.key == ventilation.key) {
      mode[m.key] = mode[m.key]! ? false : true;
      if (mode[strong.key]!) {
        mode[strong.key] = false;
        mode[weak.key] = true;
        // 如果是已打开强风，则需要设置成弱风
        BaseApi.luaControl(
            deviceId, {'mode': 'blowing,ventilation', 'blowing_speed': '1'});
      } else {
        var modeList = <String>[];
        if (mode[weak.key]!) {
          modeList.add('blowing');
        }
        if (mode[m.key]!) {
          modeList.add('ventilation');
        }
        BaseApi.luaControl(deviceId, {
          'mode': modeList.join(','),
        });
      }
      setState(() {
        mode = mode;
      });
    }
  }

  /// 开关摆风
  void toggleSwing() {
    setState(() {
      swing = !swing;
    });
    BaseApi.luaControl(deviceId, {'blowing_direction': swing ? '253' : '254'});
  }

  void toggleSmelly() {
    setState(() {
      smelly = !smelly;
    });
    BaseApi.luaControl(deviceId, {'smelly_enable': smelly ? 'on' : 'off'});
  }
}

// 物模型操作，物模型未上生产环境
// void handleModeTap(Mode m) {
//   if (m.key == strong.key) {
//     if (mode[m.key]!) {
//       mode[m.key] = false;
//       // 已打开强风，则关闭吹风
//       BaseApi.toggleBlowing(deviceId, mode[m.key]!);
//     } else if (mode[weak.key]!) {
//       // 已打开弱风， 切换至强风
//       BaseApi.setWindSpeed(deviceId, 100);
//       mode[strong.key] = true;
//       mode[weak.key] = false;
//       mode[ventilation.key] = false; // 打开强风会同时关闭换气
//     } else {
//       // 打开强风
//       BaseApi.setWindSpeedAndBlowing(deviceId, 100, true);
//       mode[m.key] = true;
//       mode[ventilation.key] = false; // 打开强风会同时关闭换气
//     }
//     setState(() {
//       mode = mode;
//     });
//   } else if (m.key == weak.key) {
//     if (mode[m.key]!) {
//       mode[m.key] = false;
//       // 已打开弱风，则关闭吹风
//       BaseApi.toggleBlowing(deviceId, mode[m.key]!);
//     } else if (mode[strong.key]!) {
//       // 已打开强风， 切换至弱风
//       BaseApi.setWindSpeed(deviceId, 1);
//       mode[weak.key] = true;
//       mode[strong.key] = false;
//     } else {
//       // 打开弱风
//       BaseApi.setWindSpeedAndBlowing(deviceId, 1, true);
//       mode[m.key] = true;
//     }
//     setState(() {
//       mode = mode;
//     });
//   } else if (m.key == light.key) {
//     mode[m.key] = mode[m.key]! ? false : true;
//     BaseApi.toggleLightMode(deviceId, mode[m.key]!);
//     setState(() {
//       mode = mode;
//     });
//   } else if (m.key == ventilation.key) {
//     mode[m.key] = mode[m.key]! ? false : true;
//     if (mode[strong.key]!) {
//       // 如果当前是强风则会切换至弱风
//       mode[strong.key] = false;
//       mode[weak.key] = true;
//       BaseApi.setWindSpeedAndVentilation(deviceId, 1, mode[m.key]!);
//     } else {
//       BaseApi.toggleVentilation(deviceId, mode[m.key]!);
//     }
//     setState(() {
//       mode = mode;
//     });
//   }
// }
//
// /// 开关摆风
// void toggleSwing() {
//   setState(() {
//     swing = !swing;
//   });
//   BaseApi.setSwingAngle(deviceId, swing ? 253 : 254);
// }
//
// void toggleSmelly() {
//   setState(() {
//     smelly = !smelly;
//   });
//   BaseApi.toggleSmelly(deviceId, smelly);
// }
