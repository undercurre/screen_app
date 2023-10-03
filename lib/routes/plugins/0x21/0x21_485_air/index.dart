import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/widgets/index.dart';

import '../../../../common/logcat_helper.dart';
import '../../../../states/device_list_notifier.dart';
import '../../../../widgets/event_bus.dart';
import 'air_data_adapter.dart';

class FreshAir485PageState extends State<FreshAir485Page> {
  var localWind = 1;
  String OnOff = "0";

  AirDataAdapter? adapter;
  String name = "";

  void goBack() {
    bus.emit('updateDeviceCardState');
    Navigator.pop(context);
  }

  Future<void> powerHandle() async {
    if (adapter!.data!.OnOff == '1') {
      adapter!.data!.OnOff = "0";
      OnOff = "0";
      setState(() {});
      adapter?.orderPower(0);
    } else {
      adapter!.data!.OnOff = "1";
      OnOff = "1";
      setState(() {});
      adapter?.orderPower(1);
    }
  }

  Future<void> gearHandle(num value) async {
    if(OnOff == '0'){
      return;
    }
    if (value == 1) {
      value = 4;
    } else if (value == 3) {
      value = 1;
    }
    localWind = value.toInt();
    adapter!.data!.windSpeed = value.toString();
    setState(() {});
    adapter?.orderSpeed(value.toInt());

  }

  Future<void> updateDetail() async {
    adapter?.fetchData();
  }

  int setWinSpeed(int wind) {
    int speed = wind;
    if (speed == 1) {
      speed = 3;
    } else if (speed == 2) {
      speed = 2;
    } else if (speed == 4) {
      speed = 1;
    } else {
      speed = 3;
    }
    return speed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<dynamic, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map?;
      setState(() {
        name = args?['name'] ?? "";
        adapter = args?['adapter'];
        localWind = int.parse(adapter!.data!.windSpeed);
        OnOff = adapter!.data!.OnOff;
        adapter!.bindDataUpdateFunction(updateData);
      });
      updateDetail();
    });
  }

  void updateData() {
    Log.i("更新状态");
    if (mounted) {
      Log.i("进来更新状态");
      setState(() {
        adapter?.data = adapter!.data!;
        localWind = int.parse(adapter!.data!.windSpeed);
        OnOff = adapter!.data!.OnOff;
        Log.i("更新状态完成");
      });
    }
  }

  @override
  void dispose() {
    adapter!.unBindDataUpdateFunction(updateData);
    adapter!.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceListModel = Provider.of<DeviceInfoListModel>(context);

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
          const Positioned(
            top: 117,
            left: 0,
            child: Image(
              width: 190,
              height: 246,
              image: AssetImage(
                  "assets/imgs/plugins/0xAC_newWind/new_wind_dev.png"),
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
                            child: GearCard(
                              maxGear: 3,
                              minGear: 1,
                              disabled: OnOff == '0',
                              value: setWinSpeed(localWind),
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
