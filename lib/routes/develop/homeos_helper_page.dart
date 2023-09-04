

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_app/channel/index.dart';

import '../../common/homlux/lan/homlux_lan_control_device_manager.dart';
import '../../common/logcat_helper.dart';

class HomeOsHelperPage extends StatefulWidget {
  const HomeOsHelperPage({super.key});

  @override
  State<HomeOsHelperPage> createState() => _HomeOsHelperPageState();
}


class _HomeOsHelperPageState extends State<HomeOsHelperPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homeos设备测试页面"),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    lanDeviceControlChannel.getSceneInfo('12313212');
                  },
                  child: const Card(
                    color: Colors.green,
                    child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(child: Text('获取本地场景列表'))
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HomluxLanControlDeviceManager.getInstant().executeScene('df3d96cd0b25450c962a3a0c199ffa57');
                  },
                  child: const Card(
                    color: Colors.green,
                    child:SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: Text('控制本地场景')),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    lanDeviceControlChannel.getGroupInfo('12313212');
                  },
                  child: const Card(
                    color: Colors.green,
                    child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(child: Text('获取本地灯组列表'))
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Log.i('控制灯组');
                    HomluxLanControlDeviceManager.getInstant().executeGroup('78f95dd791ef4f39b7548823f822a308', [
                      {'power': 1}
                    ]);
                  },
                  child: const Card(
                    color: Colors.green,
                    child:SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: Text('控制控制本地灯组')),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    lanDeviceControlChannel.getDeviceInfo('12313212');
                  },
                  child: const Card(
                    color: Colors.green,
                    child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(child: Text('获取本地设备列表'))
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Log.i('控制设备');
                    HomluxLanControlDeviceManager.getInstant().executeDevice('78f95dd791ef4f39b7548823f822a308', [
                      {'power': 1}
                    ]);
                  },
                  child: const Card(
                    color: Colors.green,
                    child:SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: Text('控制控制本地灯组')),
                    ),
                  ),
                )
              ],
            ),
          ],

        ),
      ),
    );
  }
}
