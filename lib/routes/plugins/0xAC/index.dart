import 'package:easy_refresh/easy_refresh.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/plugins/air_condition.dart';

import '../../../states/device_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/routes/plugins/0xAC/api.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../widgets/plugins/arrow.dart';
import '../../device/service.dart';

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


  void goBack() {
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    var res = await AirConditionApi.powerLua(
        deviceWatch["deviceId"], !(deviceWatch["detail"]["power"] == 'on'));

    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["power"] =
            deviceWatch["detail"]["power"] == "on" ? "off" : "on";
      });
    }
  }

  Future<void> gearHandle(value) async {
    var res = await AirConditionApi.gearLua(deviceWatch["deviceId"], value);

    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["wind_speed"] =
            deviceWatch["detail"]["wind_speed"] = value;
      });
    }
  }

  Future<void> temperatureHandle(value) async {
    var res =
        await AirConditionApi.temperatureLua(deviceWatch["deviceId"], value);

    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["temperature"] = value;
      });
    }
  }

  Future<void> modeHandle(String mode) async {
    var res = await AirConditionApi.modeLua(deviceWatch["deviceId"], mode);

    if (res.isSuccess) {
      setState(() {
        deviceWatch["detail"]["mode"] = mode;
      });
    }
  }

  List<Map<String, dynamic>> modeList = [];

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[deviceWatch["detail"]["screenModel"]] = true;
    return selectKeys;
  }

  Future<void> updateDetail() async {
    var deviceInfo = context
        .read<DeviceListModel>()
        .getDeviceInfoById(deviceWatch["deviceId"]);
    var detail = await DeviceService.getDeviceDetail(deviceInfo);
    setState(() {
      deviceWatch["detail"] = detail;
    });
    debugPrint('插件中获取到的详情：$deviceWatch');
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
      });
      deviceWatch = context
          .read<DeviceListModel>()
          .getDeviceDetail(deviceWatch["deviceId"]);
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
    Map<String, String> curMode = btnList.where((element) => element["key"] == deviceWatch["detail"]["mode"]).toList()[0];
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
                temperature: deviceWatch["detail"]["temperature"],
                windSpeed: deviceWatch["detail"]["windSpeed"],
                mode: deviceWatch["detail"]["mode"],
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
                    power: deviceWatch["detail"]["power"] == 'on',
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
                                  FunctionCard(
                                    title: '模式',
                                    child: PopupMenuButton(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      )),
                                      offset: const Offset(0, 36.0),
                                      itemBuilder: (context) {
                                        return btnList.map(
                                          (item) {
                                            return PopupMenuItem<String>(
                                              value: item['key'],
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  width: 80,
                                                  height: 50,
                                                  child: Opacity(
                                                    opacity: 0.5,
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                            item['icon']!),
                                                        Text(item['text']!,
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    "MideaType",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList();
                                      },
                                      onSelected: (String mode) {
                                        modeHandle(mode);
                                      },
                                      child: Row(
                                        children: [
                                          Opacity(
                                              opacity: 0.5,
                                              child: Image.asset(getCurModeConfig()["icon"] ?? "assets/imgs/plugins/0xAC/zidong_icon.png")
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                            child: Text(
                                              getCurModeConfig()["text"] ?? '自动',
                                              style: const TextStyle(
                                                color: Color(0X7FFFFFFF),
                                                fontSize: 18.0,
                                                fontFamily: "MideaType",
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                          Stack(
                                            children: const [
                                              SizedBox(
                                                width: 36,
                                                height: 36,
                                              ),
                                              Positioned(
                                                  top: -2,
                                                  left: 0,
                                                  child: AnimatedArrow())
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliderButtonCard(
                                    min: 17,
                                    max: 30,
                                    step: 0.5,
                                    value: deviceWatch["detail"]
                                            ["temperature"] +
                                        deviceWatch["detail"]
                                            ["small_temperature"],
                                    onChanged: temperatureHandle,
                                  ),
                                  GearCard(
                                    value: (deviceWatch["detail"]
                                                    ["wind_speed"] /
                                                20)
                                            .truncate() +
                                        1,
                                    onChanged: gearHandle,
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
