import 'package:flutter/material.dart';
import 'package:screen_app/widgets/index.dart';

class DeviceConnectState extends State<DeviceConnectPage> {

  void goBack() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    // 页面加载完成
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black
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
                  title: '设备连接',
                ),
              ),
            ],
          ),
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
