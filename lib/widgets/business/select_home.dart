import 'package:flutter/material.dart';

import '../../common/index.dart';
import '../../models/index.dart';
import '../index.dart';

class _SelectHome extends State<SelectHome> {
  List<HomeEntity> homeList = [];

  String _homeId = '';

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];
    for (var i = 0; i < homeList.length; i++) {
      var item = homeList[i];
      var addressList = item.address.split(' ');

      listView.add(
        MzCell(
            height: 99,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            title: item.name,
            titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
            titleSize: 24,
            descSize: 18,
            tag: '创建',
            bgColor: Colors.transparent,
            hasTopBorder: false,
            hasBottomBorder: i + 1 != homeList.length + 1,
            desc:
                '房间${item.roomCount}  |  设备${item.applianceCount}  |  成员${item.memberCount}  |  ${addressList.last}',
            onTap: () {
              setState(() {
                _homeId = item.homegroupId;
              });

              widget.onChange?.call(item);
            },
            rightSlot: MzRadio<String>(
              activeColor: const Color.fromRGBO(0, 145, 255, 1),
              value: item.homegroupId,
              groupValue: _homeId,
            )),
      );
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

    _homeId = widget.value;
    getHomeListData();
  }

  /// 获取家庭列表数据
  void getHomeListData() async {
    var res = await UserApi.getHomeListFromMidea();

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
  final ValueChanged<HomeEntity>? onChange;

  const SelectHome({super.key, this.value = '', this.onChange});

  @override
  State<SelectHome> createState() => _SelectHome();
}
