import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import '../../../../states/device_change_notifier.dart';
import 'mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

class ZigbeeLightPageState extends State<ZigbeeLightPage> {

  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '吸顶灯',
    "detail": {
      "deviceLatestVersion": "VT20002",
      "modelId": "midea.light.003.002",
      "guard": false,
      "msgId": "56188923-58c8-4b87-ba00-7f4bf78a1d00",
      "deviceId": "1759219627878",
      "nodeId": "8CF681FFFE822214",
      "lightPanelDeviceList": [{
        "endPoint": 1,
        "brightness": 1,
        "attribute": 1,
        "delayClose": 0,
        "colorTemperature": 52
      }
      ]
    }
  };

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    await WIFILightApi.powerLua(
        deviceWatch["detail"]["deviceId"], deviceWatch["detail"]["lightPanelDeviceList"][0]["attribute"]);
  }

  Future<void> delayHandle() async {
    setState(() {
      if (deviceWatch["detail"]["delayClose"] == 0) {
        deviceWatch["detail"]["delayClose"] = 3;
      } else {
        deviceWatch["detail"]["delayClose"] = 0;
      }
    });
    await WIFILightApi.delayPDM(deviceWatch["detail"]["deviceId"],
        deviceWatch["detail"]["delayClose"] == 3);
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      deviceWatch["detail"]["screenModel"] = mode.key;
    });
    await WIFILightApi.modePDM(deviceWatch["detail"]["applianceCode"], mode.key);
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    setState(() {
      deviceWatch["detail"]["brightness"] = value;
    });
    await WIFILightApi.brightnessPDM(
        deviceWatch["detail"]["applianceCode"], value);
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    setState(() {
      deviceWatch["detail"]["colorTemperature"] = value;
    });
    await WIFILightApi.colorTemperaturePDM(
        deviceWatch["detail"]["applianceCode"], value);
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys['mild'] = true;
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      deviceWatch = context.read<DeviceListModel>().getDeviceDetail(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的详情：$deviceWatch');
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorful = ListView(
      children: [
        ParamCard(
          title: '亮度',
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
          activeColors: const [
            Color(0xFFFFD185),
            Color(0xFFFFD185)
          ],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        ParamCard(
          title: '色温',
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]["colorTemperature"],
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
          subTitle: deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
              ? '未设置'
              : '${deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"]}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
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
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
          activeColors: const [
            Color(0xFFFFD185),
            Color(0xFFFFD185)
          ],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        FunctionCard(
          title: '延时关灯',
          subTitle: deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
              ? '未设置'
              : '${deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"]}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"] == '0'
                    ? 'assets/imgs/plugins/0x13/delay_off.png'
                    : 'assets/imgs/plugins/0x13/delay_on.png'),
              ),
            ),
          ),
        )
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
                brightness: deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
                colorTemperature: 100 - deviceWatch["detail"]["lightPanelDeviceList"][0]["colorTemperature"],
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
                    power: deviceWatch["detail"]["lightPanelDeviceList"][0]["attribute"] == 1,
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
                            child: true ? colorful : noColor
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
