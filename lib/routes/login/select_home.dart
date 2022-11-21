import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

class _SelectHome extends State<SelectHome> {
  List<HomeInfo> homeList = [];

  String homeId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < homeList.length; i++) {
      var item = homeList[i];

      listView.add(
        Cell(
            title: item.name,
            titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
            // tag: '我创建的',
            desc:
                '房间${item.roomCount} | 设备${item.applianceCount} | 成员${item.memberCount} | ${item.address}',
            titleSize: 20.0,
            hasTopBorder: true,
            onTap: () {
              debugPrint('onTap: ${item.name}');
              setState(() {
                homeId = item.homegroupId;
              });

              Global.profile.homeInfo = item;
            },
            rightSlot: MzRadio<String>(
              activeColor: const Color.fromRGBO(0, 145, 255, 1),
              value: item.homegroupId,
              groupValue: homeId,
            )),
      );
    }

    var homeListView = ListView(children: listView);

    return homeListView;
  }

  @override
  void initState() {
    super.initState();
    getHomeListData();
  }

  /// 获取家庭列表数据
  void getHomeListData() async {
    var res = await MideaApi.getHomegroup();

    if (res.isSuccess) {
      setState(() {
        homeList = res.data.homeList;
      });
    }
  }
}

class SelectHome extends StatefulWidget {
  const SelectHome({super.key});

  @override
  State<SelectHome> createState() => _SelectHome();
}
