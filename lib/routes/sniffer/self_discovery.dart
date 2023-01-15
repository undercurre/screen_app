import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/widgets/index.dart';

import '../../common/global.dart';
import '../home/device/register_controller.dart';
import '../home/device/service.dart';
import 'device_item.dart';

// 模拟数据 TODO 改为接口查询 @魏
var mockData = [
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x14",
    "name": '智能窗帘',
  },
  {
    "type": "0x26",
    "name": '浴霸',
  },
  {
    "type": "0x09",
    "name": '智能门锁',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x13",
    "name": '吸顶灯',
  },
  {
    "type": "0x14",
    "name": '智能窗帘',
  },
  {
    "type": "0x26",
    "name": '浴霸',
  },
  {
    "type": "0x09",
    "name": '智能门锁',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x26",
    "name": '浴霸',
  },
  {
    "type": "0x09",
    "name": '智能门锁',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  },
  {
    "type": "0x2B",
    "name": '摄像头',
  }
].map((d) => DeviceEntity.fromJson(d)).toList();

class SelfDiscoveryState extends State<SelfDiscoveryPage> {
  late Timer _timer; // to be deleted
  List<Device> dList = []; // 格式化后的设备列表数据，带 selected 属性

  void goBack() {
    Navigator.pop(context);
  }

  bool hasSelected() {
    return dList.any((d) => d.selected);
  }

  // 生成设备列表
  GridView _gridView() {
    return GridView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
      ),
      children: dList
          .map((device) => DeviceItem(
              boxSize: 110,
              circleSize: 80,
              fontSize: 18,
              device: device,
              onTap: (d) {
                setState(() => d.selected = !d.selected);
              }))
          .toList(),
    );
  }

  // TODO 完善数据查询 @魏
  Future<void> initQuery() async {
    // ! 模拟发现设备过程
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      timer.cancel();

      // 格式化数据
      setState(() => dList = mockData.map((d) {
            var hasController = controllerList.keys.any((key) => key == d.type);
            var icon = hasController
                ? DeviceService.getOnIcon(d)
                : 'assets/imgs/device/phone_on.png'; // TODO 替换为无类型设备图标

            return Device(
                key: d.type, name: d.name, icon: icon, selected: false);
          }).toList());
    });
  }

  // 关闭设备自发现确认
  Future<void> disableNotice() async {
    // 模拟弹出网络异常
    MzDialog mzDialog = MzDialog(
        desc: '此操作将关闭设备自发现功能',
        descSize: 24,
        btns: ['取消', '确定'],
        maxWidth: 420,
        titlePadding: const EdgeInsets.symmetric(vertical: 45, horizontal: 10),
        onPressed: (String item, int index) {
          logger.i('$index: $item');
        });

    await mzDialog.show(context);
  }

  @override
  void initState() {
    super.initState();

    initQuery();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));
    TextStyle textStyle = const TextStyle(
        fontSize: 24, color: Colors.white, fontFamily: 'MideaType');

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          // 顶部导航
          MzNavigationBar(
            onLeftBtnTap: goBack,
            title: '设备自发现',
            hasBottomBorder: true,
            sideBtnWidth: 100,
            rightSlot: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '不再提示',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Color(0XFF267AFF),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'MideaType'),
              ),
            ),
            onRightBtnTap: disableNotice,
          ),

          // 设备阵列
          Positioned(
            top: 100,
            left: 10,
            width: MediaQuery.of(context).size.width - 10,
            height: MediaQuery.of(context).size.height - 100,
            child: _gridView(),
          ),

          if (dList.isNotEmpty)
            Positioned(
                left: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                        style: buttonStyle,
                        onPressed: () => {},
                        child: Text('忽略', style: textStyle)),
                  ),
                  const VerticalDivider(width: 0.5, color: Colors.transparent),
                  Expanded(
                    child: TextButton(
                        style: hasSelected() ? buttonStyleOn : buttonStyle,
                        onPressed: () => {},
                        child: Text('确定', style: textStyle)),
                  )
                ])),
        ],
      ),
    );
  }
}

class SelfDiscoveryPage extends StatefulWidget {
  const SelfDiscoveryPage({super.key});

  @override
  SelfDiscoveryState createState() => SelfDiscoveryState();
}
