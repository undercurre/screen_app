import 'package:flutter/material.dart';

import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/system.dart';
import '../index.dart';

class _SelectRoom extends State<SelectRoom> {
  SelectRoomDataAdapter? roomDataAd;
  int selectVal = -1;

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];

    var len = roomDataAd?.familyListEntity?.familyList.length ?? 0;
    for (var i = 0; i < len; i++) {
      var item = roomDataAd?.familyListEntity?.familyList[i];
      listView.add(MzCell(
        height: 99,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        title: item?.name,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24,
        descSize: 18,
        bgColor: Colors.transparent,
        desc: '设备${item?.deviceNum}',
        hasTopBorder: false,
        hasBottomBorder: i + 1 != len + 1,
        rightSlot: MzRadio<int>(
          activeColor: const Color.fromRGBO(0, 145, 255, 1),
          value: i,
          groupValue: selectVal,
        ),
        onTap: () {
          setState(() {
            selectVal = i;
          });

          widget.onChange?.call(item!);
        },
      ));
    }

    listView.add(Container(
      width: 432,
      height: 44,
      color: Colors.white.withOpacity(0.05),
      child: const Center(
          child: Text(
            '已经到底了！',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(
                    255, 255, 255, 0.85)),
          )),
    ));

    var homeListView = ListView(children: listView);

    return Container(
        margin: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.05),
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Column(children: [
          Expanded(child: homeListView),
        ]));
  }

  @override
  void initState() {
    super.initState();

    roomDataAd = SelectRoomDataAdapter(MideaRuntimePlatform.platform);
    roomDataAd?.bindDataUpdateFunction(() {
      setState(() {});
    });
    roomDataAd?.queryRoomList(System.familyInfo!);
  }
}

class SelectRoom extends StatefulWidget {
  /// 房间变更事件
  final ValueChanged<SelectRoomItem>? onChange;

  const SelectRoom({super.key, this.onChange});

  @override
  State<SelectRoom> createState() => _SelectRoom();
}
