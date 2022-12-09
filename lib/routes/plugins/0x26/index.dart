import 'package:provider/provider.dart';

import '../../../states/device_change_notifier.dart';
import './service.dart';
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

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     print(2);
  //     final args = ModalRoute.of(context)?.settings.arguments as Map;
  //     deviceId = args['deviceId'];
  //     deviceName = args['deviceName'] ?? '浴霸';
  //     BaseService.updateDeviceDetail(this);
  //   });
  // }

  void loadData(DeviceListModel model) async {
    if (deviceId == '0') {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
    }
    // 先判断有没有这个id，没有说明设备已被删除
    final index = model.deviceList.indexWhere((element) => element.applianceCode == deviceId);
    print(index);
  }

  @override
  Widget build(BuildContext context) {
    loadData(context.watch<DeviceListModel>());
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
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ModeCard(
                            modeList: bathroomMasterMode,
                            selectedKeys: runMode,
                            spacing: 40,
                            onTap: (e) =>
                                BaseService.handleModeCardClick(this, e),
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
                              onTap: (e) => BaseService.toggleNightLight(this),
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
                              onTap: (e) => BaseService.toggleDelayClose(this),
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
