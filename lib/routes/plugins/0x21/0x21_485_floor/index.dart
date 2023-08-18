import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../widgets/event_bus.dart';
import 'floor_data_adapter.dart';

class FloorHeating485PageState extends State<FloorHeating485Page> {

  String targetTemp="";
  FloorDataAdapter? adapter;
  String name="";

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    if(adapter!.data.OnOff == '1'){
      adapter?.orderPower(0);
      adapter!.data.OnOff="0";
    }else{
      adapter?.orderPower(1);
      adapter!.data.OnOff="1";
    }
    setState(() {

    });
  }

  Future<void> temperatureHandle(num value) async {
    adapter?.orderTemp(value.toInt());
    targetTemp=value.toString();
    adapter!.data.targetTemp=targetTemp;
  }

  Future<void> updateDetail() async {

  }

  @override
  void initState() {
    super.initState();
    adapter?.bindDataUpdateFunction(() {setState(() {});});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map?;
    name= args?['name'] ?? "";
    adapter= args?['adapter'];
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
          const Positioned(
            top: 96,
            left: 0,
            child: Image(
              width: 276,
              height: 386,
              image: AssetImage("assets/imgs/plugins/0xAC_floorHeating/floor_heating_dev.png"),
            ),
          ),

          Column(
            children: [
              MzNavigationBar(
                onLeftBtnTap: goBack,
                onRightBtnTap: powerHandle,
                title: name,
                power: adapter!.data.OnOff == '1',
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
                            child: SliderButtonCard(
                              disabled: adapter!.data.OnOff == '0',
                              min: 5,
                              max: 90,
                              step: 1,
                              value: int.parse(adapter!.data.targetTemp),
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
