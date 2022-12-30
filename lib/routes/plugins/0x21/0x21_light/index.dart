import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_light/api.dart';
import '../../../../states/device_change_notifier.dart';
import '../../../device/register_controller.dart';
import '../../../device/service.dart';
import 'mode_list.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class ZigbeeLightPageState extends State<ZigbeeLightPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": 'Zigbee智能灯',
    "detail": {
      "deviceLatestVersion": "VT20002",
      "modelId": "midea.light.003.002",
      "guard": false,
      "msgId": "56188923-58c8-4b87-ba00-7f4bf78a1d00",
      "deviceId": "1759219627878",
      "nodeId": "8CF681FFFE822214",
      "lightPanelDeviceList": [
        {
          "endPoint": 1,
          "brightness": 1,
          "attribute": 1,
          "delayClose": 0,
          "colorTemperature": 52
        }
      ]
    }
  };

  String fakeModel = '';

  void goBack() {
    Navigator.pop(context);
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"] = detail;
    });
    judgeModel();
    debugPrint('插件中获取到的详情：$deviceWatch');
  }

  judgeModel() {
    for (var element in lightModes) {
      var curMode = element as ZigbeeLightMode;
      if (deviceWatch["detail"]["brightness"] == curMode.brightness &&
          deviceWatch["detail"]["colorTemperature"] ==
              curMode.colorTemperature) {
        setState(() {
          fakeModel = curMode.key;
        });
      }
    }
  }

  Future<void> powerHandle() async {
    var res = await ZigbeeLightApi.powerPDM(
        deviceWatch["detail"]["deviceId"],
        !(deviceWatch["detail"]["lightPanelDeviceList"][0]["attribute"] == 1),
        deviceWatch["detail"]["nodeId"]);
    if (res.isSuccess) {
      updateDetail();
    }
  }

  Future<void> delayHandle() async {
    setState(() {
      if (deviceWatch["detail"]["delayClose"] == 0) {
        deviceWatch["detail"]["delayClose"] = 3;
      } else {
        deviceWatch["detail"]["delayClose"] = 0;
      }
    });
    var res = await ZigbeeLightApi.delayPDM(
        deviceWatch["detail"]["deviceId"],
        !(deviceWatch["detail"]["delayClose"] == 0),
        deviceWatch["detail"]["nodeId"]);
    if (res.isSuccess) {
      updateDetail();
    }
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      fakeModel = mode.key;
    });
    var curMode = lightModes.where((element) => element.key == fakeModel).toList()[0] as ZigbeeLightMode;
    var res = await ZigbeeLightApi.adjustPDM(deviceWatch["detail"]["deviceId"],
        curMode.brightness, curMode.colorTemperature, deviceWatch["detail"]["nodeId"]);
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"] = curMode.brightness;
        deviceWatch["detail"]["lightPanelDeviceList"][0]["colorTemperature"] = curMode.colorTemperature;
      });
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    }
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    var res = await ZigbeeLightApi.adjustPDM(deviceWatch["detail"]["deviceId"],
        value, deviceWatch["detail"]["lightPanelDeviceList"][0]["colorTemperature"], deviceWatch["detail"]["nodeId"]);
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"] = value;
      });
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    }
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    var res = await ZigbeeLightApi.adjustPDM(
        deviceWatch["detail"]["deviceId"],
        deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
        value,
        deviceWatch["detail"]["nodeId"]);
    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["lightPanelDeviceList"][0]["colorTemperature"] = value;
      });
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    }
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[fakeModel] = true;
    return selectKeys;
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
        debugPrint('插件中获取到的详情：$deviceWatch');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorful = Column(
      children: [
        ParamCard(
          title: '亮度',
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
          activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        ParamCard(
          title: '色温',
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]
              ["colorTemperature"],
          activeColors: const [Color(0xFFFFD39F), Color(0xFF55A2FA)],
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
          subTitle: deviceWatch["detail"]["lightPanelDeviceList"][0]
                      ["delayClose"] ==
                  0
              ? '未设置'
              : '${deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"]}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceWatch["detail"]["lightPanelDeviceList"][0]
                            ["delayClose"] ==
                        0
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceWatch["detail"]["lightPanelDeviceList"]
                            [0]["delayClose"] ==
                        0
                    ? 'assets/imgs/plugins/0x13/delay_off.png'
                    : 'assets/imgs/plugins/0x13/delay_on.png'),
              ),
            ),
          ),
        )
      ],
    );

    var noColor = Column(
      children: [
        ParamCard(
          title: '亮度',
          value: deviceWatch["detail"]["lightPanelDeviceList"][0]["brightness"],
          activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
          onChanged: brightnessHandle,
          onChanging: brightnessHandle,
        ),
        FunctionCard(
          title: '延时关灯',
          subTitle: deviceWatch["detail"]["lightPanelDeviceList"][0]
                      ["delayClose"] ==
                  0
              ? '未设置'
              : '${deviceWatch["detail"]["lightPanelDeviceList"][0]["delayClose"]}分钟后关灯',
          child: Listener(
            onPointerDown: (e) => delayHandle(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: deviceWatch["detail"]["lightPanelDeviceList"][0]
                            ["delayClose"] ==
                        0
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image(
                image: AssetImage(deviceWatch["detail"]["lightPanelDeviceList"]
                            [0]["delayClose"] ==
                        0
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
                brightness: deviceWatch["detail"]["lightPanelDeviceList"][0]
                    ["brightness"],
                colorTemperature: 100 -
                    deviceWatch["detail"]["lightPanelDeviceList"][0]
                        ["colorTemperature"],
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
                    power: deviceWatch["detail"]["lightPanelDeviceList"][0]
                            ["attribute"] ==
                        1,
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
                              heightFactor: 2,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 200,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(scrollbars: false),
                                    child: zigbeeControllerList[
                                                deviceWatch["modelNumber"]] ==
                                            '0x21_light_colorful'
                                        ? colorful
                                        : noColor),
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

class ZigbeeLightPage extends StatefulWidget {
  const ZigbeeLightPage({super.key});

  @override
  State<ZigbeeLightPage> createState() => ZigbeeLightPageState();
}
