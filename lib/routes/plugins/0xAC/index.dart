import 'package:easy_refresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/plugins/air_condition.dart';

import '../../../states/device_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../widgets/plugins/arrow.dart';

class AirConditionPageState extends State<AirConditionPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '空调',
    "detail": {"mode": '', "temperature": 26, "wind_speed": 102}
  };

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    await WIFILightApi.powerLua(
        deviceWatch["deviceId"], deviceWatch["detail"]["power"]);
  }

  Future<void> delayHandle() async {
    setState(() {
      if (deviceWatch["detail"]["timeOff"] == '0') {
        deviceWatch["detail"]["timeOff"] = '3';
      } else {
        deviceWatch["detail"]["timeOff"] = '0';
      }
    });
    await WIFILightApi.delayPDM(
        deviceWatch["deviceId"], deviceWatch["detail"]["timeOff"] == '3');
  }

  Future<void> modeHandle(Mode mode) async {
    await WIFILightApi.modePDM(deviceWatch["deviceId"], mode.key);
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    await WIFILightApi.brightnessPDM(deviceWatch["deviceId"], value);
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    await WIFILightApi.colorTemperaturePDM(deviceWatch["deviceId"], value);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[deviceWatch["detail"]["screenModel"]] = true;
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      deviceWatch = context
          .read<DeviceListModel>()
          .getDeviceDetail(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的详情：$deviceWatch');
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
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              child: AirCondition(
                temperature: deviceWatch["detail"]["temperature"],
                windSpeed: deviceWatch["detail"]["windSpeed"],
                mode: deviceWatch["detail"]["mode"],
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
                    onRightBtnTap: powerHandle,
                    title: deviceWatch["deviceName"],
                    power: deviceWatch["detail"]["power"] == 'on',
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
                      onRefresh: () async {},
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            const Align(
                              widthFactor: 1,
                              heightFactor: 1,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 303,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  FunctionCard(
                                      title: '模式',
                                      child: Row(
                                        children: [
                                          const Opacity(
                                              opacity: 0.5,
                                              child: Image(
                                                  image: AssetImage(
                                                      'assets/imgs/plugins/0xAC/zidong_icon.png'))),
                                          const Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(7, 0, 7, 0),
                                            child: Text(
                                              '自动',
                                              style: TextStyle(
                                                color: Color(0X7FFFFFFF),
                                                fontSize: 18.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          Stack(
                                            children: const [
                                              SizedBox(
                                                width: 36,
                                                height: 36,
                                              ),
                                              Positioned(
                                                top: -2,
                                                left: 0,
                                                child: AnimatedArrow()
                                              )
                                            ],
                                          )
                                        ],
                                      )),
                                  const SliderButtonCard(),
                                  const GearCard(),
                                ],
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

class AirConditionPage extends StatefulWidget {
  const AirConditionPage({super.key});

  @override
  State<AirConditionPage> createState() => AirConditionPageState();
}
