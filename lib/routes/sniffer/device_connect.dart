import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';
import '../../common/global.dart';

class DeviceConnectState extends State<DeviceConnectPage> {
  bool isLoading = true;
  late Timer _timer; // to be deleted

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
              top: 100,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: MzCell(
                  title: "Cell",
                  rightSlot: DropdownButton(
                    value: "A",
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    alignment: AlignmentDirectional.center,
                    items: const [
                      DropdownMenuItem(value: "A", child: Text("Item A")),
                      DropdownMenuItem(value: "b", child: Text("Item B")),
                    ],
                    icon: Image.asset(
                      "assets/imgs/icon/arrow-right.png",
                      width: 30,
                      height: 30,
                    ),
                    onChanged: (e) {
                      logger.i('changed');
                    },
                  ))),



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
