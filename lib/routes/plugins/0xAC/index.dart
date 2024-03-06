
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/gateway_platform.dart';
import '../../../states/device_list_notifier.dart';
import '../../../widgets/business/dropdown_menu.dart' as ui;
import 'data_adapter.dart';

class AirConditionPageState extends State<AirConditionPage> {
  WIFIAirDataAdapter? dataAdapter;

  void goBack() {
    Navigator.pop(context);
  }

  List<Map<String, dynamic>> modeList = [];

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    selectKeys[dataAdapter?.data!.mode ?? "auto"] = true;
    return selectKeys;
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
    super.dispose();
    dataAdapter?.unBindDataUpdateFunction(updateCallback);
  }

  void updateCallback() {
    setState(() {});
  }

  List<Map<String, String>> btnList = [
    {
      'icon': 'assets/newUI/acmodel/zidong.png',
      'text': '自动',
      'key': 'auto'
    },
    {
      'icon': 'assets/newUI/acmodel/zhileng.png',
      'text': '制冷',
      'key': 'cool'
    },
    {
      'icon': 'assets/newUI/acmodel/zhire.png',
      'text': '制热',
      'key': 'heat'
    },
    {
      'icon': 'assets/newUI/acmodel/songfeng.png',
      'text': '送风',
      'key': 'fan'
    },
    {
      'icon': 'assets/newUI/acmodel/chushi.png',
      'text': '除湿',
      'key': 'dry'
    },
  ];

  Map<String, String> getCurModeConfig() {
    Map<String, String> curMode =
        btnList.where((element) => element["key"] == (dataAdapter?.data!.mode ?? "auto")).toList()[0];
    return curMode;
  }

  @override
  Widget build(BuildContext context) {

    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);


    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceNameNormal(
          deviceId: dataAdapter?.applianceCode);

      if (deviceListModel.deviceListHomlux.isEmpty &&
          deviceListModel.deviceListMeiju.isEmpty) {
        return '加载中';
      }

      return nameInModel;
    }


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
              child: AirCondition(
                temperature: dataAdapter?.data!.indoorTemperature.toInt().toString(),
                windSpeed: dataAdapter?.data!.wind,
                mode: dataAdapter?.data!.mode,
              )
          ),
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
                    onRightBtnTap: () {
                      dataAdapter?.controlPower();
                    },
                    title: getDeviceName(),
                    power: dataAdapter?.data!.power ?? false,
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
                        dataAdapter?.fetchData();
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
                                      child: ui.DropdownMenu(
                                        disabled: dataAdapter?.data!.power == false,
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
                                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: dataAdapter?.data!.mode== item['key']
                                                          ? const Color(
                                                              0x26101010)
                                                          : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Image.asset(item['icon']!),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                                          child: Text(
                                                            item['text']!,
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontFamily: "MideaType",
                                                              fontWeight: FontWeight.w200,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        trigger: Row(
                                          children: [
                                            Image.asset(getCurModeConfig()[
                                            "icon"] ??
                                                "assets/newUI/acmodel/zidong.png"),
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                              child: Text(
                                                getCurModeConfig()["text"] ??
                                                    '自动',
                                                style: const TextStyle(
                                                  color: Color(0XFFFFFFFF),
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
                                        onSelected: (dynamic mode) {
                                          if (mode != null &&
                                              mode != getSelectedKeys()) {
                                            dataAdapter?.controlMode(mode);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: SliderButtonCard(
                                      disabled: dataAdapter?.data!.power == false ||
                                          dataAdapter?.data!.mode == 'fan',
                                      min: dataAdapter?.data!.minTemperature ?? 16,
                                      max: dataAdapter?.data!.maxTemperature ?? 30,
                                      step: 0.5,
                                      value: (dataAdapter?.data!.temperature ?? 16) + (dataAdapter?.data!.smallTemperature ?? 0),
                                      onChanged: dataAdapter?.controlTemperature,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: GearCard(
                                      disabled: dataAdapter?.data!.power == false ||
                                          dataAdapter?.data!.mode == 'auto' ||
                                          dataAdapter?.data!.mode == 'dry',
                                      value: ((dataAdapter?.data!.wind ?? 0) / 20).truncate() + 1,
                                      onChanged: dataAdapter?.controlGear,
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
