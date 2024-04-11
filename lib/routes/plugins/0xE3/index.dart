
import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../common/gateway_platform.dart';
import '../../../states/device_list_notifier.dart';
import '../../../widgets/business/dropdown_menu.dart' as ui;
import '../../../widgets/plugins/electric_water_heater.dart';
import '../../../widgets/plugins/gas_water_heater.dart';
import 'data_adapter.dart';
import 'mode_list.dart';

class GasWaterHeaterPageState extends State<GasWaterHeaterPage> {
  GasWaterHeaterDataAdapter? dataAdapter;
  String modeTap="";

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
    if (mounted) {
      setState(() {
      });
    }
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
              child: GasWaterHeater(

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
                                    child: SliderButtonCard(
                                      disabled: dataAdapter?.data!.power == false,
                                      min: dataAdapter?.data!.minTemperature ?? 32,
                                      max: dataAdapter?.data!.maxTemperature ?? 65,
                                      step: 1,
                                      value: (dataAdapter?.data!.temperature ?? 40),
                                      onChanged: dataAdapter?.controlTemperature,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ModeCard(
                                      hasHeightlight: true,
                                      modeList: gasWaterHeaterModes,
                                      selectedKeys: getSelectedKeys(),
                                      onTap: (mode) {
                                        setState(() {
                                          modeTap = mode.key;
                                          log("选择的模式:$modeTap");
                                        });
                                        Timer(const Duration(milliseconds: 500), () {
                                          setState(() {
                                            modeTap = "";
                                          });
                                        });
                                        dataAdapter?.controlMode(mode.key);
                                      },
                                      disabled: dataAdapter?.data!.power ?? true ? false : true,
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
