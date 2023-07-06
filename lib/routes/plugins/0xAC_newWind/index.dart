import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../home/device/service.dart';

class NewWindPageState extends State<NewWindPage> {
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;

  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '新风',
    "detail": {
      "wind_speed": 102
    }
  };

  var localPower = 'off';
  var localWind = 102;

  bool istouching = false;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    var res = await AirConditionApi.powerLua(
        deviceWatch["deviceId"], !(localPower == 'on'));

    if (res.isSuccess) {
      setState(() {
        localPower = localPower == "on" ? "off" : "on";
      });
    }
  }

  Future<void> gearHandle(num value) async {
    var exValue = localWind;
    setState(() {
      localWind = value.toInt() > 0 ? (value.toInt() - 1) * 20 : 1;
      istouching = true;
    });
    var res = await AirConditionApi.gearLua(
        deviceWatch["deviceId"], value > 0 ? (value - 1) * 20 : 1);

    var timeout = const Duration(seconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () {
      setState(() {
        istouching = false;
      });
    });

    if (res.isSuccess) {

    } else {
      setState(() {
        localWind = exValue;
      });
    }
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    logger.i('新风详情', detail);
    setState(() {
      deviceWatch["detail"] = detail;
      localPower = detail["power"];
      localWind = detail["wind_speed"];
    });
    debugPrint('插件中获取到的详情：$deviceWatch');
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
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
        localPower = args["power"] ? 'on' : 'off';
        localWind = deviceDetail["detail"]["wind_speed"];
      });
      deviceWatch = context
          .read<DeviceListModel>()
          .getDeviceDetailById(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的详情：$deviceWatch');

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
            if (istouching) return;
            Timer(const Duration(milliseconds: 1000), () {
              updateDetail();
            });
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF272F41),
            Color(0xFF080C14),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 117,
            left: 0,
            child: Image(
              width: 190,
              height: 246,
              image: AssetImage("assets/imgs/plugins/0xAC_newWind/new_wind_dev.png"),
            ),
          ),

          Column(
            children: [
              MzNavigationBar(
                onLeftBtnTap: goBack,
                onRightBtnTap: powerHandle,
                title: deviceWatch["deviceName"],
                power: localPower == 'on',
                hasPower: true,
              ),
              Expanded(
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
                    updateDetail();
                  },
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 32, 16, 0),
                            child: GearCard(
                              maxGear: 3,
                              minGear: 1,
                              disabled: localPower == 'off',
                              value: (localWind / 20).truncate() + 1,
                              onChanged: gearHandle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class NewWindPage extends StatefulWidget {
  const NewWindPage({super.key});

  @override
  State<NewWindPage> createState() => NewWindPageState();
}
