import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

class _SelectRoom extends State<SelectRoom> {
  var roomList = <RoomInfo>[];

  String roomId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < roomList.length; i++) {
      var item = roomList[i];

      listView.add(MzCell(
        title: item.name,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        desc: '设备',
        titleSize: 20.0,
        hasTopBorder: true,
        rightSlot: MzRadio<String>(
          activeColor: const Color.fromRGBO(0, 145, 255, 1),
          value: item.roomId,
          groupValue: roomId,
        ),
        onTap: () {
          debugPrint('onTap: ${item.name}');
          setState(() {
            roomId = item.roomId;
          });

          Global.profile.roomInfo = item;
        },
      ));
    }

    var homeListView = ListView(children: listView);

    return homeListView;
  }

  @override
  void initState() {
    super.initState();

    getHomeData();
  }

  /// 获取指定家庭信息
  void getHomeData() async {
    var res = await MideaApi.getHomeList(
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
  const SelectRoom({super.key});

  @override
  State<SelectRoom> createState() => _SelectRoom();
}
