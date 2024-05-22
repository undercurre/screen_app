import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../states/device_list_notifier.dart';
import '../../../widgets/plugins/gas_water_heater.dart';
import 'data_adapter.dart';

class GasWaterHeaterPageState extends State<GasWaterHeaterPage> {
  GasWaterHeaterDataAdapter? dataAdapter;
  String modeTap = "";

  void goBack() {
    Navigator.pop(context);
  }

  List<Map<String, dynamic>> modeList = [];

  Map<String, bool?> getSelectedKeys() {
    final selectKeys = <String, bool?>{};
    if (modeTap != null) {
      selectKeys[modeTap] = true;
    }
    return selectKeys;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map?;
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

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
          const Positioned(left: 0, top: 0, child: GasWaterHeater()),
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
                                    child: SliderButtonCard(
                                      disabled:
                                          dataAdapter?.data!.power == false,
                                      min: dataAdapter?.data!.minTemperature ??
                                          32,
                                      max: dataAdapter?.data!.maxTemperature ??
                                          65,
                                      step: 1,
                                      value: (dataAdapter?.data!.temperature ??
                                          40),
                                      onChanged:
                                          dataAdapter?.controlTemperature,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(7, 0, 7, 16),
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 15, 20, 15),
                                    decoration: const BoxDecoration(
                                      color: Color(0x19FFFFFF),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                         Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: Image(
                                                  image: AssetImage(
                                                      'assets/imgs/plugins/0xE2/cold_water_master.png'),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(left: 11),
                                                child:  const Text("零冷水",
                                                    style: TextStyle(
                                                      color: Color(0XFFFFFFFF),
                                                      fontSize: 18.0,
                                                      fontFamily: "MideaType",
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      decoration:
                                                      TextDecoration.none,
                                                    )),
                                              )
                                            ]),
                                        MzSwitch(
                                          activeColor: const Color(0xFF3C92D6),
                                          inactiveColor: const Color(0x33DCDCDC),
                                          pointActiveColor: const Color(0xFFDCDCDC),
                                          pointInactiveColor: const Color(0xFFDCDCDC),
                                          disabled:  dataAdapter?.data!.power == false,
                                          value: dataAdapter!.data!.coldWater,
                                          onTap: (bool value) {
                                            dataAdapter!.controlColdWater(value);
                                            setState(() {
                                              dataAdapter!.data!.coldWater=value;
                                            });
                                          },
                                        ),
                                      ],
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

class GasWaterHeaterPage extends StatefulWidget {
  const GasWaterHeaterPage({super.key});

  @override
  State<GasWaterHeaterPage> createState() => GasWaterHeaterPageState();
}
