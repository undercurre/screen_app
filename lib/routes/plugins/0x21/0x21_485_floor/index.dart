import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../common/global.dart';
import '../../../../states/device_list_notifier.dart';
import '../../../../widgets/event_bus.dart';
import '../../../../widgets/plugins/slider_485_button_card.dart';
import 'floor_data_adapter.dart';

class FloorHeating485PageState extends State<FloorHeating485Page> {
  String targetTemp = "30";
  String currentTemp = "32";
  String OnOff = "1";
  FloorDataAdapter? adapter;
  String name = "";

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    if (adapter!.data!.OnOff) {
      adapter!.data!.OnOff = false;
      OnOff = "0";
      setState(() {});
      adapter?.orderPower(0);
    } else {
      adapter!.data!.OnOff = true;
      OnOff = "1";
      setState(() {});
      adapter?.orderPower(1);
    }
  }

  Future<void> temperatureHandle(num value) async {
    if (OnOff == '0') {
      return;
    }
    adapter?.orderTemp(value.toInt());
    targetTemp = value.toString();
    adapter!.data!.targetTemp = value.toInt();
  }

  Future<void> updateDetail() async {
    adapter?.fetchData();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        name = args?['name'] ?? "";
        adapter = args?['adapter'];
        targetTemp = adapter!.data!.targetTemp.toString();
        currentTemp = adapter!.data!.currentTemp.toString();
        OnOff = adapter!.data!.OnOff ? "1" : "0";
        adapter!.bindDataUpdateFunction(update485FloorDetialData);
        logger.i("初始化地暖详情");
      });

      updateDetail();
    });
    super.initState();
  }

  void update485FloorDetialData() {
    if (mounted) {
      logger.i("详情地暖室内温度:${adapter!.data!.currentTemp}");
      setState(() {
        adapter?.data = adapter!.data;
        targetTemp = adapter!.data!.targetTemp.toString();
        OnOff = adapter!.data!.OnOff ? "1" : "0";
        currentTemp = adapter!.data!.currentTemp.toString();
      });
    }
  }

  @override
  void dispose() {
    logger.i("解绑数据更新");
    adapter!.unBindDataUpdateFunction(update485FloorDetialData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel =
        Provider.of<DeviceInfoListModel>(context, listen: false);

    String getDeviceName() {
      String nameInModel = deviceListModel.getDeviceName(
          deviceId: adapter?.applianceCode,
          maxLength: 6,
          startLength: 3,
          endLength: 2);

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
            top: 50,
            left: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTemp,
                  style: const TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 66.0,
                    fontFamily: "MideaType",
                    fontWeight: FontWeight.w200,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 25, 0, 0),
                  child: Text(
                    "℃",
                    style: TextStyle(
                      color: Color(0xff959595),
                      fontSize: 20.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.w200,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Positioned(
              top: 155,
              left: 15,
              child: Text(
                "室内温度",
                style: TextStyle(
                  color: Color(0x77ffffff),
                  fontSize: 16.0,
                  fontFamily: "MideaType",
                  fontWeight: FontWeight.w200,
                  decoration: TextDecoration.none,
                ),
              )),
          const Positioned(
            top: 120,
            left: 0,
            child: Image(
              width: 276,
              height: 386,
              image: AssetImage(
                  "assets/imgs/plugins/0xAC_floorHeating/floor_heating_485.png"),
            ),
          ),
          Column(
            children: [
              MzNavigationBar(
                onLeftBtnTap: goBack,
                onRightBtnTap: powerHandle,
                title: getDeviceName(),
                power: OnOff == '1',
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
                            child: Slider485ButtonCard(
                              disabled: OnOff == '0',
                              min: 5,
                              max: 90,
                              step: 1,
                              value: int.parse(targetTemp),
                              onChanged: temperatureHandle,
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

class FloorHeating485Page extends StatefulWidget {
  const FloorHeating485Page({super.key});

  @override
  State<FloorHeating485Page> createState() => FloorHeating485PageState();
}
