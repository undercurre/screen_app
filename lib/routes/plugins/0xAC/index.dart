import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../home/device/service.dart';

class AirConditionPageState extends State<AirConditionPage> {
  Map<String, dynamic> deviceWatch = {
    "deviceId": "",
    "deviceName": '空调',
    "detail": {
      "mode": 'auto',
      "temperature": 26,
      "small_temperature": 0.5,
      "wind_speed": 102
    }
  };

  var localPower = 'off';
  var localMode = 'auto';
  var localTemp = 26;
  num localSmallTemp = 0.5;
  var localWind = 102;

  bool menuVisible = false;

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

  Future<void> gearHandle(value) async {
    var res = await AirConditionApi.gearLua(
        deviceWatch["deviceId"], value > 0 ? (value - 1) * 20 : 1);

    if (res.isSuccess) {
      setState(() {
        localWind = value;
      });
    }
  }

  Future<void> temperatureHandle(value) async {
    var res =
        await AirConditionApi.temperatureLua(deviceWatch["deviceId"], value);

    if (res.isSuccess) {
      setState(() {
        localTemp = value;
      });
    }
  }

  Future<void> modeHandle(String mode) async {
    var res = await AirConditionApi.modeLua(deviceWatch["deviceId"], mode);

    if (res.isSuccess) {
      setState(() {
        localMode = mode;
      });
    }
  }

  List<Map<String, dynamic>> modeList = [];

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[localMode] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"] = detail;
      localPower = detail["power"];
      localMode = detail["mode"];
      localTemp = detail["temperature"];
      localSmallTemp = detail["small_temperature"];
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
        localPower = deviceDetail["detail"]["power"];
        localMode = deviceDetail["detail"]["mode"];
        localTemp = deviceDetail["detail"]["temperature"];
        localSmallTemp = deviceDetail["detail"]["small_temperature"];
        localWind = deviceDetail["detail"]["wind_speed"];
      });
      deviceWatch = context
          .read<DeviceListModel>()
          .getDeviceDetailById(deviceWatch["deviceId"]);
      debugPrint('插件中获取到的详情：$deviceWatch');
    });
  }

  List<Map<String, String>> btnList = [
    {
      'icon': 'assets/imgs/plugins/0xAC/zidong_icon.png',
      'text': '自动',
      'key': 'auto'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhileng_icon.png',
      'text': '制冷',
      'key': 'cool'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/zhire_icon.png',
      'text': '制热',
      'key': 'heat'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/songfeng_icon.png',
      'text': '送风',
      'key': 'fan'
    },
    {
      'icon': 'assets/imgs/plugins/0xAC/chushi_icon.png',
      'text': '除湿',
      'key': 'dry'
    },
  ];

  Map<String, String> getCurModeConfig() {
    Map<String, String> curMode =
        btnList.where((element) => element["key"] == localMode).toList()[0];
    return curMode;
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
              child: AirCondition(
                temperature: localTemp,
                windSpeed: localWind,
                mode: localMode,
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
                    power: localPower == 'on',
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
                        updateDetail();
                      },
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            const Align(
                              widthFactor: 1,
                              heightFactor: 1,
                              alignment: Alignment(-1.0, -0.63),
                              child: SizedBox(
                                width: 152,
                                height: 303,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: FunctionCard(
                                      title: '模式',
                                      child: DropdownMenu(
                                        disabled: localPower == 'off',
                                        menu: btnList.map(
                                          (item) {
                                            return PopupMenuItem<String>(
                                              padding: EdgeInsets.zero,
                                              value: item['key'],
                                              child: MouseRegion(
                                                child: Center(
                                                  child: Container(
                                                    width: 130,
                                                    height: 50,
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: false // TODO: 完善
                                                          ? const Color(
                                                              0xff575757)
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Opacity(
                                                      opacity: true // TODO: 完善
                                                          ? 1
                                                          : 0.7,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                              item['icon']!),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    7, 0, 7, 0),
                                                            child: Text(
                                                              item['text']!,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    "MideaType",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        trigger: Opacity(
                                          opacity: menuVisible ? 0.5 : 1,
                                          child: Row(
                                            children: [
                                              Image.asset(getCurModeConfig()[
                                                      "icon"] ??
                                                  "assets/imgs/plugins/0xAC/zidong_icon.png"),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        7, 0, 7, 0),
                                                child: Text(
                                                  getCurModeConfig()["text"] ??
                                                      '自动',
                                                  style: const TextStyle(
                                                    color: Color(0X7FFFFFFF),
                                                    fontSize: 18.0,
                                                    fontFamily: "MideaType",
                                                    fontWeight: FontWeight.w200,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onVisibleChange: (visible) {
                                          setState(() {
                                            menuVisible = visible;
                                          });
                                        },
                                        onSelected: (dynamic mode) {
                                          if (mode != null &&
                                              mode != getSelectedKeys()) {
                                            modeHandle(mode);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: SliderButtonCard(
                                      disabled: localPower == 'off' ||
                                          localMode == 'fan',
                                      min: 17,
                                      max: 30,
                                      step: 0.5,
                                      value: localTemp + localSmallTemp,
                                      onChanged: temperatureHandle,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: GearCard(
                                      disabled: localPower == 'off' ||
                                          localMode == 'auto' ||
                                          localMode == 'dry',
                                      value: (localWind / 20).truncate() + 1,
                                      onChanged: gearHandle,
                                    ),
                                  ),
                                ],
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

class AirConditionPage extends StatefulWidget {
  const AirConditionPage({super.key});

  @override
  State<AirConditionPage> createState() => AirConditionPageState();
}
