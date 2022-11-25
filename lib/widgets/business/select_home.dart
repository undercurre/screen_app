import 'package:flutter/material.dart';
import '../../common/index.dart';
import '../../models/index.dart';
import '../index.dart';

class _SelectHome extends State<SelectHome> {
  List<HomeInfo> homeList = [];

  String _homeId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < homeList.length; i++) {
      var item = homeList[i];
      var addressList = item.address.split(' ');

      listView.add(
        MzCell(
            title: item.name,
            titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
            // tag: '我创建的',
            desc:
                '房间${item.roomCount} | 设备${item.applianceCount} | 成员${item.memberCount} | ${addressList.last}',
            titleSize: 20.0,
            hasTopBorder: true,
            onTap: () {
              setState(() {
                _homeId = item.homegroupId!;
              });

              widget.onChange?.call(item);
            },
            rightSlot: MzRadio<String>(
              activeColor: const Color.fromRGBO(0, 145, 255, 1),
              value: item.homegroupId!,
              groupValue: _homeId,
            )),
      );
    }

    var homeListView = ListView(children: listView);

    return homeListView;
  }

  @override
  void initState() {
    super.initState();

    _homeId = widget.value;
    getHomeListData();
  }

  /// 获取家庭列表数据
  void getHomeListData() async {
    var res = await UserApi.getHomegroup();

    if (res.isSuccess) {
      setState(() {
        homeList = res.data.homeList;
      });
    }
  }
}

class SelectHome extends StatefulWidget {
  // 默认选择的家庭id
  final String value;

  /// 家庭变更事件
  final ValueChanged<HomeInfo>? onChange;

  const SelectHome({super.key, this.value = '', this.onChange});

  @override
  State<SelectHome> createState() => _SelectHome();
}
