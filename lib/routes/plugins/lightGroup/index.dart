
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/gateway_platform.dart';
import '../../../states/device_list_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'data_adapter.dart';

class LightGroupPageState extends State<LightGroupPage> {
  LightGroupDataAdapter? dataAdapter;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
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
      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return deviceListModel.getDeviceName(
          deviceId: dataAdapter?.getDeviceId(),
          maxLength: 8, startLength: 5, endLength: 2
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
                brightness: dataAdapter?.data?.brightness ?? 0,
                colorTemperature: 100 - (dataAdapter?.data?.colorTemp ?? 0),
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
                    onRightBtnTap: dataAdapter?.controlPower,
                    title: getDeviceName(),
                    power: dataAdapter?.data?.power ?? false,
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
                      onRefresh: () async {
                        await dataAdapter?.fetchData();
                      },
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            const Align(
                              widthFactor: 1,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 303,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: ParamCard(
                                        disabled: dataAdapter?.data?.power ?? true ? false : true,
                                        title: '亮度',
                                        minValue: 1,
                                        maxValue: 100,
                                        value: dataAdapter?.data?.brightness ?? 0,
                                        activeColors: const [
                                          Color(0xFFFFD185),
                                          Color(0xFFFFD185)
                                        ],
                                        onChanged: dataAdapter?.controlBrightness,
                                        onChanging: dataAdapter?.controlBrightness,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: ParamCard(
                                        disabled: dataAdapter?.data?.power ?? true ? false : true,
                                        title: '色温',
                                        unit: 'k',
                                        customMin: dataAdapter?.data?.minColorTemp ?? 2700,
                                        customMax: dataAdapter?.data?.maxColorTemp ?? 6500,
                                        value: dataAdapter?.data?.colorTemp ?? 0,
                                        activeColors: const [
                                          Color(0xFFFFD39F),
                                          Color(0xFF55A2FA)
                                        ],
                                        onChanged: dataAdapter?.controlColorTemperature,
                                        onChanging: dataAdapter?.controlColorTemperature,
                                      ),
                                    ),
                                  ],
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

class LightGroupPage extends StatefulWidget {
  const LightGroupPage({super.key});

  @override
  State<LightGroupPage> createState() => LightGroupPageState();
}
