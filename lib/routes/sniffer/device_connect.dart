import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/models/device_entity.dart';
import 'package:screen_app/widgets/index.dart';
import '../../states/device_change_notifier.dart';

// 模拟数据 TODO 改为接口查询 @魏
var roomList = {'客厅': '客厅', '餐厅': '餐厅', '主卧': '主卧', '客卧': '客卧', '阳台': '阳台'};

class DeviceWithRoom extends DeviceEntity {
  late String room;
  DeviceWithRoom(): super();
}

class DeviceConnectState extends State<DeviceConnectPage> {
  bool isLoading = true;
  late Timer _timer; // to be deleted
  List<DeviceWithRoom> dList = [];

  void goBack() {
    Navigator.pop(context);
  }

  // 生成设备列表
  List<MzCell> _listView() {
    return dList.map((d) {
      return MzCell(
        title: d.name,
        titleSize: 24,
        rightSlot: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: d.room,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              alignment: AlignmentDirectional.topCenter,
              items: roomList.keys
                  .map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minWidth: 100),
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 24,
                            fontFamily: "MideaType",
                            fontWeight: FontWeight.w400)),
                  ),
                );
              }).toList(),
              dropdownColor: const Color(0XFF626262),
              focusColor: Colors.blue,
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: 30,
              iconEnabledColor: Colors.white,
              onChanged: (String? value) {
                setState(() => d.room = value!);
              },
            )),
        hasTopBorder: true,
        hasBottomBorder: true,
        padding:
        const EdgeInsets.symmetric(vertical: 17, horizontal: 26),
      );
    }).toList();
  }

  // TODO 完善数据查询 @魏
  Future<void> initQuery() async {
    // ! 模拟设备连接过程
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      timer.cancel();

      setState(() => isLoading = false);

      // ! 模拟数据 直接从已有设备列表中截取数据，实际上应该从查找到的数据中匹配显示
      var deviceList = context.read<DeviceListModel>().deviceList;

      setState(() => dList = deviceList.map((d) {
        var res = DeviceWithRoom();
        res.name = d.name;
        res.room = roomList.keys.first;
        return res;
      }).toList());
    });
  }

  @override
  void initState() {
    super.initState();

    // 页面加载完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initQuery();
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
        padding: const EdgeInsets.symmetric(vertical: 16));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 16));

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
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
                  title: '设备连接',
                  desc: '已成功添加${dList.length}台设备',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),

          Positioned(
              top: 70,
              left: 7,
              right: 7,
              bottom: 64,
              child: ListView(children: _listView())),

          Positioned(
              left: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Expanded(
                  child: TextButton(
                      style: buttonStyle,
                      onPressed: () {},
                      child: const Text('上一步',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: 'MideaType'))),
                ),
                Expanded(
                  child: TextButton(
                      style: buttonStyleOn,
                      onPressed: () {},
                      child: const Text('完成添加',
                          style: TextStyle(
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

class DeviceConnectPage extends StatefulWidget {
  const DeviceConnectPage({super.key});

  @override
  DeviceConnectState createState() => DeviceConnectState();
}
