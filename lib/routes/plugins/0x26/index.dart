import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/routes/plugins/0x26/data_adapter.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/global.dart';
import '../../../mixins/throttle.dart';
import '../../../models/mz_response_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/util/debouncer.dart';
import './api.dart';
import './mode_list.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_change_notifier.dart';

class BathroomMaster extends StatefulWidget {
  const BathroomMaster({super.key});

  @override
  State<StatefulWidget> createState() => BathroomMasterState();
}

class BathroomMasterState extends State<BathroomMaster> with Throttle {
  WIFIYubaDataAdapter? dataAdapter;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{
      'light': false,
      'blowing': false,
      'heating': false,
      'bath': false,
      'ventilation': false,
      'drying': false,
    };
    if (dataAdapter?.data!.light_mode.contains('main_light') ?? false) {
      selectKeys['light'] = true;
    }
    selectKeys.keys.toList().forEach((element) {
      if (dataAdapter?.data!.mode.contains(element) ?? false) {
        selectKeys[element] = true;
      }
    });
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        dataAdapter = args?['adapter'];
      });
      dataAdapter?.bindDataUpdateFunction(updateCallback);
    });
  }

  @override
  void dispose() {
    super.dispose();
    dataAdapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);

    String getDeviceName() {
      if (deviceListModel.deviceListHomlux.isEmpty && deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return deviceListModel.getDeviceName(deviceId: dataAdapter?.getDeviceId(), maxLength: 8, startLength: 5, endLength: 2);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF272F41),
            Color(0xFF080C14),
          ],
        ),
      ),
      child: Column(
        children: [
          MzNavigationBar(
            onLeftBtnTap: goBack,
            onRightBtnTap: () {
              dataAdapter?.power(false);
            },
            title: getDeviceName(),
            power: dataAdapter?.getPowerStatus() ?? false,
            hasPower: true,
          ),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 50,
                  child: Image(
                    image: AssetImage(dataAdapter?.getCardStatus()?['light_mode'] != 'close_all'
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
                        onRefresh: () {
                          dataAdapter?.fetchData();
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 16, bottom: 16),
                                child: ModeCard(
                                  modeList: bathroomMasterMode,
                                  selectedKeys: getSelectedKeys(),
                                  spacing: 40,
                                  onTap: (e) {
                                    if (e.key == 'light') {
                                      dataAdapter?.controlLightMode('main_light');
                                    } else {
                                      dataAdapter?.controlMode(e.key);
                                    }
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: FunctionCard(
                                  icon: const Image(
                                    height: 40,
                                    width: 40,
                                    image: AssetImage('assets/newUI/yubamodel/night_light.png'),
                                  ),
                                  title: '小夜灯',
                                  child: MzSwitch(
                                    value: dataAdapter?.data!.light_mode == 'night_light',
                                    onTap: (e) {
                                      dataAdapter?.controlLightMode('night_light');
                                    },
                                  ),
                                ),
                              ),
                              // FunctionCard(
                              //   icon: const Image(
                              //     height: 40,
                              //     width: 40,
                              //     image: AssetImage('assets/newUI/yubamodel/delay.png'),
                              //   ),
                              //   title: '延时关机',
                              //   child: MzSwitch(
                              //     disabled: !(dataAdapter?.getPowerStatus() ?? false),
                              //     value: dataAdapter?.data!.delay_enable == 'on',
                              //     onTap: (e) {
                              //       dataAdapter?.controlDelay();
                              //     },
                              //   ),
                              // ),
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
}
