import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/0x21/recognizer/index.dart';

import '../../../common/global.dart';
import '../../../states/device_change_notifier.dart';
import './mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

class ZigbeeLightPageState extends State<ZigbeeLightPage> {

  DeviceEntity deviceInfo = DeviceEntity();

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    setState(() {
      deviceInfo.detail?["power"] = !deviceInfo.detail?["power"];
    });
    await WIFILightApi.powerLua(deviceInfo.detail?["applianceCode"], deviceInfo.detail?["power"]);
  }

  Future<void> delayHandle() async {
    setState(() {
      if (deviceInfo.detail?["timeOff"] == '0') {
        deviceInfo.detail?["timeOff"] = '3';
      } else {
        deviceInfo.detail?["timeOff"] = '0';
      }
    });
    await WIFILightApi.delayPDM(deviceInfo.detail?["applianceCode"], deviceInfo.detail?["timeOff"] == '3');
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      deviceInfo.detail?["screenModel"] = mode.key;
    });
    await WIFILightApi.modePDM(deviceInfo.detail?["applianceCode"], mode.key);
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    setState(() {
      deviceInfo.detail?["brightness"] = value;
    });
    await WIFILightApi.brightnessPDM(deviceInfo.detail?["applianceCode"], value);
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    setState(() {
      deviceInfo.detail?["colorTemperature"] = value;
    });
    await WIFILightApi.colorTemperaturePDM(deviceInfo.detail?["applianceCode"], value);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[deviceInfo.detail?["screenModel"]] = true;
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      String deviceIdOnRoute = args['deviceId'];
      var deviceList = context.read<DeviceListModel>().deviceList;
      deviceInfo = deviceList.where((element) => element.applianceCode == deviceIdOnRoute).toList()[0];
      debugPrint('插件拿到的全局信息$deviceInfo');
      WIFILightApi.getLightDetail(deviceInfo.detail?["applianceCode"]);
    });
  }

  @override
  Widget build(BuildContext context) {

    var colorful = ListView(
      children: [
        ParamCard(
          title: '亮度',
          value: deviceInfo.detail?["brightness"],
          activeColors: const [
            Color(0xFFFFD185),
            Color(0xFFFFD185)
          ],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        ParamCard(
          title: '色温',
          value: deviceInfo.detail?["colorTemperature"],
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
          onTap: modeHandle,
        ),
        FunctionCard(
          title: '延时关灯',
          subTitle: deviceInfo.detail?["timeOff"] == '0'
              ? '未设置'
              : '${int.parse(deviceInfo.detail?["timeOff"])}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceInfo.detail?["timeOff"] == '0'
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceInfo.detail?["timeOff"] == '0'
                    ? 'assets/imgs/plugins/0x13/delay_off.png'
                    : 'assets/imgs/plugins/0x13/delay_on.png'),
              ),
            ),
          ),
        )
      ],
    );

    var noColor = ListView(
      children: [
        ParamCard(
          title: '亮度',
          value: deviceInfo.detail?["brightness"],
          activeColors: const [
            Color(0xFFFFD185),
            Color(0xFFFFD185)
          ],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        FunctionCard(
          title: '延时关灯',
          subTitle: deviceInfo.detail?["timeOff"] == '0'
              ? '未设置'
              : '${int.parse(deviceInfo.detail?["timeOff"])}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceInfo.detail?["timeOff"] == '0'
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceInfo.detail?["timeOff"] == '0'
                    ? 'assets/imgs/plugins/0x13/delay_off.png'
                    : 'assets/imgs/plugins/0x13/delay_on.png'),
              ),
            ),
          ),
        )
      ],
    );

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
                brightness: deviceInfo.detail?["brightness"],
                colorTemperature: 100 - deviceInfo.detail?["colorTemperature"],
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
                    onPowerBtnTap: powerHandle,
                    title: deviceInfo.name,
                    power: deviceInfo.detail?["power"],
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
                          child: modelNumList[deviceInfo.modelNumber]?.recognize() == 'DS' ? colorful : noColor
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


class ZigbeeLightPage extends StatefulWidget {

  const ZigbeeLightPage({super.key});

  @override
  State<ZigbeeLightPage> createState() => ZigbeeLightPageState();
}
