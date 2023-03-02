import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/routes/plugins/0x13/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/global.dart';
import '../../../widgets/event_bus.dart';
import './mode_list.dart';
import '../../../states/device_change_notifier.dart';

class WifiLightPageState extends State<WifiLightPage> with Throttle {
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '吸顶灯',
    "detail": {
      "brightValue": 1,
      "colorTemperatureValue": 0,
      "power": false,
      "screenModel": "manual",
      "timeOff": "0"
    }
  };

  var localBrightness = 1;
  var localColorTemp = 0;
  var localPower = false;
  var localScreenModel = 'manual';
  var localTimeOff = 0;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    var res = await WIFILightApi.powerLua(deviceWatch["deviceId"], !localPower);
    if (res.isSuccess) {
      setState(() {
        localPower = !localPower;
      });
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    }
  }

  Future<void> delayHandle() async {
    if (localTimeOff == 0) {
      var res = await WIFILightApi.delayPDM(deviceWatch["deviceId"], true);
      if (res.isSuccess) {
        setState(() {
          localTimeOff = 3;
        });
        updateDetail();
      }
    } else {
      var res = await WIFILightApi.delayPDM(deviceWatch["deviceId"], false);
      if (res.isSuccess) {
        setState(() {
          localTimeOff = 0;
        });
        updateDetail();
      }
    }
  }

  Future<void> modeHandle(Mode mode) async {
    var res = await WIFILightApi.modePDM(deviceWatch["deviceId"], mode.key);
    if (res.isSuccess) {
      setState(() {
        localScreenModel = mode.key;
      });
      updateDetail();
    }
  }

  Future<void> brightnessHandle(num value, Color activeColor) async {
    var res = await WIFILightApi.brightnessPDM(deviceWatch["deviceId"], value);
    if (res.isSuccess) {
      throttle(() {
        setState(() {
          localBrightness = unFormatValue(value);
        });
      }, durationTime: const Duration(seconds: 1000));
    } else {
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(seconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () {
        updateDetail();
      });
    }
  }

  Future<void> colorTemperatureHandle(num value, Color activeColor) async {
    var res =
        await WIFILightApi.colorTemperaturePDM(deviceWatch["deviceId"], value);
    if (res.isSuccess) {
      throttle(() {
        setState(() {
          localColorTemp = unFormatValue(value);
        });
      }, durationTime: const Duration(seconds: 1000));
    } else {
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(seconds: 1000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () {
        updateDetail();
      });
    }
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[localScreenModel] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"] = detail;
      localBrightness = detail["brightValue"];
      localColorTemp = detail["colorTemperatureValue"];
      localPower = detail["power"];
      localScreenModel = detail["screenModel"];
      localTimeOff = detail["timeOff"];
    });
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
    debugPrint('插件中获取到的详情：$deviceWatch');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      var deviceDetail = context
          .read<DeviceListModel>()
          .getDeviceDetailById(deviceWatch["deviceId"]);
      setState(() {
        deviceWatch = deviceDetail;
        localBrightness = deviceDetail["detail"]["brightValue"];
        localColorTemp = deviceDetail["detail"]["colorTemperatureValue"];
        localPower = deviceDetail["detail"]["power"];
        localScreenModel = deviceDetail["detail"]["screenModel"];
        localTimeOff = deviceDetail["detail"]["timeOff"];
      });
      debugPrint('插件中获取到的详情：$deviceWatch');
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 2000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});

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
          if ((detail['masterId'] as String).isNotEmpty && detail?['detail']?['nodeId'] == nodeId) {
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
                brightness: formatValue(localBrightness),
                colorTemperature: 100 - formatValue(localColorTemp),
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
                              heightFactor: 2,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          title: '亮度',
                                          disabled: !localPower,
                                          value: formatValue(localBrightness),
                                          activeColors: const [
                                            Color(0xFFFFD185),
                                            Color(0xFFFFD185)
                                          ],
                                          onChanged: brightnessHandle,
                                          onChanging: brightnessHandle,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ParamCard(
                                          title: '色温',
                                          disabled: !localPower,
                                          value: formatValue(localColorTemp),
                                          activeColors: const [
                                            Color(0xFFFFD39F),
                                            Color(0xFF55A2FA)
                                          ],
                                          onChanged: colorTemperatureHandle,
                                          onChanging: colorTemperatureHandle,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ModeCard(
                                          modeList: lightModes,
                                          selectedKeys: getSelectedKeys(),
                                          onTap: modeHandle,
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: FunctionCard(
                                          title: '延时关灯',
                                          subTitle: localTimeOff == 0
                                              ? '未设置'
                                              : '$localTimeOff分钟后关灯',
                                          child: Listener(
                                            onPointerDown: (e) => delayHandle(),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: localTimeOff == 0
                                                    ? const Color(0xFF000000)
                                                    : const Color(0xFFFFFFFF),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Image(
                                                image: AssetImage(localTimeOff ==
                                                        0
                                                    ? 'assets/imgs/plugins/0x13/delay_off.png'
                                                    : 'assets/imgs/plugins/0x13/delay_on.png'),
                                              ),
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

class WifiLightPage extends StatefulWidget {
  const WifiLightPage({super.key});

  @override
  State<WifiLightPage> createState() => WifiLightPageState();
}

int formatValue(num value) {
  return int.parse((value / 255 * 100).toStringAsFixed(0));
}

int unFormatValue(num value) {
  return int.parse((value / 100 * 255).toStringAsFixed(0));
}
