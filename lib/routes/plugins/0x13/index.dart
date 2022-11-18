import 'package:flutter/material.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/common/api/index.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/plugins/business_widget/mode_card/index.dart';
import 'package:screen_app/widgets/plugins/business_widget/param_card/index.dart';
import 'package:screen_app/common/device_mode/0x13/index.dart';
import 'package:screen_app/widgets/plugins/business_widget/function_card/index.dart';
import 'package:screen_app/common/device_mode/mode.dart';
import 'package:screen_app/widgets/plugins/device_widget/light_ball/index.dart';
import 'package:screen_app/widgets/plugins/base_widget/nav_bar/index.dart'
as nav_bar;

class WifiLightPageState extends State<WifiLightPage> {
  bool power = true;
  num brightness = 0;
  num colorTemperature = 0;
  String screenModel = 'mannel';
  String timeOff = '0';
  late String deviceId;
  late String deviceName;

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    await WIFILightApi.powerLua(deviceId, !power);
    setState(() {
      power = !power;
    });
  }

  Future<void> delayHandle() async {
    await WIFILightApi.delayPDM(deviceId, timeOff == '3');
    setState(() {
      if (timeOff == '0') {
        timeOff = '3';
      } else {
        timeOff = '0';
      }
    });
  }

  Future<void> modeHandle(Mode mode) async {
    await WIFILightApi.modePDM(deviceId, mode.key);
    setState(() {
      screenModel = mode.key;
    });
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    await WIFILightApi.brightnessPDM(deviceId, value);
    setState(() {
      brightness = value;
    });
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    await WIFILightApi.colorTemperaturePDM(deviceId, value);
    setState(() {
      colorTemperature = value;
    });
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[screenModel] = true;
    return selectKeys;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as Map;
    deviceId = args['deviceId'];
    deviceName = args['deviceName'];
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
                brightness: brightness,
                colorTemperature: 100 - colorTemperature,
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
                  child: nav_bar.NavigationBar(
                    onLeftBtnClick: goBack,
                    onPowerBtnClick: powerHandle,
                    title: deviceName,
                    power: power,
                    hasPower: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: const Alignment(-1.0, -0.63),
                      child: Container(
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
                                value: brightness,
                                activeColors: const [
                                  Color(0xFFFFD185),
                                  Color(0xFFFFD185)
                                ],
                                onChanged: brightnessHandle,
                                onChanging: brightnessHandle,
                              ),
                              ParamCard(
                                title: '色温',
                                value: colorTemperature,
                                activeColors: const [
                                  Color(0xFFFFD39F),
                                  Color(0xFF55A2FA)
                                ],
                                onChanged: colorTemperatureHandle,
                                onChanging: colorTemperatureHandle,
                              ),
                              ModeCard(
                                modeList: lightModes,
                                selectedKeys: getSelectedKeys(),
                                onClick: modeHandle,
                              ),
                              FunctionCard(
                                title: '延时关灯',
                                subTitle: timeOff == '0'
                                    ? '未设置'
                                    : '${int.parse(timeOff)}分钟后关灯',
                                child: Listener(
                                  onPointerDown: (e) => delayHandle(),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: timeOff == '0'
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFF000000),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Image(
                                      image: AssetImage(timeOff == '0'
                                          ? 'assets/imgs/plugins/0x13/delay_on.png'
                                          : 'assets/imgs/plugins/0x13/delay_off.png'),
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
