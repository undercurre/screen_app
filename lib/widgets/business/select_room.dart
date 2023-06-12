import 'package:flutter/material.dart';

import '../../common/index.dart';
import '../../models/index.dart';
import '../index.dart';

class _SelectRoom extends State<SelectRoom> {
  var roomList = <RoomEntity>[];

  String _roomId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < roomList.length; i++) {
      var item = roomList[i];

      listView.add(MzCell(
        height: 99,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        title: item.name,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        titleSize: 24,
        descSize: 18,
        bgColor: Colors.transparent,
        desc: '设备${item.applianceList.length}',
        hasTopBorder: false,
        hasBottomBorder: i + 1 != roomList.length + 1,
        rightSlot: MzRadio<String>(
          activeColor: const Color.fromRGBO(0, 145, 255, 1),
          value: item.roomId!,
          groupValue: _roomId,
        ),
        onTap: () {
          setState(() {
            _roomId = item.roomId!;
          });

          widget.onChange?.call(item);
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
        ]));;
  }

  @override
  void initState() {
    super.initState();

    _roomId = widget.value;
    getHomeData();
  }

  /// 获取指定家庭信息
  void getHomeData() async {
    var res = await UserApi.getHomeListWithDeviceList(
        homegroupId: Global.profile.homeInfo?.homegroupId);

    if (res.isSuccess) {
      setState(() {
        var homeInfo = res.data.homeList[0];
        roomList = homeInfo.roomList ?? [];
      });
    }
  }
}

class SelectRoom extends StatefulWidget {
  // 默认选择的房间id
  final String value;

  /// 房间变更事件
  final ValueChanged<RoomEntity>? onChange;

  const SelectRoom({super.key, this.value = '', this.onChange});

  @override
  State<SelectRoom> createState() => _SelectRoom();
}
