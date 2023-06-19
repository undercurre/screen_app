import 'dart:async';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:screen_app/common/api/gateway_api.dart';
import 'package:screen_app/common/api/index.dart';
import 'package:screen_app/common/push.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/routes/home/device/register_controller.dart';
import 'package:screen_app/routes/home/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';

import '../../../common/api/user_api.dart';
import '../../../common/global.dart';
import '../../../states/room_change_notifier.dart';
import '../../../widgets/event_bus.dart';
import 'device_card.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late EasyRefreshController _controller;
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  double roomTitleScale = 1;
  Function(Map<String, dynamic> arg)? cb;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  List<Map<String, String>> btnList = [
    {'title': '添加设备', 'route': 'SnifferPage'},
    {'title': '切换房间', 'route': 'SelectRoomPage'}
  ];

  List<Widget> deviceWidgetList = [];
  List<DeviceEntity> deviceEntityList = [];

  initPage() async {
    if (mounted) {
      var deviceModel = context.read<DeviceListModel>();
      // 更新设备detail
      await deviceModel.updateAllDetail();
      var entityList = deviceModel.showList;
      setState(() {
        deviceEntityList = entityList;
        deviceWidgetList = deviceEntityList
            .map((device) => DeviceCard(deviceInfo: device))
            .toList();
      });
      initDeviceState();
    }
  }

  initDeviceState() async {
    var deviceModel = context.read<DeviceListModel>();
    await deviceModel.onlyFetchDetailForAll();
    var entityList = deviceModel.showList;
    setState(() {
      deviceEntityList = entityList;

      deviceWidgetList = deviceEntityList.map((device) {
        logger.i('装载卡片数据', device);
        return DeviceCard(deviceInfo: device);
      }).toList();
    });
    bus.emit('updateDeviceCardState');
  }

  @override
  void initState() {
    super.initState();

    bus.on('updateDeviceListState', (arg) async {
      initPage();
    });

    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initPage();
    });

    _timer = Timer.periodic(const Duration(seconds: 60), setTime);
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final offset = min(_scrollController.offset, 150);
        setState(() {
          roomTitleScale = min(1 - (offset / 150), 1);
        });
      }
    });

    cb = (arg) {
      initPage();
      GatewayApi.check((bind,code) {
        if (!bind) {
          bus.emit('logout');
        }
      },() {
          //接口请求报错
      });
    };

    Push.listen("添加设备", cb!);
    Push.listen("解绑设备", cb!);
    Push.listen("删除设备", cb!);
  }

  void setTime(Timer timer) {
    setState(() {
      time = DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    Push.dislisten("添加设备", cb!);
    Push.dislisten("解绑设备", cb!);
    Push.dislisten("删除设备", cb!);
  }

  void toConfigPage(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget feedback(List<DraggableGridItem> list, int index) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 20,
      height: MediaQuery.of(context).size.height / 2 - 40,
      child: list[index].child,
    );
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: Container(
        color: Colors.transparent,
      ),
    );
  }

  void onDragAccept(
      List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    debugPrint('onDragAccept: $beforeIndex -> $afterIndex');
  }

  //声明星期变量
  var weekday = [" ", "周一", "周二", "周三", "周四", "周五", "周六", "周日"];
}
