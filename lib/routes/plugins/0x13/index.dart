
import 'dart:async';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/gateway_platform.dart';
import '../../../states/device_list_notifier.dart';
import '../../../widgets/event_bus.dart';
import './mode_list.dart';
import 'data_adapter.dart';

class WifiLightPageState extends State<WifiLightPage> with Throttle {
  WIFILightDataAdapter? dataAdapter;
  Mode? modeTap;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    if (modeTap != null) {
      selectKeys[modeTap!.key] = true;
    } else {
      selectKeys[dataAdapter?.data!.screenModel ?? 'manual'] = true;
    }
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
    dataAdapter?.destroy();
  }

  void updateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);

    String getDeviceName() {
      if (deviceListModel.deviceListHomlux.length == 0 &&
          deviceListModel.deviceListMeiju.length == 0) {
        return '加载中';
      }

      return deviceListModel.getDeviceName(
        deviceId: dataAdapter?.getDeviceId(),
      );
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
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              child: LightBall(
                brightness: formatValue(dataAdapter?.data!.brightness ?? 1),
                colorTemperature: 100 - formatValue(dataAdapter?.data!.colorTemp ?? 0),
              )),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    maxHeight: 60.0,
                  ),
                  child: MzNavigationBar(
                    onLeftBtnTap: goBack,
                    onRightBtnTap: () {
                      dataAdapter?.controlPower();
                    },
                    title: getDeviceName() ?? '',
                    power: dataAdapter?.data!.power ?? false,
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
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
                        child: Row(
                          children: [
                            const Align(
                              widthFactor: 1,
                              heightFactor: 2,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          minValue: 1,
                                          maxValue: 100,
                                          title: '亮度',
                                          disabled: dataAdapter?.data!.power ?? true ? false : true,
                                          value: max(1, dataAdapter?.data!.brightness ?? 1),
                                          activeColors: const [
                                            Color(0xFFFFD185),
                                            Color(0xFFFFD185)
                                          ],
                                          onChanged: dataAdapter?.controlBrightness,
                                          onChanging: dataAdapter?.controlBrightness,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          title: '色温',
                                          unit: "K",
                                          customMin: dataAdapter?.data?.minColorTemp ?? 2700,
                                          customMax: dataAdapter?.data?.maxColorTemp ?? 6500,
                                          disabled: dataAdapter?.data!.power ?? true ? false : true,
                                          value: dataAdapter?.data!.colorTemp ?? 0,
                                          activeColors: const [
                                            Color(0xFFFFD39F),
                                            Color(0xFF55A2FA)
                                          ],
                                          onChanged: dataAdapter?.controlColorTemperature,
                                          onChanging: dataAdapter?.controlColorTemperature,
                                        ),
                                      ),
                                      // if (((dataAdapter?.platform.inMeiju() ?? false)  && dataAdapter?.sn8 == '79009833')
                                      //   || (dataAdapter?.platform.inHomlux() ?? false)) Container(
                                      //   margin:
                                      //       const EdgeInsets.only(bottom: 16),
                                      //   child: ModeCard(
                                      //     disabled: dataAdapter?.data!.power ?? true ? false : true,
                                      //     modeList: lightModes,
                                      //     selectedKeys: getSelectedKeys(),
                                      //     onTap: (mode) {
                                      //       setState(() {
                                      //         modeTap = mode;
                                      //       });
                                      //       Timer(const Duration(milliseconds: 500), () {
                                      //         setState(() {
                                      //           modeTap = null;
                                      //         });
                                      //       });
                                      //       dataAdapter?.controlMode(mode);
                                      //     },
                                      //   ),
                                      // ),
                                      // if ((dataAdapter?.platform.inMeiju() ?? false)  && dataAdapter?.sn8 == '79009833')
                                      //   Container(
                                      //   margin:
                                      //       const EdgeInsets.only(bottom: 16),
                                      //   child: FunctionCard(
                                      //     title: '延时关灯',
                                      //     subTitle: dataAdapter?.data!.timeOff == 0
                                      //         ? '未设置'
                                      //         : '${dataAdapter?.data!.timeOff}分钟后关灯',
                                      //     child: Listener(
                                      //       onPointerDown: (e) {
                                      //         dataAdapter?.controlDelay();
                                      //       },
                                      //       child: Container(
                                      //         width: 40,
                                      //         height: 40,
                                      //         decoration: BoxDecoration(
                                      //           gradient: LinearGradient(
                                      //             begin: Alignment.topRight,
                                      //             end: Alignment.bottomLeft,
                                      //             colors: dataAdapter?.data!.timeOff == 0 ? [const Color(0x21FFFFFF), const Color(0x21FFFFFF)]:
                                      //               [const Color(0xFF767B86), const Color(0xFF88909F), const Color(0xFF516375)],
                                      //           ),
                                      //           borderRadius:
                                      //               BorderRadius.circular(20),
                                      //         ),
                                      //         child: const Image(
                                      //           image: AssetImage('assets/imgs/plugins/0x13/delay_off.png'),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}

int formatValue(num value) {
  return int.parse((value / 255 * 100).toStringAsFixed(0));
}
