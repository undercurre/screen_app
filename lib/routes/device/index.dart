import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:date_format/date_format.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/api/device_api.dart';
import 'package:screen_app/models/device_home_list_entity.dart';
import 'package:screen_app/routes/device/config.dart';
import 'package:screen_app/routes/device/service.dart';
import 'package:screen_app/states/device_change_notifier.dart';
import '../../common/global.dart';
import 'device_item.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  initPage() async {
    List<DraggableGridItem> newBins = [];
    var deviceList = Global.profile.roomInfo != null ? Global.profile.roomInfo!.applianceList! : [];
    for (int xx = 1; xx <= deviceList.length; xx++) {
      var deviceInfo = deviceList[xx - 1];
      var config = DeviceService.configFinder(deviceInfo);
      var hasService = serviceList.keys.toList().where((element) => element == config.apiCode).length == 1;
      if (hasService && DeviceService.isOnline(deviceInfo)) {
        var detail = await DeviceService.getDeviceDetail(config.apiCode, deviceInfo);
        var curDevice = Global.profile.roomInfo!.applianceList.where((element) => element.applianceCode == deviceInfo.applianceCode).toList()[0];
        curDevice.detail = detail;
        debugPrint('curDevice${curDevice.toJson()}');
        debugPrint(curDevice.detail.toString());
      }
      newBins.add(DraggableGridItem(
        child: DeviceItem(deviceInfo: deviceInfo),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          debugPrint('设备$xx+"isDragging: $isDragging');
        },
      ));
    }
    setState(() {
      itemBins = newBins;
    });
  }

  @override
  void initState() {
    for (int xx = 1; xx < 7; xx++) {
      itemBins.add(DraggableGridItem(
        child: const DeviceItem(),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          debugPrint('设备$xx+"isDragging: $isDragging');
        },
      ));
    }
    initPage();
    _timer = Timer.periodic(const Duration(seconds: 1), setTime);
    super.initState();
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
  }

  void toSelectRoom() {
    Navigator.pushNamed(context, 'Room');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${time.month}月${time.day}日  ${weekday[time.weekday]}     ${formatDate(time, [
                          HH,
                          ':',
                          nn
                        ])}",
                    style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 18.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
                GestureDetector(
                  onTap: () => toSelectRoom(),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Image.asset(
                      "assets/imgs/icon/select_room.png",
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(Global.profile.roomInfo?.name ?? '房间',
                    style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 30.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ))
              ],
            ),
          ),
          Expanded(
            child: ChangeNotifierProvider(
              create: (_) => DeviceListChangeNotifier(),
              child: DraggableGridViewBuilder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // 垂直方向item之间的间距
                  mainAxisSpacing: 17.0,
                  // 水平方向item之间的间距
                  crossAxisSpacing: 17.0,
                  childAspectRatio: 0.7,
                ),
                children: itemBins,
                dragCompletion: onDragAccept,
                isOnlyLongPress: true,
                dragFeedback: feedback,
                dragPlaceHolder: placeHolder,
              ),
            ),
          )
        ],
      ),
    );
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
    print('onDragAccept: $beforeIndex -> $afterIndex');
  }

  //声明星期变量
  var weekday = [" ", "周一", "周二", "周三", "周四", "周五", "周六", "周日"];
}
