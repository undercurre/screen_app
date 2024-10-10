
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/logcat_helper.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../states/device_list_notifier.dart';
import '../../../../widgets/event_bus.dart';
import '../../0x14/mode_list.dart';

class ZigbeeEleMachineCurtainPageState extends State<ZigbeeEleMachineCurtainPage> {
  DeviceCardDataAdapter? dataAdapter;
  Mode? modeTap;
  Timer? clickTimer;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    if (modeTap != null) {
      selectKeys[modeTap!.key] = true;
    } else {
      //selectKeys[dataAdapter?.data!.curtainStatus ?? "unknown"] = true;
      selectKeys["unknown"] = true;
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
    clickTimer?.cancel();
  }

  void updateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
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
          // 窗帘动画
          Positioned(
              left: -32, // 向左偏移
              top: 0,
              child: AnimationCurtain(
                position: dataAdapter?.getCardStatus()?['curtainPosition'] ?? 0,
              )
          ),
          Column(
            children: <Widget>[
              // 顶部导航
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: MzNavigationBar(
                  onLeftBtnTap: goBack,
                  title: deviceListModel.getDeviceName(
                      deviceId: dataAdapter?.getDeviceId(),
                      maxLength: 8, startLength: 5, endLength: 2),
                  hasPower: false,
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    // 卡片位置限制
                    const Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: Alignment(-1.0, -0.63),
                      child: SizedBox(
                        width: 152,
                        height: 303,
                      ),
                    ),
                    // 卡片
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: SliderButtonCard(
                                  title: '开合度',
                                  unit: '%',
                                  value: dataAdapter?.getCardStatus()?['curtainPosition'] ?? 0,
                                  min: 0,
                                  max: 100,
                                  isOnlySlide: true,
                                  onChanged: (value) {
                                    dataAdapter?.slider1To(value as int);
                                  },
                                ),
                              ),
                              ModeCard(
                                title: "模式",
                                spacing: 40,
                                modeList: curtainModes,
                                selectedKeys: getSelectedKeys(),
                                onTap: (mode) {
                                  setState(() {
                                    modeTap = mode;
                                  });
                                  clickTimer?.cancel();
                                  clickTimer = Timer(const Duration(milliseconds: 500), () {
                                    setState(() {
                                      modeTap = null;
                                    });
                                  });
                                  dataAdapter?.tabTo(curtainModes.indexOf(mode));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ZigbeeEleMachineCurtainPage extends StatefulWidget {
  const ZigbeeEleMachineCurtainPage({super.key});

  @override
  State<ZigbeeEleMachineCurtainPage> createState() => ZigbeeEleMachineCurtainPageState();
}
