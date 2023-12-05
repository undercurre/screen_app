import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/adapter/select_room_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/system.dart';
import '../index.dart';

class SelectRoomState extends State<SelectRoom> {
  SelectRoomDataAdapter? roomDataAd;
  int selectVal = -1;

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];

    var len = roomDataAd?.roomListEntity?.roomList.length ?? 0;
    for (var i = 0; i < len; i++) {
      var item = roomDataAd?.roomListEntity?.roomList[i];
      listView.add(MzCell(
        height: 99,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        title: item?.name,
        titleMaxLines: 1,
        titleMaxWidth: 320,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24,
        descSize: 18,
        tag: widget.defaultRoomId != null && widget.defaultRoomId == item!.id ? '当前房间' : null,
        bgColor: const Color(0xFF303441),
        desc: '设备${item?.deviceNum}',
        hasTopBorder: false,
        hasBottomBorder: i != len -1,
        topLeftRadius: i == 0 ? 16 : 0,
        topRightRadius: i == 0 ? 16 : 0,
        bottomLeftRadius: i == len -1 ? 16 : 0,
        bottomRightRadius: i == len -1 ? 16 : 0,
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

    if(len > 2) {
      listView.add(const SizedBox(
        width: 432,
        height: 44,
        child: Center(
            child: Text(
              '已经到底了~',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(
                      255, 255, 255, 0.85)),
            )),
      ));
    }

    return Container(
      width: 480,
      height: 340,
      alignment: Alignment.topCenter,
      child: Stack(
        children: [
          if(len == 0) Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 480,
              height: 260,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator(radius: 25),
            ),
          ),

          if(len > 0) SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 432,
                margin: const EdgeInsets.fromLTRB(24, 10, 24, 50),
                // decoration: const BoxDecoration(
                //     color: Color(0xFF303441),
                //     borderRadius: BorderRadius.all(Radius.circular(16))
                // ),
                child: Column(
                    children: listView.toList()
                ),
              )
          ),

        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    roomDataAd = SelectRoomDataAdapter(MideaRuntimePlatform.platform);
    roomDataAd?.bindDataUpdateFunction(() {
      var roomList = roomDataAd?.roomListEntity?.roomList;
      var findIndex = roomList?.indexWhere((element) => element.id == widget.defaultRoomId) ?? -1;
      if(findIndex != -1) {
        selectVal = findIndex;
        widget.onChange?.call(roomList![findIndex]);
      }
      setState(() {});
    });
    roomDataAd?.queryRoomList(System.familyInfo!);
  }

  void refreshList() {
    roomDataAd?.queryRoomList(System.familyInfo!);
  }
}

class SelectRoom extends StatefulWidget {
  /// 房间变更事件
  final ValueChanged<SelectRoomItem>? onChange;
  final String? defaultRoomId;

  const SelectRoom({super.key, this.onChange, this.defaultRoomId});

  @override
  State<SelectRoom> createState() => SelectRoomState();
}
