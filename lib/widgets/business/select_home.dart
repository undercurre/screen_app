import 'package:flutter/material.dart';

import '../../common/adapter/select_family_data_adapter.dart';
import '../../common/gateway_platform.dart';
import '../../common/utils.dart';
import '../index.dart';

class SelectHomeState extends State<SelectHome> {
  SelectFamilyDataAdapter? familyDataAd;
  int selectVal = -1;
  SelectFamilyItem? itemTemp;

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
            tag: familyDataAd?.familyListEntity?.familyList[i].houseCreatorFlag == true ? '创建' : null,
            bgColor: Colors.transparent,
            hasTopBorder: false,
            hasBottomBorder: i + 1 != len + 1,
            desc:
                '房间${item?.roomNum}  |  设备${item?.deviceNum}  |  成员${item?.userNum}',
            onTap: () {
              setState(() {
                selectVal = i;
              });
              itemTemp = item;
            },
            rightSlot: MzRadio<int>(
              activeColor: const Color.fromRGBO(0, 145, 255, 1),
              value: i,
              groupValue: selectVal,
            )),
      );
    }

    if(len > 0) {
      listView.add(const SizedBox(
        width: 432,
        height: 44,
        child: Center(
            child: Text(
              '已经到底了！',
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
      alignment: Alignment.center,
      child: Stack(
        children: [
          if(len == 0) Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 480,
              height: 260,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),

          if(len > 0) SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: 432,
              margin: const EdgeInsets.fromLTRB(24, 10, 24, 50),
              decoration: const BoxDecoration(
                  color: Color(0xFF303441),
                  borderRadius: BorderRadius.all(Radius.circular(16))
              ),
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

  void checkAndSelect() {
    if (itemTemp == null) {
      TipsUtils.toast(content: '请选择家庭');
      return;
    }
    familyDataAd?.queryHouseAuth(itemTemp!).then((isAuth) {
      if (isAuth == true) {
        widget.onChange?.call(itemTemp);
      } else {
        TipsUtils.toast(content: '该家庭无登陆权限，请重新选择');
      }
    });
  }

}

class SelectHome extends StatefulWidget {

  /// 家庭变更事件
  final ValueChanged<SelectFamilyItem?>? onChange;

  const SelectHome({super.key, this.onChange});

  @override
  State<SelectHome> createState() => SelectHomeState();
}
