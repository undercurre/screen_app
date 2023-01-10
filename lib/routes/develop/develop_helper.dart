// 开发者帮助类

import 'package:flutter/material.dart';
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,  MaterialPageRoute(builder: (context) => ZigbeeDeviceManager())
                  );
                },
                child: const Text("进入添加Zigbee子设备"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,  MaterialPageRoute(builder: (context) => WiFiDeviceManager())
                  );
                },
                child: const Text("进入添加WiFi子设备"),
              ),
            ),
          ]),
    );
  }

}
