import 'package:easy_refresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import '../../../models/device_entity.dart';
import '../../../states/device_change_notifier.dart';
import './api.dart';
import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class BathroomMaster extends StatefulWidget {
  const BathroomMaster({super.key});

  @override
  State<StatefulWidget> createState() => BathroomMasterState();
}

class BathroomMasterState extends State<BathroomMaster> {
  String deviceId = '0';
  String deviceName = '浴霸';
  String controlType = 'lua'; // todo: 后面需要加上判断使用物模型还是lua控制
  bool isSingleMotor = true; // todo: 添加单双电机浴霸判断
  late DeviceListModel deviceList;
  late DeviceEntity device;
  late EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  Map<String, bool> runMode = <String, bool>{};
  bool mainLight = false;
  bool nightLight = false;
  bool delayClose = false;
  int delayTime = 1;

  // 用于lua查询或者物模型查询后设置state
  void setStateCallBack({
    mainLight,
    nightLight,
    delayClose,
    runMode,
    delayTime,
  }) {
    setState(() {
      this.mainLight = mainLight ?? this.mainLight;
      this.nightLight = nightLight ?? this.nightLight;
      this.delayClose = delayClose ?? this.delayClose;
      this.runMode = runMode ?? this.runMode;
      this.delayTime = delayTime ?? this.delayTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceList = context.watch<DeviceListModel>();
    // 第一次加载，先从路由取deviceId
    if (deviceId == '0') {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
    }
    // 先判断有没有这个id，没有说明设备已被删除
    final index = deviceList.deviceList
        .indexWhere((element) => element.applianceCode == deviceId);
    if (index >= 0) {
      device = deviceList.deviceList[index];
      deviceName = deviceList.deviceList[index].name;
      luaDeviceDetailToState();
    } else {
      // todo: 设备已被删除，应该弹窗并让用户退出
    }
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
                    image: AssetImage(
                        runMode['light'] != null && runMode['light']!
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
                                height: 10,
                              ),
                              ModeCard(
                                modeList: bathroomMasterMode,
                                selectedKeys: runMode,
                                spacing: 40,
                                onTap: (e) => handleModeCardClick(e),
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
                                        'assets/imgs/plugins/0x26/night_light.png'),
                                  ),
                                ),
                                title: '小夜灯',
                                child: MzSwitch(
                                  value: nightLight,
                                  onTap: (e) => toggleNightLight(),
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
                                        'assets/imgs/plugins/0x26/delay_off.png'),
                                  ),
                                ),
                                title: '延时关机',
                                child: MzSwitch(
                                  value: delayClose,
                                  onTap: (e) => toggleDelayClose(),
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

  handleRefresh() async {
    final index = deviceList.deviceList
        .indexWhere((element) => element.applianceCode == deviceId);
    try {
      final res = await DeviceListApiImpl().getDeviceDetail(device);
      deviceList.deviceList[index].detail = res;
      deviceList.notifyListeners();
    } catch (e) {
      // 接口请求失败
      print(e);
    } finally {
      refreshController.finishRefresh();
    }
  }

  void luaDeviceDetailToState() {
    final detail = device.detail!;
    final activeModeList = (detail['mode'] as String).split(',');
    for (var mode in bathroomMasterMode) {
      runMode[mode.key] = activeModeList.contains(mode.key);
    }
    runMode['light'] = detail['light_mode'] == 'main_light' ||
        detail['light_mode'] == 'night_light';
    setState(() {
      delayClose = detail['delay_enable'] == 'on';
      delayTime = int.parse(detail['delay_time']);
      mainLight = detail['light_mode'] == 'main_light';
      nightLight = detail['light_mode'] == 'night_light';
      runMode = runMode;
    });
  }

  void toggleNightLight() async {
    final newValue = !nightLight;
    device.detail!['light_mode'] = newValue ? 'night_light' : 'close_all';
    deviceList.setProviderDeviceInfo(device);
    // deviceList.notifyListeners();
    // deviceList.setDeviceDetail(device);
    await BaseApi.luaControl(
      deviceId,
      {'light_mode': newValue ? 'night_light' : 'close_all'},
    );
  }

  void toggleDelayClose() {
    delayClose = !delayClose;
    // device.detail['']
    if (delayClose) {
      device.detail!['delay_enable'] = 'on';
      device.detail!['delay_time'] = '15';
      BaseApi.luaControl(deviceId, {
        'delay_enable': 'on',
        'delay_time': '15',
      });
    } else {
      device.detail!['delay_enable'] = 'off';
      BaseApi.luaControl(deviceId, {
        'delay_enable': 'off',
      });
    }
    deviceList.setProviderDeviceInfo(device);
  }

  void handleModeCardClick(Mode mode) async {
    if (mode.key == light.key) {
      // 如果主灯和夜灯都是关则打开主灯
      if (!mainLight && !nightLight) {
        device.detail!['light_mode'] = 'main_light';
        BaseApi.luaControl(
          deviceId,
          {'light_mode': 'main_light'},
        );
      } else {
        // 如果主灯或者夜灯打开则全部关闭
        device.detail!['light_mode'] = 'close_all';
        BaseApi.luaControl(
          deviceId,
          {'light_mode': 'close_all'},
        );
      }
      deviceList.setProviderDeviceInfo(device);
      return;
    } else {
      // 如果当前是处于某个mode，则关闭那个mode，否则打开某个mode
      runMode[mode.key] =
          runMode[mode.key] != null && runMode[mode.key]! ? false : true;
      device.detail!['mode'] = runMode[mode.key]! ? mode.key : '';
    }
    deviceList.setProviderDeviceInfo(device);
    final res = await BaseApi.luaControl(
      deviceId,
      {'mode': runMode[mode.key]! ? mode.key : ''},
    );
    device.detail = res.result['status'];
    deviceList.setProviderDeviceInfo(device);
  }
}
