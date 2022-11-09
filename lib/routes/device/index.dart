import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import 'DeviceItem.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<DraggableGridItem> itemBins = [];
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 480,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("客厅",
                    style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: 30.0,
                      fontFamily: "MideaType",
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    )),
              ],
            ),
          ),
          Container(
            width: 480,
            height: 1,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
          Container(
            height: 380,
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: DraggableGridViewBuilder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // 垂直方向item之间的间距
                mainAxisSpacing: 10.0,
                // 水平方向item之间的间距
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.6,
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
}
