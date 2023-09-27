
import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../common/adapter/device_card_data_adapter.dart';
import '../../../../common/gateway_platform.dart';
import '../../../../states/device_list_notifier.dart';
import '../../../../widgets/event_bus.dart';
import '../../../home/device/register_controller.dart';
import 'data_adapter.dart';
import 'mode_list.dart';

class ZigbeeLightPageState extends State<ZigbeeLightPage> {
  ZigbeeLightDataAdapter? dataAdapter;
  Mode? modeTap;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    if (modeTap != null) {
      selectKeys[modeTap!.key] = true;
    }
    // var key = dataAdapter?.data!.fakeModel ?? "";
    // if (key.isNotEmpty) {
    //   selectKeys[key] = true;
    // }
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

    var colorful = Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ParamCard(
            minValue: 1,
            maxValue: 100,
            disabled: dataAdapter?.data!.power ?? true ? false : true,
            title: '亮度',
            value: dataAdapter?.data!.brightness ?? 1,
            activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
            onChanged: dataAdapter?.controlBrightness,
            onChanging: dataAdapter?.controlBrightness,
          ),
        ),
        if(dataAdapter?.type == AdapterType.zigbeeLight) Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ParamCard(
            disabled: dataAdapter?.data!.power ?? true ? false : true,
            title: '色温',
            unit: "K",
            customMin: dataAdapter?.data?.minColorTemp ?? 2700,
            customMax: dataAdapter?.data?.maxColorTemp ?? 6500,
            value: dataAdapter?.data!.colorTemp ?? 1,
            activeColors: const [Color(0xFFFFD39F), Color(0xFF55A2FA)],
            onChanged: dataAdapter?.controlColorTemperature,
            onChanging: dataAdapter?.controlColorTemperature,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ModeCard(
            hasHeightlight: true,
            modeList: lightModes,
            selectedKeys: getSelectedKeys(),
            onTap: (mode) {
              setState(() {
                modeTap = mode;
              });
              Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  modeTap = null;
                });
              });
              dataAdapter?.controlMode(mode);
            },
            disabled: dataAdapter?.data!.power ?? true ? false : true,
          ),
        ),
        if ((dataAdapter?.platform.inMeiju() ?? false)
            && (dataAdapter?.type == AdapterType.zigbeeLight))
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FunctionCard(
              title: '延时关灯',
              subTitle: dataAdapter?.data!.delayClose == 0 ? '未设置' : '${dataAdapter?.data!.delayClose}分钟后关灯',
              child: Listener(
                onPointerDown: (e) {
                  dataAdapter?.controlDelay();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: dataAdapter?.data!.delayClose == 0 ? [const Color(0x21FFFFFF), const Color(0x21FFFFFF)]:
                      [const Color(0xFF767B86), const Color(0xFF88909F), const Color(0xFF516375)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Image(
                    image: AssetImage('assets/imgs/plugins/0x13/delay_off.png'),
                  ),
              ),
            ),
          ),
        ),
      ],
    );

    var noColor = Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ParamCard(
            minValue: 1,
            maxValue: 100,
            disabled: dataAdapter?.data!.power ?? true ? false : true,
            title: '亮度',
            value: dataAdapter?.data!.brightness ?? 1,
            activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
            onChanged: dataAdapter?.controlBrightness,
            onChanging: dataAdapter?.controlBrightness,
          ),
        ),
        if (dataAdapter?.platform.inMeiju() ?? false) Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FunctionCard(
            title: '延时关灯',
            subTitle: dataAdapter?.data!.delayClose == 0 ? '未设置' : '${dataAdapter?.data!.delayClose}分钟后关灯',
            child: Listener(
              onPointerDown: (e) {
                dataAdapter?.controlDelay();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: dataAdapter?.data!.delayClose == 0 ? [const Color(0x21FFFFFF), const Color(0x21FFFFFF)]:
                    [const Color(0xFF767B86), const Color(0xFF88909F), const Color(0xFF516375)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Image(
                  image: AssetImage('assets/imgs/plugins/0x13/delay_off.png'),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
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
                brightness: dataAdapter?.data!.brightness ?? 0,
                colorTemperature: 100 - (dataAdapter?.data!.colorTemp ?? 1),
              )),
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    maxHeight: 60.0,
                  ),
                  child: MzNavigationBar(
                    onLeftBtnTap: goBack,
                    onRightBtnTap: dataAdapter?.controlPower,
                    title: deviceListModel.getDeviceName(
                      deviceId: dataAdapter?.getDeviceId()),
                    power: dataAdapter?.data!.power ?? false,
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
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
                      onRefresh: () async {
                        await dataAdapter?.fetchData();
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(top: 35.0),
                          child: Row(
                            children: [
                              const Align(
                                widthFactor: 1,
                                heightFactor: 2,
                                alignment: Alignment(-1.0, -0.63),
                                child: SizedBox(
                                  width: 152,
                                  height: 200,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: colorful),
                                ),
                              ),
                            ],
                          ),
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

class ZigbeeLightPage extends StatefulWidget {
  const ZigbeeLightPage({super.key});

  @override
  State<ZigbeeLightPage> createState() => ZigbeeLightPageState();
}
