import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/global.dart';
import 'package:screen_app/routes/plugins/0x21/0x21_curtain/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../widgets/event_bus.dart';
import './mode_list.dart';
import '../../../../common/api/device_api.dart';
import '../../../../models/mz_response_entity.dart';
import '../../../../states/device_change_notifier.dart';
import '../../../home/device/register_controller.dart';
import '../../../home/device/service.dart';

class ZigbeeCurtainPageState extends State<ZigbeeCurtainPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": 'Zigbee智能窗帘',
    "sn8": '',
    "modelNumber": '1107',
    "detail": {
      "deviceLatestVersion": "s0.0.3",
      "modelId": "midea.curtain.003.003",
      "guard": 0,
      "msgId": "0cadac7f-d3ec-4604-b1e5-2115ea87d2ca",
      "deviceControlList": [
        {"endPoint": 1, "attribute": 1},
        {"endPoint": 2, "attribute": 1}
      ],
      "curtainDeviceList": [
        {"endPoint": 1, "deviceFunctionLevel": 58, "attribute": 1}
      ],
      "nodeId": "8CF681FFFE6768A3"
    }
  };

  var screenModel1 = '';
  var screenModel2 = '';

  num position1 = 0;
  num position2 = 0;

  num curtainNum = 1;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> modeHandle1(Mode mode) async {
    if (deviceWatch["detail"]["nodeId"] == null) {
      await getNodeId();
    }
    setState(() {
      curtainNum = 1;
    });
    if (zigbeeControllerList[deviceWatch["modelNumber"]] ==
        '0x21_curtain_panel_one') {
      var res = await ZigbeeCurtainApi.powerPDM(deviceWatch["masterId"],
          mode.key == 'open', deviceWatch["detail"]["nodeId"]);
      if (res.isSuccess) {
        setState(() {
          screenModel1 = mode.key;
          position1 = mode.key == 'open' ? 100 : 0;
        });
      }
    } else if (zigbeeControllerList[deviceWatch["modelNumber"]] ==
        '0x21_curtain_panel_two') {
      var res = await ZigbeeCurtainApi.powerPDMTwin(
          deviceWatch["masterId"],
          mode.key == 'open',
          deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1,
          deviceWatch["detail"]["nodeId"]);
      if (res.isSuccess) {
        setState(() {
          screenModel1 = mode.key;
          position1 = mode.key == 'open' ? 100 : 0;
        });
      }
    } else {
      MzResponseEntity res;
      if (mode.key == 'open') {
        res = await ZigbeeCurtainApi.curtainOpenPDM(
            deviceWatch["masterId"], deviceWatch["detail"]["nodeId"]);
      } else if (mode.key == 'close') {
        res = await ZigbeeCurtainApi.curtainClosePDM(
            deviceWatch["masterId"], deviceWatch["detail"]["nodeId"]);
      } else {
        res = await ZigbeeCurtainApi.curtainStopPDM(
            deviceWatch["masterId"], deviceWatch["detail"]["nodeId"]);
      }
      if (res.isSuccess) {
        setState(() {
          screenModel1 = mode.key;
          if (mode.key == 'open') {
            position1 = 100;
          } else if (mode.key == 'close') {
            position1 = 0;
          } else {
            Future.delayed(const Duration(seconds: 3)).then((_) async {
              updateDetail();
            });
          }
        });
      }
    }
  }

  Future<void> modeHandle2(Mode mode) async {
    setState(() {
      curtainNum = 2;
    });
    if (zigbeeControllerList[deviceWatch["modelNumber"]] ==
        '0x21_curtain_panel_two') {
      var res = await ZigbeeCurtainApi.powerPDMTwin(
          deviceWatch["masterId"],
          deviceWatch["detail"]["deviceControlList"][1]["attribute"] == 1,
          mode.key == 'open',
          deviceWatch["detail"]["nodeId"]);
      if (res.isSuccess) {
        setState(() {
          screenModel2 = mode.key;
          position2 = mode.key == 'open' ? 100 : 0;
        });
      }
    }
  }

  Future<void> curtainHandle(num value) async {
    if (deviceWatch["detail"]["nodeId"] == null) {
      await getNodeId();
    }
    setState(() {
      position1 = value;
    });
    ZigbeeCurtainApi.curtainPercentPDM(
        deviceWatch["masterId"], value, deviceWatch["detail"]["nodeId"]);
    Future.delayed(const Duration(seconds: 3)).then((_) async {
      updateDetail();
    });
  }

  Map<String, bool?> getSelectedKeys1() {
    final selectKeys = <String, bool?>{};
    selectKeys[screenModel1] = true;
    return selectKeys;
  }

  Map<String, bool?> getSelectedKeys2() {
    final selectKeys = <String, bool?>{};
    selectKeys[screenModel2] = true;
    return selectKeys;
  }

  updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"] = detail;
    });
    deviceInfo.detail = detail;
    debugPrint('插件中获取到的详情：$deviceWatch');
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
    initView();
  }

  getNodeId() async {
    MzResponseEntity<String> gatewayInfo = await DeviceApi.getGatewayInfo(
        deviceWatch["deviceId"], deviceWatch["masterId"]);
    Map<String, dynamic> infoMap = json.decode(gatewayInfo.result);
    deviceWatch["detail"]["nodeId"] = infoMap["nodeid"];
  }

  initView() {
    if (zigbeeControllerList[deviceWatch["modelNumber"]] == '0x21_curtain') {
      position1 =
          deviceWatch["detail"]["curtainDeviceList"][0]["deviceFunctionLevel"];
      if (deviceWatch["detail"]["curtainDeviceList"][0]["attribute"] == 240) {
        screenModel1 = 'stop';
      } else if (deviceWatch["detail"]["curtainDeviceList"][0]["attribute"] ==
          0) {
        screenModel1 = 'close';
      } else {
        screenModel1 = 'open';
      }
    } else if (zigbeeControllerList[deviceWatch["modelNumber"]] ==
        '0x21_curtain_panel_two') {
      position1 =
          deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1
              ? 100
              : 0;
      position2 =
          deviceWatch["detail"]["deviceControlList"][1]["attribute"] == 1
              ? 100
              : 0;
      screenModel1 =
          deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1
              ? 'open'
              : 'close';
      screenModel2 =
          deviceWatch["detail"]["deviceControlList"][1]["attribute"] == 1
              ? 'open'
              : 'close';
    } else {
      position1 =
          deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1
              ? 100
              : 0;
      screenModel1 =
          deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1
              ? 'open'
              : 'close';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      setState(() {
        deviceWatch = context
            .read<DeviceListModel>()
            .getDeviceDetailById(deviceWatch["deviceId"]);
        debugPrint('插件中获取到的详情：$deviceWatch');
        initView();
      });
      // 实例化Duration类 设置定时器持续时间 毫秒
      var timeout = const Duration(milliseconds: 2000);

      // 延时调用一次 1秒后执行
      Timer(timeout, () => {updateDetail()});
    });
  }

  @override
  Widget build(BuildContext context) {
    var curtain = [
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: SliderButtonCard(
            unit: '%',
            value: position1,
            min: 0,
            max: 100,
            onChanged: curtainHandle),
      ),
      ModeCard(
        title: "模式",
        spacing: 40,
        modeList: curtainModes,
        selectedKeys: getSelectedKeys1(),
        onTap: modeHandle1,
      ),
    ];

    var curtainPanelOne = [
      ModeCard(
        title: "窗帘1",
        spacing: 80,
        modeList: curtainPanelModes1,
        selectedKeys: getSelectedKeys1(),
        onTap: modeHandle1,
      ),
    ];

    var curtainPanelTwo = [
      GestureDetector(
        onTap: () {
          setState(() {
            curtainNum = 1;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ModeCard(
            title: "窗帘1",
            spacing: 80,
            modeList: curtainPanelModes1,
            selectedKeys: getSelectedKeys1(),
            onTap: modeHandle1,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            curtainNum = 2;
          });
        },
        child: ModeCard(
          title: "窗帘2",
          spacing: 80,
          modeList: curtainPanelModes2,
          selectedKeys: getSelectedKeys2(),
          onTap: modeHandle2,
        ),
      ),
    ];

    Map<String, List<Widget>> childList = {
      "0x21_curtain": curtain,
      "0x21_curtain_panel_one": curtainPanelOne,
      "0x21_curtain_panel_two": curtainPanelTwo,
    };

    bool curtainPanelOnePower() {
      if (deviceWatch["detail"]["deviceControlList"] != null) {
        return deviceWatch["detail"]["deviceControlList"][0]["attribute"] == 1;
      } else {
        return false;
      }
    }

    bool curtainPanelTwoPower() {
      if (deviceWatch["detail"]["deviceControlList"] != null &&
          deviceWatch["detail"]["deviceControlList"].length == 2) {
        return (deviceWatch["detail"]["deviceControlList"][0]["attribute"] ==
                1) &&
            (deviceWatch["detail"]["deviceControlList"][1]["attribute"] == 1);
      } else {
        return false;
      }
    }

    Map<String, bool> powerList = {
      "0x21_curtain": deviceWatch["detail"]["curtainDeviceList"] != null
          ? deviceWatch["detail"]["curtainDeviceList"][0]["attribute"] == 1
          : false,
      "0x21_curtain_panel_one": curtainPanelOnePower(),
      "0x21_curtain_panel_two": curtainPanelTwoPower(),
    };

    getPowerStatus() {
      return powerList[zigbeeControllerList[deviceWatch["modelNumber"]]] ??
          false;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          Positioned(
            left: -16, // 向左偏移
            top: 0,
            child: Opacity(
              opacity: curtainNum == 1 ? 1 : 0,
              child: AnimationCurtain(
                position: position1.toDouble(),
              ),
            ),
          ),
          Positioned(
            left: -16, // 向左偏移
            top: 0,
            child: Opacity(
              opacity: curtainNum == 2 ? 1 : 0,
              child: AnimationCurtain(
                position: position2.toDouble(),
              ),
            ),
          ),
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
                    title: deviceWatch["deviceName"],
                    power: getPowerStatus(),
                    hasPower: false,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
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
                                height: 60,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height - 60,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: childList[zigbeeControllerList[
                                              deviceWatch["modelNumber"]]] ??
                                          curtain),
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

class ZigbeeCurtainPage extends StatefulWidget {
  const ZigbeeCurtainPage({super.key});

  @override
  State<ZigbeeCurtainPage> createState() => ZigbeeCurtainPageState();
}
