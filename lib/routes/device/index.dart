import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:date_format/date_format.dart';
import 'DeviceItem.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<DraggableGridItem> itemBins = [];
  var time = DateTime.now();
  late Timer _timer;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    for (int xx = 1; xx < 16; xx++) {
      itemBins.add(DraggableGridItem(
        child: DeviceItem(deviceName: "设备$xx"),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          print('设备$xx+"isDragging: $isDragging');
        },
      ));
    }
    _timer = Timer.periodic(const Duration (seconds: 1), setTime);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                 Text("${time.month}月${time.day}日  ${weekday[time.weekday]}     ${formatDate(time,[HH,':',nn])}",
                    style: const TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 18.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
                GestureDetector(
                  onTap: () => {},
                  child:  Container(
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
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text("客厅",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 30.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ))
              ],
            ),
          ),
          Container(
            height: 325,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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

  void onDragAccept(List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    print('onDragAccept: $beforeIndex -> $afterIndex');
  }

  //声明星期变量
  var weekday = [" ", "周一", "周二", "周三", "周四", "周五", "周六", "周日"];
}
