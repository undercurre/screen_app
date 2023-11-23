import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/mixins/throttle.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/routes/plugins/0x17/api.dart';
import 'package:screen_app/routes/plugins/0x17/data_adapter.dart';
import 'package:screen_app/routes/plugins/0x17/entity.dart';
import 'package:screen_app/widgets/index.dart';
import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'mode_list.dart';

class WifiLiangyiPageState extends State<WifiLiangyiPage> with Throttle {
  Function(Map<String, dynamic> arg)? _eventCallback;
  Function(Map<String, dynamic> arg)? _reportCallback;
  WIFILiangyiDataAdapter? dataAdapter;

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '晾衣架',
    "detail": {"updown": 'pause', "location_status": "normal", "light": "off"}
  };

  var localUpdown = "pause";
  var localStatus = "normal";
  var localLight = "off";

  String fakerModel = '';

  String getUpdownStr() {
    if (localStatus == "normal" && localUpdown == 'up') {
      return '上升中';
    }
    if (localStatus == "normal" && localUpdown == 'down') {
      return '下降中';
    }
    if (localStatus == "upper_limit" && localUpdown == 'pause') {
      return '最高点';
    }
    if (localStatus == "lower_limit" && localUpdown == 'pause') {
      return '最低点';
    }
    return '暂停';
  }

  Future<void> modeHandle(Mode mode) async {
    Map<String, int> modes = {'up': 3, 'pause': 4, 'down': 5};
    if (modes[mode.key] != null)  dataAdapter?.modeControl(modes[mode.key]!);
  }

  Future<void> lightHandle(bool e) async {
    setState(() {
      localLight = localLight == 'on' ? 'off' : 'on';
    });
    var res = await WIFILiangyiApi.lightLua(deviceWatch["deviceId"], e);
    if (res.isSuccess) {
      // updateDetail();
    } else {
      setState(() {
        localLight = localLight == 'on' ? 'off' : 'on';
      });
    }
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    if (dataAdapter?.data?.updown != null) selectKeys[dataAdapter!.data!.updown] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = context.read<DeviceListModel>().getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    if (detail.isNotEmpty) {
      setState(() {
        deviceWatch["detail"] = detail;
        localUpdown = detail["updown"];
        localStatus = detail["location_status"];
        localLight = detail["light"];
        fakerModel = detail["updown"];
      });
    }
    if (mounted) {
      context.read<DeviceListModel>().updateDeviceDetail(deviceInfo);
    }
    debugPrint('插件中获取到的详情：$deviceWatch');
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        dataAdapter = args?['adapter'];
      });
      dataAdapter?.bindDataUpdateFunction(updateCallback);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dataAdapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {});
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
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: LiangyiEntity(light: dataAdapter?.data?.light == 'on'),
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
                    power: false,
                    hasPower: false,
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
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 60),
                          child: Row(
                            children: [
                              const Align(
                                widthFactor: 1,
                                heightFactor: 1,
                                alignment: Alignment(-1.0, -0.63),
                                child: SizedBox(
                                  width: 152,
                                  height: 240,
                                  child: Stack(
                                    children: [],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          child: ModeCard(
                                            spacing: 40,
                                            modeList: liangyiModes,
                                            selectedKeys: getSelectedKeys(),
                                            onTap: modeHandle,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          child: FunctionCard(
                                            icon: const Image(
                                              height: 40,
                                              width: 40,
                                              image: AssetImage('assets/newUI/liangyimodel/light.png'),
                                            ),
                                            title: '照明',
                                            child: MzSwitch(
                                              value: dataAdapter?.data?.light == 'on',
                                              onTap: (e) {
                                                dataAdapter?.modeControl(2);
                                              },
                                            ),
                                          ),
                                        ),
                                        FunctionCard(
                                          icon: const Image(
                                            height: 40,
                                            width: 40,
                                            image: AssetImage('assets/newUI/liangyimodel/laundry.png'),
                                          ),
                                          title: '一键晾衣',
                                          child:  MzSwitch(
                                            disabled: false,
                                            value: dataAdapter?.data?.laundry == 'on',
                                            onTap: (e) {
                                              dataAdapter?.modeControl(1);
                                            },
                                          ),
                                        ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WifiLiangyiPage extends StatefulWidget {
  const WifiLiangyiPage({super.key});

  @override
  State<WifiLiangyiPage> createState() => WifiLiangyiPageState();
}
