import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/widgets/index.dart';

import './api.dart';
import './mode_list.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_change_notifier.dart';

class CoolMaster extends StatefulWidget {
  const CoolMaster({super.key});

  @override
  State<StatefulWidget> createState() => _CoolMasterState();
}

class _CoolMasterState extends State<CoolMaster> {
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;
  String deviceId = '0';
  String deviceName = '凉霸';
  late DeviceListModel deviceList;
  late DeviceEntity device;
  late EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  Map<String, bool?> mode = <String, bool?>{};
  int windSpeed = 0;
  bool swing = false;
  bool smelly = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initView();
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
        String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
        Map<String,dynamic> eventMap = json.decode(event);
        String nodeId = eventMap['nodeId'] ?? "";
        var detail = context.read<DeviceListModel>().getDeviceDetailById(args['deviceId']);

        if (nodeId.isEmpty) {
          if (detail['deviceId'] == arg['applianceCode']) {
            handleRefresh();
            luaDataConvToState();
          }
        } else {
          if ((detail['masterId'] as String).isNotEmpty && detail['detail']?['nodeId'] == nodeId) {
            handleRefresh();
            luaDataConvToState();
          }
        }
      }));

      Push.listen("appliance/status/report", _reportCallback = ((arg) {
        var detail = context.read<DeviceListModel>().getDeviceDetailById(args['deviceId']);
        if (arg.containsKey('applianceId')) {
          if (detail['deviceId'] == arg['applianceId']) {
            handleRefresh();
            luaDataConvToState();
          }
        }
      }));
    });
  }

  initView() {
    deviceList = context.read<DeviceListModel>();
    // 第一次加载，先从路由取deviceId
    if (deviceId == '0') {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
      setState(() {
        mode["ventilation"] = true;
      });
    }
    // 先判断有没有这个id，没有说明设备已被删除
    final index = deviceList.deviceList
        .indexWhere((element) => element.applianceCode == deviceId);
    if (index >= 0) {
      device = deviceList.deviceList[index];
      deviceName = deviceList.deviceList[index].name;
      luaDataConvToState();
    } else {
      // todo: 设备已被删除，应该弹窗并让用户退出
    }
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
                      child: EasyRefresh(
                        controller: refreshController,
                        header: const ClassicHeader(
                          dragText: '下拉刷新',
                          armedText: '释放执行刷新',
                          readyText: '正在刷新...',
                          processingText: '正在刷新...',
                          processedText: '刷新完成',
                          noMoreText: '没有更多信息',
                          failedText: '失败',
                          messageText: '上次更新 %T',
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                        onRefresh: handleRefresh,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ModeCard(
                                  modeList: coolMasterMode,
                                  selectedKeys: mode,
                                  onTap: (e) => handleModeTap(e),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: FunctionCard(
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
                                title: '异味感应',
                                child: MzSwitch(
                                  value: smelly,
                                  onTap: (e) => toggleSmelly(),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  /// lua上报状态转widget状态
  void luaDataConvToState() {
    if (device.detail == null) {
      return;
    }
    Map<String, dynamic> data = device.detail!;
    if (data['mode'] == 'close_all') {
      mode[strong.key] = false;
      mode[weak.key] = false;
      mode[ventilation.key] = false;
    } else if (data['mode'] == 'blowing') {
      mode[strong.key] = int.parse(data['blowing_speed']) >= 67 ? true : false;
      mode[weak.key] = int.parse(data['blowing_speed']) < 67 ? true : false;
      mode[ventilation.key] = false;
    } else if (data['mode'] == 'ventilation') {
      mode[strong.key] = false;
      mode[weak.key] = false;
      mode[ventilation.key] = true;
    } else if (data['mode'].split(',').length == 2) {
      mode[strong.key] = int.parse(data['blowing_speed']) >= 67 ? true : false;
      mode[weak.key] = int.parse(data['blowing_speed']) < 67 ? true : false;
      mode[ventilation.key] = true;
    }
    if (data['light_mode'] == 'close_all') {
      mode[light.key] = false;
    } else if (data['light_mode'] == 'main_light') {
      mode[light.key] = true;
    }
    if (data['smelly_enable'] == 'off') {
      smelly = false;
    } else if (data['smelly_enable'] == 'on') {
      smelly = true;
    }
    if (data['blowing_direction'] == '253') {
      swing = true;
    } else if (data['blowing_direction'] == '254') {
      swing = false;
    }
    setState(() {
      swing = swing;
      smelly = smelly;
      mode = mode;
    });
    // 物模型的状态转换
    // final res = await BaseApi.getDetail(deviceId);
    // if (res.success) {
    //   setState(() {
    //     smelly = res.result['smelly'];
    //     swing = res.result['windAngle'] == 253; // 253代表摆风 254代表停止
    //     mode = {
    //       'strong': res.result['blowing'] && res.result['windSpeed'] >= 67,
    //       'weak': res.result['blowing'] && res.result['windSpeed'] < 67,
    //       'light': res.result['light'],
    //       'ventilation': res.result['ventilation'],
    //     };
    //   });
    // }
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
    setState(() {
      mode = mode;
    });
    Timer(const Duration(milliseconds: 1000), () => {handleRefresh()});
  }

  handleRefresh() async {
    final index = deviceList.deviceList
        .indexWhere((element) => element.applianceCode == deviceId);
    try {
      final res = await DeviceListApiImpl().getDeviceDetail(device);
      deviceList.deviceList[index].detail = res;
      deviceList.notifyListeners();
      initView();
    } catch (e) {
      // 接口请求失败
      print(e);
    } finally {
      refreshController.finishRefresh();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Push.dislisten("gemini/appliance/event", _eventCallback);
    Push.dislisten("appliance/status/report",_reportCallback);
  }

  /// 开关摆风
  void toggleSwing() {
    setState(() {
      swing = !swing;
    });
    BaseApi.luaControl(deviceId, {'blowing_direction': swing ? '253' : '254'});
    Timer(const Duration(milliseconds: 1000), () => {handleRefresh()});
  }

  void toggleSmelly() {
    setState(() {
      smelly = !smelly;
    });
    BaseApi.luaControl(deviceId, {'smelly_enable': smelly ? 'on' : 'off'});
    Timer(const Duration(milliseconds: 1000), () => {handleRefresh()});
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
