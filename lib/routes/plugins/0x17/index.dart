import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/routes/plugins/0x17/api.dart';
import 'package:screen_app/routes/plugins/0x17/entity.dart';
import 'package:screen_app/widgets/index.dart';
import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'mode_list.dart';

class WifiLiangyiPageState extends State<WifiLiangyiPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '晾衣架',
    "detail": {"updown": 'pause', "location_status": "normal", "light": "off"}
  };

  var localUpdown = "pause";
  var localStatus = "normal";
  var localLight = "off";

  late Timer _timer;

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

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> modeHandle(Mode mode) async {
    if ((localStatus == "upper_limit" && mode.key == "up") ||
        (localStatus == "lower_limit" && mode.key == "down")) {
      MzNotice mzNotice = MzNotice(
          icon: const SizedBox(width: 0, height: 0),
          btnText: '我知道了',
          title: '已经到达最${mode.key == 'up' ? '高' : '低'}点',
          backgroundColor: const Color(0XFF575757),
          onPressed: () {});

      mzNotice.show(context);
    }
    var res = await WIFILiangyiApi.updwonLua(deviceWatch["deviceId"], mode.key);
    if (res.isSuccess) {
      setState(() {
        fakerModel = mode.key;
      });
      updateDetail();
    }
  }

  Future<void> lightHandle(bool e) async {
    var res = await WIFILiangyiApi.lightLua(deviceWatch["deviceId"], e);
    if (res.isSuccess) {
      updateDetail();
    }
  }

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[localUpdown] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    if (detail.isNotEmpty) {
      setState(() {
        deviceWatch["detail"] = detail;
        localUpdown = detail["updown"];
        localStatus = detail["location_status"];
        localLight = detail["light"];
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateDetail();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      deviceWatch["deviceId"] = args['deviceId'];
      var deviceDetail = context
          .read<DeviceListModel>()
          .getDeviceDetailById(deviceWatch["deviceId"]);
      setState(() {
        deviceWatch = deviceDetail;
        localLight = deviceDetail["detail"]["light"];
        localStatus = deviceDetail["detail"]["location_status"];
        localUpdown = deviceDetail["detail"]["updown"];
      });
      debugPrint('插件中获取到的详情：$deviceWatch');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
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
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: LiangyiEntity(light: localLight == 'on'),
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
                          constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height - 60),
                          child: Row(
                            children: [
                              Align(
                                widthFactor: 1,
                                heightFactor: 1,
                                alignment: const Alignment(-1.0, -0.63),
                                child: SizedBox(
                                  width: 152,
                                  height: 240,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 16,
                                        bottom: 0,
                                        child: Column(
                                          children: [
                                            Text(
                                              getUpdownStr(),
                                              style: const TextStyle(
                                                  color: Color(0xFF8F8F8F),
                                                  fontSize: 18,
                                                  fontFamily: 'MideaType',
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              '照明${localLight == 'on' ? '开' : '关'}',
                                              style: const TextStyle(
                                                  color: Color(0xFF8F8F8F),
                                                  fontSize: 18,
                                                  fontFamily: 'MideaType',
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(scrollbars: false),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          child: ModeCard(
                                            spacing: 40,
                                            modeList: liangyiModes,
                                            selectedKeys: getSelectedKeys(),
                                            onTap: modeHandle,
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          child: FunctionCard(
                                            title: '照明',
                                            subTitle:
                                                localLight == 'on' ? '开' : '关',
                                            child: MzSwitch(
                                              value: localLight == 'on',
                                              onTap: (e) => lightHandle(e),
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
