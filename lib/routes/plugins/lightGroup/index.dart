import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/lightGroup/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';

class LightGroupPageState extends State<LightGroupPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "sn8": null,
    "modelNumber": '',
    "deviceName": '灯光分组',
    "detail": {
      "id": 0,
      "groupId": 1,
      "applianceList": [
        {"parentApplianceCode": "", "applianceCode": ""}
      ],
      "detail": {
        "groupId": "1",
        "groupName": "灯光分组",
        "brightness": "0",
        "colorTemperature": "0",
        "switchStatus": "0",
        "maxColorTemp": "6500",
        "minColorTemp": "2700"
      }
    }
  };

  late DeviceEntity deviceInfoById;

  var localBrightness = '1';
  var localColorTemp = '0';
  var localPower = false;
  var isColorful = true;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    setState(() {
      localPower = !localPower;
    });
    var res = await LightGroupApi.powerPDM(deviceInfoById, localPower);
    if (res.isSuccess) {
      updateDetail();
    } else {
      setState(() {
        localPower = !localPower;
      });
    }
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    var exValue = localBrightness;
    setState(() {
      localBrightness = value.toString();
    });
    var res = await LightGroupApi.brightnessPDM(deviceInfoById, value);
    if (res.isSuccess) {
      updateDetail();
    } else {
      setState(() {
        localBrightness = exValue;
      });
    }
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    var exValue = localColorTemp;
    setState(() {
      localColorTemp = value.toString();
    });
    var res = await LightGroupApi.colorTemperaturePDM(deviceInfoById, value);
    if (res.isSuccess) {
      updateDetail();
    } else {
      setState(() {
        localColorTemp = exValue;
      });
    }
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var result = await LightGroupApi.getLightDetail(deviceInfo);
    initView(result.result["result"]["group"]);
    deviceInfo.detail!["detail"] = result.result["result"]["group"];
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
  }

  initView(detail) {
    setState(() {
      localBrightness = detail["brightness"];
      localColorTemp = detail["colorTemperature"];
      localPower = detail["switchStatus"] == "1";
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      setIsColorFul(args['deviceId']);
      setState(() {
        deviceWatch = context
            .read<DeviceListModel>()
            .getDeviceDetailById(deviceWatch["deviceId"]);
        localBrightness = deviceWatch["detail"]["detail"]["brightness"];
        localColorTemp = deviceWatch["detail"]["detail"]["colorTemperature"];
        localPower = args["power"];
      });
      deviceInfoById = context
          .read<DeviceListModel>()
          .getDeviceInfoById(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的deviceInfo：$deviceInfoById');
      debugPrint('插件中获取到的详情：$deviceWatch');
    });
    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(milliseconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () => {updateDetail()});
  }

  setIsColorFul(String deviceId) async {
    var isColorfulRes = await LightGroupApi.isColorful(context.read<DeviceListModel>().getDeviceInfoById(deviceId));
    logger.i('isColorfulRes', isColorfulRes);
    setState(() {
      isColorful = isColorfulRes;
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
                brightness: int.parse(localBrightness),
                colorTemperature: 100 - int.parse(localColorTemp),
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
                    power: localPower,
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
                        await updateDetail();
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
                                        title: '亮度',
                                        value: int.parse(deviceWatch["detail"]
                                            ["detail"]["brightness"]),
                                        activeColors: const [
                                          Color(0xFFFFD185),
                                          Color(0xFFFFD185)
                                        ],
                                        onChanged: brightnessHandle,
                                        onChanging: brightnessHandle,
                                      ),
                                    ),
                                    if (isColorful) Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: ParamCard(
                                        title: '色温',
                                        value: int.parse(deviceWatch["detail"]
                                            ["detail"]["colorTemperature"]),
                                        activeColors: const [
                                          Color(0xFFFFD39F),
                                          Color(0xFF55A2FA)
                                        ],
                                        onChanged: colorTemperatureHandle,
                                        onChanging: colorTemperatureHandle,
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
