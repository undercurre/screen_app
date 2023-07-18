import 'package:flutter/material.dart';

import '../../common/adapter/select_family_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../index.dart';

class _SelectHome extends State<SelectHome> {
  SelectFamilyDataAdapter? familyDataAd;
  int selectVal = -1;

  @override
  Widget build(BuildContext context) {
    var listView = <Widget>[];

    var len = familyDataAd?.familyListEntity?.familyList.length ?? 0;
    for (var i = 0; i < len; i++) {
      var item = familyDataAd?.familyListEntity?.familyList[i];

      listView.add(
        MzCell(
            height: 99,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            title: item?.familyName,
            titleColor: const Color.fromRGBO(255, 255, 255, 0.85),
            titleSize: 24,
            descSize: 18,
            tag: '创建',
            bgColor: Colors.transparent,
            hasTopBorder: false,
            hasBottomBorder: i + 1 != len + 1,
            desc:
                '房间${item?.roomNum}  |  设备${item?.deviceNum}  |  成员${item?.userNum}',
            onTap: () {
              setState(() {
                selectVal = i;
              });
              checkAndSelect(item!);
            },
            rightSlot: MzRadio<int>(
              activeColor: const Color.fromRGBO(0, 145, 255, 1),
              value: i,
              groupValue: selectVal,
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

    familyDataAd = SelectFamilyDataAdapter(MideaRuntimePlatform.platform);
    familyDataAd?.bindDataUpdateFunction(() {
      setState(() {});
    });
    familyDataAd?.queryFamilyList();
  }

  @override
  void dispose() {
    super.dispose();
    familyDataAd?.destroy();
    familyDataAd = null;
  }

  void checkAndSelect(SelectFamilyItem item) {
    familyDataAd?.queryHouseAuth(item).then((isAuth) {
      if (isAuth == true) {
        widget.onChange?.call(item);
      }
    });

  }

}

class SelectHome extends StatefulWidget {

  /// 家庭变更事件
  final ValueChanged<SelectFamilyItem>? onChange;

  const SelectHome({super.key, this.onChange});

  @override
  State<SelectHome> createState() => _SelectHome();
}
