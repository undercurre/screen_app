import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../../widgets/index.dart';

class _SelectHome extends State<SelectHome> {
  List<HomeList> homeList = [];

  String homeId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < homeList.length; i++) {
      var item = homeList[i];

      listView.add(Cell(
        title: item.name,
        titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
        // tag: '我创建的',
        desc: '房间${item.roomCount} | 设备${item.applianceCount} | 成员${item.memberCount} | ${item.address}',
        titleSize: 20.0,
        hasTopBorder: true,
        bgColor: homeId == item.homegroupId ? const Color.fromRGBO(216, 216, 216, 0.2) : const Color.fromRGBO(216, 216, 216, 0.1),
        onTap: () {
          debugPrint('onTap: ${item.name}');
          setState(() {
            homeId = item.homegroupId;
          });

          Global.profile.homeInfo = item;
        },
      ));
    }

    var homeListView = ListView(
      children: listView
    );

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
      setState((){
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
