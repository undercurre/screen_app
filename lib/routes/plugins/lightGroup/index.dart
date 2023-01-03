import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/lightGroup/api.dart';

import '../../../states/device_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

class LightGroupPageState extends State<LightGroupPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "sn8": null,
    "modelNumber": '',
    "deviceName": '灯光分组',
    "detail": {
      "id": 0,
      "groupId": 1,
      "applianceList": [{
        "parentApplianceCode": "",
        "applianceCode": ""
      }],
      "detail": {
        "group": {
          "groupId": "1",
          "groupName": "灯光分组",
          "brightness": "0",
          "colorTemperature": "0",
          "switchStatus": "0",
          "maxColorTemp": "6500",
          "minColorTemp": "2700"
        }
      }
    }
  };

  late DeviceEntity deviceInfoById;

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    var res = await LightGroupApi.powerPDM(deviceInfoById,
        !(deviceWatch["detail"]["detail"]["group"]["switchStatus"] == "1"));
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["detail"]["group"]["switchStatus"] = deviceWatch["detail"]["detail"]["group"]["switchStatus"] == "1" ? "0" : "1";
      });
      updateDetail();
    }
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    var res = await LightGroupApi.brightnessPDM(deviceInfoById, value);
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["detail"]["group"]["brightness"] = value.toString();
      });
      updateDetail();
    }
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    var res =
        await LightGroupApi.colorTemperaturePDM(deviceInfoById, value);
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["detail"]["group"]["colorTemperature"] = value.toString();
      });
      updateDetail();
    }
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var result = await LightGroupApi.getLightDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"]["detail"] = result.result["result"];
    });
    debugPrint('插件中获取到的详情：$deviceWatch');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      setState(() {
        deviceWatch = context
            .read<DeviceListModel>()
            .getDeviceDetail(deviceWatch["deviceId"]);
      });
      deviceInfoById = context.read<DeviceListModel>().getDeviceInfoById(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的deviceInfo：$deviceInfoById');
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
                brightness:
                    int.parse(deviceWatch["detail"]["detail"]["group"]["brightness"]),
                colorTemperature: 100 -
                    int.parse(
                        deviceWatch["detail"]["detail"]["group"]["colorTemperature"]),
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
                    power: deviceWatch["detail"]["detail"]["group"]["switchStatus"] == "1",
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
                                value: int.parse(deviceWatch["detail"]["detail"]["group"]
                                    ["brightness"]),
                                activeColors: const [
                                  Color(0xFFFFD185),
                                  Color(0xFFFFD185)
                                ],
                                onChanged: brightnessHandle,
                                onChanging: brightnessHandle,
                              ),
                              ParamCard(
                                title: '色温',
                                value: int.parse(deviceWatch["detail"]["detail"]["group"]
                                    ["colorTemperature"]),
                                activeColors: const [
                                  Color(0xFFFFD39F),
                                  Color(0xFF55A2FA)
                                ],
                                onChanged: colorTemperatureHandle,
                                onChanging: colorTemperatureHandle,
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

class LightGroupPage extends StatefulWidget {
  const LightGroupPage({super.key});

  @override
  State<LightGroupPage> createState() => LightGroupPageState();
}
