import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../index.dart';

class _SelectRoom extends State<SelectRoom> {
  var roomList = <RoomInfo>[];

  String _roomId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < roomList.length; i++) {
      var item = roomList[i];

      listView.add(MzCell(
        title: item.name,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        desc: '设备${item.applianceList.length}',
        titleSize: 20.0,
        hasTopBorder: true,
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

    var homeListView = ListView(children: listView);

    return homeListView;
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
        var homeInfo = res.data.homeList[0] as HomeInfo;
        roomList = homeInfo.roomList ?? [];
      });
    }
  }
}

class SelectRoom extends StatefulWidget {
  // 默认选择的房间id
  final String value;

  /// 房间变更事件
  final ValueChanged<RoomInfo>? onChange;

  const SelectRoom({super.key, this.value = '', this.onChange});

  @override
  State<SelectRoom> createState() => _SelectRoom();
}
