import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_change_notifier.dart';

class WifiLightPageState extends State<WifiLightPage> {

  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '吸顶灯',
    "detail": {
      "brightValue": 1,
      "colorTemperature": 0,
      "power": false,
      "screenModel": "manual",
      "timeOff": "0"
    }
  };

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    await WIFILightApi.powerLua(deviceWatch["deviceId"], deviceWatch["detail"]["power"]);
  }

  Future<void> delayHandle() async {
    setState(() {
      if (deviceWatch["detail"]["timeOff"] == '0') {
        deviceWatch["detail"]["timeOff"] = '3';
      } else {
        deviceWatch["detail"]["timeOff"] = '0';
      }
    });
    await WIFILightApi.delayPDM(deviceWatch["deviceId"], deviceWatch["detail"]["timeOff"] == '3');
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
      deviceWatch = context.read<DeviceListModel>().getDeviceDetailById(deviceWatch["deviceId"]);
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
              child: LightBall(
                brightness: deviceWatch["detail"]["brightValue"],
                colorTemperature: 100 - deviceWatch["detail"]["colorTemperature"],
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
                    power: deviceWatch["detail"]["power"],
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: Alignment(-1.0, -0.63),
                      child: SizedBox(
                        width: 152,
                        height: 303,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            children: [
                              ParamCard(
                                title: '亮度',
                                value: deviceWatch["detail"]["brightValue"],
                                activeColors: const [
                                  Color(0xFFFFD185),
                                  Color(0xFFFFD185)
                                ],
                                onChanged: brightnessHandle,
                                onChanging: brightnessHandle,
                              ),
                              ParamCard(
                                title: '色温',
                                value: deviceWatch["detail"]["colorTemperature"],
                                activeColors: const [
                                  Color(0xFFFFD39F),
                                  Color(0xFF55A2FA)
                                ],
                                onChanged: colorTemperatureHandle,
                                onChanging: colorTemperatureHandle,
                              ),
                              FunctionCard(
                                title: '延时关灯',
                                subTitle: deviceWatch["detail"]["timeOff"] == '0'
                                    ? '未设置'
                                    : '${int.parse(deviceWatch["detail"]["timeOff"])}分钟后关灯',
                                child: Listener(
                                  onPointerDown: (e) => delayHandle(),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: deviceWatch["detail"]["timeOff"] == '0'
                                          ? const Color(0xFF000000)
                                          : const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Image(
                                      image: AssetImage(deviceWatch["detail"]["timeOff"] == '0'
                                          ? 'assets/imgs/plugins/0x13/delay_off.png'
                                          : 'assets/imgs/plugins/0x13/delay_on.png'),
                                    ),
                                  ),
                                ),
                              )
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

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}
