import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../widgets/event_bus.dart';
import '../0x21_485_cac/cac_data_adapter.dart';
import 'air_data_adapter.dart';

class FreshAir485PageState extends State<FreshAir485Page> {

  var localWind = 1;

  AirDataAdapter? adapter;
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

  Future<void> gearHandle(num value) async {
    adapter?.orderSpeed(value.toInt());
    localWind=value.toInt();
    adapter!.data.windSpeed=value.toString();
  }

  Future<void> updateDetail() async {
    adapter?.fetchData();
  }

  @override
  void initState() {
    super.initState();


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
    localWind=int.parse(adapter!.data.windSpeed);
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
            top: 117,
            left: 0,
            child: Image(
              width: 190,
              height: 246,
              image: AssetImage("assets/imgs/plugins/0xAC_newWind/new_wind_dev.png"),
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
                            child: GearCard(
                              maxGear: 3,
                              minGear: 1,
                              disabled:  false,
                              value: localWind,
                              onChanged: gearHandle,
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

class FreshAir485Page extends StatefulWidget {
  const FreshAir485Page({super.key});

  @override
  State<FreshAir485Page> createState() => FreshAir485PageState();
}
