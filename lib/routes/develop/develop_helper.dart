// 开发者帮助类

import 'package:flutter/material.dart';
import 'package:screen_app/routes/develop/relay_page.dart';
import 'package:screen_app/routes/develop/screen_on_off.dart';
import 'package:screen_app/routes/develop/wifi_manager.dart';
import 'package:screen_app/routes/develop/zigbee_manager.dart';

class DeveloperHelperPage extends StatelessWidget {
  const DeveloperHelperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
           Navigator.of(context).pop();
          },
        ),
        title: const Text("Flutter开发者页面"),
      ),
      body: Column(
          children: [
            item("进入添加Zigbee子设备", () => Navigator
                .push(context, MaterialPageRoute(builder: (context) => ZigbeeDeviceManager()))),
            item("进入添加WiFi子设备", () => Navigator
                .push(context, MaterialPageRoute(builder: (context) => const WiFiDeviceManager()))),
            item("息屏亮屏测试", () => Navigator
                .push(context, MaterialPageRoute(builder: (context) => const ScreenOnOffPage()))),
            item("继电器测试", () => Navigator
                .push(context, MaterialPageRoute(builder: (context) => const RelayPage()))),
          ]),
    );
  }

  Widget item(String title, void Function() onPress) => Padding(
    padding: const EdgeInsets.all(20),
    child: ElevatedButton(
      onPressed: onPress,
      child: Text(title),
    ),
  );

}
