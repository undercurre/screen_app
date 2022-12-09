import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/routes/device/config.dart';
import 'device_item.dart';

// TODO 模拟数据
const mockData = [
  {
    "deviceType": "0x13",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x14",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x17",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x26",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x09",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x2B",
    "deviceId": 'dd',
  },
  {
    "deviceType": "0x2B",
    "deviceId": 'dd',
  }
];

class SnifferState extends State<SnifferPage> {
  late Timer _timer; // to be deleted
  double turns = 0; // 控制扫描动画圈数
  final int timeout = 30; // 设备查找时间
  final int timePerTurn = 3; // 转一圈所需时间
  List<Device> dList = []; // 格式化后的设备列表数据

  void goBack() {
    Navigator.pop(context);
  }

  void toDeviceConnect() {
    if (hasSelected()) {
      Navigator.pushNamed(context, 'DeviceConnectPage');
    }
  }

  bool hasSelected() {
    return dList.any((d) => d.selected);
  }

  // 生成设备列表
  List<Widget> _listView() {
    return dList
        .map((device) => DeviceItem(
            device: device,
            onTap: (d) {
              setState(() => d.selected = !d.selected);
            }))
        .toList();
  }

  // TODO 完善数据查询 @魏
  Future<void> initQuery() async {
    // ! 模拟发现设备过程
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      timer.cancel();

      // 格式化数据
      setState(() => dList = mockData.map((d) {
            String? type = d['deviceType'];
            var finder = deviceConfig.where((element) => element.type == type);
            var temp = finder.isEmpty ? something : finder.first;

            return Device(
                key: temp.type,
                name: temp.name,
                icon: temp.onIcon,
                selected: false);
          }).toList());
    });
  }

  @override
  void initState() {
    super.initState();

    initQuery();

    // 页面加载完成，即开始执行扫描动画
    // HACK 0.5 使扫描光线图片恰好转到视图下方，无法看到
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => turns -= timeout / timePerTurn - 0.5);
    });
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
        padding: const EdgeInsets.symmetric(vertical: 15));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 15));

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/imgs/device/sniffer_01.png")),
      ),
      child: Stack(
        children: [
          // 顶部导航
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  maxHeight: 60.0,
                ),
                child: MzNavigationBar(
                  onLeftBtnTap: goBack,
                  title: '发现设备',
                ),
              ),
            ],
          ),

          // 扫描动画
          Positioned(
              left: MediaQuery.of(context).size.width / 2,
              bottom: 0,
              child: AnimatedRotation(
                turns: turns,
                alignment: Alignment.bottomLeft,
                duration: Duration(seconds: timeout),
                child: const Image(
                  height: 296,
                  width: 349,
                  image: AssetImage("assets/imgs/device/sniffer_02.png"),
                ),
              )),

          // 设备阵列
          Positioned(
              top: 128,
              width: MediaQuery.of(context).size.width,
              child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  runSpacing: 6,
                  children: _listView())),

          if (dList.isEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              left: 0,
              child: const Center(
                child: Text('正在搜索设备',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'MideaType')),
              ),
            ),
          if (dList.isNotEmpty)
            Positioned(
                left: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                        style: hasSelected() ? buttonStyleOn : buttonStyle,
                        onPressed: () => toDeviceConnect(),
                        child: Text(hasSelected() ? '添加设备' : '选择设备',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'MideaType'))),
                  ),
                ])),
        ],
      ),
    );
  }
}

class SnifferPage extends StatefulWidget {
  const SnifferPage({super.key});

  @override
  SnifferState createState() => SnifferState();
}
