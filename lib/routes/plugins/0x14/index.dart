import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/plugins/0x14/api.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../widgets/event_bus.dart';
import './mode_list.dart';
import '../../home/device/service.dart';

class WifiCurtainPageState extends State<WifiCurtainPage> {
  String deviceId = '178120883713504'; // 暂时写死设备编码
  String deviceName = '智能窗帘';
  String deviceType = '0x14';
  int curtainPosition = 0;
  String curtainStatus = 'stop';
  String curtainDirection = 'positive';
  Function(Map<String,dynamic> arg)? _eventCallback;
  Function(Map<String,dynamic> arg)? _reportCallback;
  bool istouching = false;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> modeHandle(Mode mode) async {

    if (mode.key == 'open') {
      setState(() {
        curtainPosition = 100;
      });
    } else if (mode.key == 'close'){
      setState(() {
        curtainPosition = 0;
      });
    }
    setState(() {
      curtainStatus = mode.key;
    });
    await CurtainApi.setMode(deviceId, mode.key, curtainDirection);
    // TODO 定时回显返回值
  }

  Future<void> curtainHandle(num value) async {
    // 控制值即时响应
    setState(() {
      curtainPosition = value.toInt();
      istouching = true;
    });
    await CurtainApi.changePosition(deviceId, value, curtainDirection);
    // TODO 控制返回值回显
    // 实例化Duration类 设置定时器持续时间 毫秒
    var timeout = const Duration(seconds: 1000);

    // 延时调用一次 1秒后执行
    Timer(timeout, () {
      setState(() {
        istouching = false;
      });
    });
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[curtainStatus] = true;
    debugPrint('$selectKeys');
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = DeviceEntity.fromJson(
        {'applianceCode': deviceId, 'type': deviceType});
    var res = await DeviceService.getDeviceDetail(deviceInfo);
    debugPrint('res: $res');

    setState(() {
      curtainPosition = int.parse(res['curtain_position']);
      curtainStatus = res['curtain_status'];
      curtainDirection = res['curtain_direction'];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceId = args['deviceId'];
      setState(() {
        curtainPosition = args['power'] ? 100 : 0;
      });
      updateDetail();

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
            if (istouching) return;
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
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          // 窗帘动画
          Positioned(
              left: -16, // 向左偏移
              top: 0,
              child: AnimationCurtain(
                position: curtainPosition,
              )),
          Column(
            children: <Widget>[
              // 顶部导航
              Container(
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                child: MzNavigationBar(
                  onLeftBtnTap: goBack,
                  title: deviceName,
                  hasPower: false,
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    // 卡片位置限制
                    const Align(
                      widthFactor: 1,
                      heightFactor: 2,
                      alignment: Alignment(-1.0, -0.63),
                      child: SizedBox(
                        width: 152,
                        height: 303,
                      ),
                    ),
                    // 卡片
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: SliderButtonCard(
                                    unit: '%',
                                    value: curtainPosition,
                                    min: 0,
                                    max: 100,
                                    onChanged: curtainHandle),
                              ),
                              ModeCard(
                                title: "模式",
                                spacing: 40,
                                modeList: curtainModes,
                                selectedKeys: getSelectedKeys(),
                                onTap: modeHandle,
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

class WifiCurtainPage extends StatefulWidget {
  const WifiCurtainPage({super.key});

  @override
  State<WifiCurtainPage> createState() => WifiCurtainPageState();
}
