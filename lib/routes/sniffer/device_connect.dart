import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

var roomList = {'客厅': '客厅', '餐厅': '餐厅', '主卧': '主卧', '客卧': '客卧', '阳台': '阳台'};

class DeviceConnectState extends State<DeviceConnectPage> {
  bool isLoading = true;
  late Timer _timer; // to be deleted
  String selectedItem = roomList.keys.first;

  void goBack() {
    Navigator.pop(context);
  }

  // TODO 完善数据查询 @魏
  Future<void> initQuery() async {
    // ! 模拟设备连接过程
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      timer.cancel();

      setState(() => isLoading = false);
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
        padding: const EdgeInsets.symmetric(vertical: 15));
    ButtonStyle buttonStyleOn = TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(38, 122, 255, 1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(vertical: 15));

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
                  desc: '已成功添加4台设备',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),

          Positioned(
              top: 70,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: MzCell(
                title: "智能窗帘",
                titleSize: 24,
                rightSlot: DropdownButtonHideUnderline(
                    child: DropdownButton(
                  value: selectedItem,
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
                  icon: const Icon(Icons.arrow_forward_ios_sharp),
                  iconEnabledColor: Colors.white,
                  onChanged: (String? value) {
                    setState(() => selectedItem = value!);
                  },
                )),
                hasTopBorder: true,
                hasBottomBorder: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 17, horizontal: 26),
              )),

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
