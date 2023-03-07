import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_light/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../states/device_change_notifier.dart';
import '../../../../widgets/event_bus.dart';
import '../../../home/device/register_controller.dart';
import '../../../home/device/service.dart';
import 'mode_list.dart';

class ZigbeeLightPageState extends State<ZigbeeLightPage> {
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;
  // 本地原始数据
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

  // 本地视图getters
  num localColorTemperature = 0;
  num localBrightness = 1;
  num localDelayClose = 0;
  bool localPower = false;

  // 填装视图数据
  setViewData(Map<String, dynamic> detail) {
    setState(() {
      localBrightness = detail["lightPanelDeviceList"][0]["brightness"] ?? 1;
      localColorTemperature =
          detail["lightPanelDeviceList"][0]["colorTemperature"] ?? 0;
      localPower = detail["lightPanelDeviceList"][0]["attribute"] == 1;
      localDelayClose = detail["lightPanelDeviceList"][0]["delayClose"];
    });
  }

  String fakeModel = '';

  void goBack() {
    bus.emit('updateDeviceCardState');
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
    logger.i('设备详情', detail);
    deviceInfo.detail = detail;
    setViewData(detail);
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
    judgeModel();
    debugPrint('插件中获取到的详情：$deviceWatch');
  }

  judgeModel() {
    for (var element in lightModes) {
      var curMode = element as ZigbeeLightMode;
      if (localBrightness == curMode.brightness &&
          localColorTemperature == curMode.colorTemperature) {
        setState(() {
          fakeModel = curMode.key;
        });
      }
    }
  }

  Future<void> powerHandle() async {
    setState(() {
      localPower = !localPower;
    });
    var res = await ZigbeeLightApi.powerPDM(deviceWatch["detail"]["deviceId"],
        localPower, deviceWatch["detail"]["nodeId"]);
    if (!res.isSuccess) {
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    }
  }

  Future<void> delayHandle() async {
    if (!localPower) return;
    setState(() {
      if (localDelayClose == 0) {
        localDelayClose = 3;
      } else {
        localDelayClose = 0;
      }
    });
    var res = await ZigbeeLightApi.delayPDM(deviceWatch["detail"]["deviceId"],
        !(localDelayClose == 0), deviceWatch["detail"]["nodeId"]);

    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(milliseconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () => {updateDetail()});
  }

  Future<void> modeHandle(Mode mode) async {
    setState(() {
      fakeModel = mode.key;
    });
    var curMode = lightModes
        .where((element) => element.key == fakeModel)
        .toList()[0] as ZigbeeLightMode;
    logger.i('deviceId', deviceWatch);
    var res = await ZigbeeLightApi.adjustPDM(
        deviceWatch["detail"]["deviceId"],
        curMode.brightness,
        curMode.colorTemperature,
        deviceWatch["detail"]["nodeId"]);

    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(milliseconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () => {updateDetail()});
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    setState(() {
      localBrightness = value;
      fakeModel = '';
    });
    var res = await ZigbeeLightApi.adjustPDM(deviceWatch["detail"]["deviceId"],
        value, localColorTemperature, deviceWatch["detail"]["nodeId"]);

    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(milliseconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () => {updateDetail()});
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    setState(() {
      localColorTemperature = value;
      fakeModel = '';
    });
    var res = await ZigbeeLightApi.adjustPDM(deviceWatch["detail"]["deviceId"],
        localBrightness, value, deviceWatch["detail"]["nodeId"]);

    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(milliseconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () => {updateDetail()});
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
            .getDeviceDetailById(deviceWatch["deviceId"]);
        debugPrint('插件中获取到的详情：$deviceWatch');
        deviceWatch['detail']["lightPanelDeviceList"][0]["attribute"] = args['power'] ? 1 : 0;
      });
      setViewData(deviceWatch['detail']);

      Push.listen("gemini/appliance/event", _eventCallback = ((arg) async {
        String event = (arg['event'] as String).replaceAll("\\\"", "\"") ?? "";
        Map<String,dynamic> eventMap = json.decode(event);
        String nodeId = eventMap['nodeId'] ?? "";
        var detail = context.read<DeviceListModel>().getDeviceDetailById(args['deviceId']);

        if (nodeId.isEmpty) {
          if (detail['deviceId'] == arg['applianceCode']) {
            updateDetail();
          }
        } else {
          if ((detail['masterId'] as String).isNotEmpty && detail['detail']?['nodeId'] == nodeId) {
            updateDetail();
          }
        }
      }));

      Push.listen("appliance/status/report", _reportCallback = ((arg) {
        var detail = context.read<DeviceListModel>().getDeviceDetailById(args['deviceId']);
        if (arg.containsKey('applianceId')) {
          if (detail['deviceId'] == arg['applianceId']) {
            updateDetail();
          }
        }
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();
    Push.dislisten("gemini/appliance/event", _eventCallback);
    Push.dislisten("appliance/status/report",_reportCallback);
  }

  @override
  Widget build(BuildContext context) {
    var colorful = Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ParamCard(
            minValue: 1,
            maxValue: 100,
            disabled: !localPower,
            title: '亮度',
            value: localBrightness,
            activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
            onChanged: brightnessHandle,
            onChanging: brightnessHandle,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ParamCard(
            disabled: !localPower,
            title: '色温',
            value: localColorTemperature,
            activeColors: const [Color(0xFFFFD39F), Color(0xFF55A2FA)],
            onChanged: colorTemperatureHandle,
            onChanging: colorTemperatureHandle,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ModeCard(
            hasHeightlight: true,
            modeList: lightModes,
            selectedKeys: getSelectedKeys(),
            onTap: modeHandle,
            disabled: !localPower,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FunctionCard(
            title: '延时关灯',
            subTitle: localDelayClose == 0 ? '未设置' : '$localDelayClose分钟后关灯',
            child: Listener(
              onPointerDown: (e) => delayHandle(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: localDelayClose == 0
                      ? const Color(0xFF000000)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Image(
                  image: AssetImage(localDelayClose == 0
                      ? 'assets/imgs/plugins/0x13/delay_off.png'
                      : 'assets/imgs/plugins/0x13/delay_on.png'),
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
            disabled: !localPower,
            title: '亮度',
            value: localBrightness,
            activeColors: const [Color(0xFFFFD185), Color(0xFFFFD185)],
            onChanged: brightnessHandle,
            onChanging: brightnessHandle,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FunctionCard(
            title: '延时关灯',
            subTitle: localDelayClose == 0 ? '未设置' : '$localDelayClose分钟后关灯',
            child: Listener(
              onPointerDown: (e) => delayHandle(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: localDelayClose == 0
                      ? const Color(0xFF000000)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Image(
                  image: AssetImage(localDelayClose == 0
                      ? 'assets/imgs/plugins/0x13/delay_off.png'
                      : 'assets/imgs/plugins/0x13/delay_on.png'),
                ),
              ),
            ),
          ),
        ),
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
                brightness: localBrightness,
                colorTemperature: 100 - localColorTemperature,
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
